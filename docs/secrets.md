# Secrets with sops-nix

[SOPS](https://github.com/getsops/sops) encrypts secret values before they are
committed, and [sops-nix](https://github.com/Mic92/sops-nix) decrypts them when
the system is activated. Every NixOS and nix-darwin host created through
`lib/mk_system.nix` already imports the appropriate system module and the
shared `modules/public/sops.nix` configuration. A new host only needs its own
recipient, creation rule, encrypted file, and `sops.secrets` declarations.
The shared Home Manager package list also installs `sops`, `age`, and
`ssh-to-age` for the primary user on both platforms.

Host-only encrypted files belong in `hosts/<hostname>/secrets/`. Encrypted
files shared by an explicit set of hosts live beside an opt-in declaration
module in `modules/public/secrets/<scope>/`. Administrator and host private
keys, plaintext source files, and decrypted files must never be committed.
sops-nix writes decrypted secrets to `/run/secrets/<name>` by default, outside
the Nix store, with owner `root` and mode `0400`.

The shared creation rule accepts `.yaml`, `.jsonc`, `.json`, `.ini`, and
`.toml` files located directly below one `<scope>` directory. Nested files and
files directly below `modules/public/secrets/` do not match it.

## Identities and recipients

This repository uses two recipients for each host:

- An administrator age identity allows a trusted user to create and edit the
  encrypted files.
- The target's SSH Ed25519 host identity allows that machine to decrypt its
  files unattended during activation.

Each host-specific rule in `.sops.yaml` includes the administrator recipient
and only that host's recipient. Therefore one machine does not automatically
gain access to another machine's secrets. A shared rule lists the administrator
and every authorized host in one `age` key group, so each listed identity can
decrypt independently. Split files by access scope; SOPS does not provide
different recipient sets for individual values within one encrypted file.

### Create the administrator identity once

If an administrator identity already exists, reuse it; do not generate a
replacement. Otherwise, create it on a trusted machine and immediately back up
`keys.txt` to a password manager or encrypted offline storage:

```shell
mkdir -p ~/.config/sops/age
chmod 700 ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt
```

The last command prints the public recipient that may be added to
`.sops.yaml`. The private identity stays in `keys.txt`. On macOS, SOPS also
supports `$HOME/Library/Application Support/sops/age/keys.txt` as its native
user configuration path.

## Add a new host

Run the following steps for every new NixOS or nix-darwin host. Step 1 runs on
the target. Run steps 2–4 on a trusted machine that has both the checkout and
the administrator identity; the target itself may serve that role. Step 5
builds and activates the target using the normal local or remote workflow.
Commands that refer to repository paths should be run from the repository
root.

### 1. Get the new host's recipient

This repository sets `sops.age.sshKeyPaths` on both platforms so they decrypt
with `/etc/ssh/ssh_host_ed25519_key`. On the new host, make sure the key exists
and convert only its public key to an age recipient:

```shell
test -f /etc/ssh/ssh_host_ed25519_key || sudo ssh-keygen -A
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
```

The output beginning with `age1` is the host recipient. Never copy
`/etc/ssh/ssh_host_ed25519_key` or any other private key into the repository.
If `ssh-to-age` is not installed before the host's first activation, copy or
pipe the public `.pub` file to the trusted administrator machine and run
`ssh-to-age` there; conversion does not require the private key.

### 2. Add a host-specific creation rule

Extend the existing `keys` and `creation_rules` sections in `.sops.yaml`.
The following example adds a NixOS host named `atlas` and a nix-darwin host
named `MacBook-Air`:

```yaml
keys:
  - &admin_fython age1ADMIN_RECIPIENT
  - &atlas age1ATLAS_RECIPIENT
  - &macbook_air age1MACBOOK_AIR_RECIPIENT

creation_rules:
  - path_regex: ^hosts/atlas/secrets/[^/]+$
    key_groups:
      - age:
          - *admin_fython
          - *atlas

  - path_regex: ^hosts/MacBook-Air/secrets/[^/]+$
    key_groups:
      - age:
          - *admin_fython
          - *macbook_air
```

Use the real recipients and append the new entries without removing existing
hosts. The directory in `path_regex` must exactly match the host directory
under `hosts/`.

### 3. Create or import an encrypted file

For a structured YAML secret on the NixOS example host:

```shell
mkdir -p hosts/atlas/secrets
sops hosts/atlas/secrets/secrets.yaml
```

The editor may contain values such as:

```yaml
database-password: replace-me
```

SOPS encrypts the value when the editor closes. YAML, JSON, dotenv, and INI are
structured formats: their keys remain visible so sops-nix can extract a named
value.

Use binary mode when a service needs the entire decrypted file byte-for-byte.
For example, import a JSON configuration for the nix-darwin example host
without first copying its plaintext into the repository:

```shell
mkdir -p hosts/MacBook-Air/secrets
sops encrypt \
  --filename-override hosts/MacBook-Air/secrets/app-config.json \
  --input-type binary \
  --output-type binary \
  --output hosts/MacBook-Air/secrets/app-config.json.new \
  /path/to/plaintext-app-config.json
mv hosts/MacBook-Air/secrets/app-config.json.new \
  hosts/MacBook-Air/secrets/app-config.json
```

> `--filename-override` makes SOPS select the creation rule for the final
> repository path.

### 4. Declare the secret in the target host

Add declarations to `hosts/<hostname>/secrets/default.nix`. A structured secret name
must match the key inside the encrypted document. For example,
`hosts/atlas/secrets/default.nix` can declare the YAML value created above:

```nix
{
  config,
  ...
}: {
  sops.secrets."database-password" = {
    sopsFile = ./secrets.yaml;
    format = "yaml";
  };

  # Pass this path to the service that consumes the secret:
  # config.sops.secrets."database-password".path
}
```

For a whole-file secret, set `format = "binary"`. For example,
`hosts/MacBook-Air/secrets/default.nix` can declare the imported JSON configuration:

```nix
{
  config,
  ...
}: {
  sops.secrets."app-config" = {
    sopsFile = ./secrets/app-config.json;
    format = "binary";
    owner = "root";
    mode = "0400";
  };

  # Pass this path to the service that consumes the file:
  # config.sops.secrets."app-config".path
}
```

Use `config.sops.secrets."<name>".path` instead of embedding secret contents in
a Nix string. Override `owner`, `group`, or `mode` only when the consuming
service requires different access.

### 5. Build and verify the target

Evaluate the repository first:

```shell
nix flake check '.?submodules=1' --no-build
```

For a NixOS host, build and temporarily activate the configuration:

```shell
sudo nixos-rebuild test --flake '.?submodules=1#atlas'
sudo ls -l /run/secrets/database-password
```

For a nix-darwin host, build before switching:

```shell
nix build '.?submodules=1#darwinConfigurations.MacBook-Air.system'
sudo darwin-rebuild switch --flake '.?submodules=1#MacBook-Air'
sudo ls -l /run/secrets/app-config
```

Inspect only metadata during routine verification. Do not print decrypted
values into terminal history or build logs.

### Shared secret modules

Host-shared configurations are located in the `modules/public/secrets/<scope>/` directory.
The `default.nix` file within defines multiple sops-nix secrets;
hosts must explicitly opt in to enable this configuration:

```nix
{
  config,
  ...
}: {
  imports = [
    ../../modules/public/secrets/<scope>
  ];

  # Pass this path to the service that consumes the secret:
  # config.sops.secrets."database-password".path
}
```

One generic `.sops.yaml` rule covers these module-local files:

```yaml
- path_regex: ^modules/public/secrets/[^/]+/[^/]+\.(yaml|jsonc|json|ini|toml)$
  key_groups:
    - age:
        - *admin_user
        - *host1
        - *host2
        - ...
```

The first `[^/]+` is the scope directory and the second is the filename, so the
rule deliberately does not cross directory boundaries. It gives the
administrator and all listed hosts access to every matching shared file.
Importing a module controls consumption; recipient membership controls whether
the host can decrypt it.

SOPS auto-detects `.yaml`, `.json`, and `.ini` as structured formats. The
repository also allows `.jsonc` and `.toml` names, but SOPS does not infer a
native structured format from those extensions; handle them as whole-file
binary secrets. A YAML, JSON, or INI file may also intentionally use binary
mode when a service needs the original bytes preserved.

Creation rules use first-match semantics. If a future scope needs a different
recipient set, add a scope-specific rule before this generic rule instead of
placing it after the generic match.

## Daily operations

Edit an existing encrypted document in place:

```shell
sops hosts/<hostname>/secrets/<secret-file>
```

After adding, removing, or rotating a recipient in `.sops.yaml`, rewrap each
affected file's data key without exposing its plaintext:

```shell
sops updatekeys hosts/<hostname>/secrets/<secret-file>
```

For a structured shared secret, use its module-local path instead:

```shell
sops edit modules/public/secrets/<scope>/<secret-file>
sops updatekeys modules/public/secrets/<scope>/<secret-file>
```

Whole-file binary secrets must specify their format explicitly. This includes
`.jsonc` and `.toml` shared files, plus structured extensions such as `.yaml`
when their original bytes must be preserved:

```shell
sops edit \
  --input-type binary \
  --output-type binary \
  modules/public/secrets/<scope>/<secret-file>
sops updatekeys \
  --input-type binary \
  modules/public/secrets/<scope>/<secret-file>
```

sops-nix-managed files under `/run/secrets` should be treated as immutable. If
an application must update a credential or refresh token, copy the decrypted
seed into application-owned persistent state and explicitly synchronize
intentional changes back into an encrypted file.

## Encrypted files

### NixOS: mutable rclone configuration

The rclone configuration is a native SOPS-encrypted INI file:

```shell
sops hosts/<hostname>/secrets/rclone.ini
```

sops-nix decrypts it as a read-only seed at `/run/secrets/rclone-config`.
`rclone-config.service` copies a changed seed atomically into the persistent,
user-owned `/var/lib/rclone/rclone.conf`. The scheduled systemd job passes the
runtime path explicitly, and interactive login sessions receive the same path
through `RCLONE_CONFIG`.

The split is intentional: rclone must write refreshed OAuth tokens back to its
configuration, while files managed directly by sops-nix are immutable. A
seed-version marker preserves runtime token refreshes across ordinary boots and
rebuilds; changing the encrypted seed replaces the runtime configuration on the
next activation.

To persist an intentional change made with `rclone config`, encrypt the runtime
file to a new output first, then replace the committed seed:

```shell
sops encrypt \
  --filename-override hosts/<hostname>/secrets/rclone.ini \
  --input-type ini \
  --output-type ini \
  --output hosts/<hostname>/secrets/rclone.ini.new \
  /var/lib/rclone/rclone.conf
mv hosts/<hostname>/secrets/rclone.ini.new \
  hosts/<hostname>/secrets/rclone.ini
```

### Mihomo transparent proxy

The Darwin Mihomo module runs a root LaunchDaemon for TUN and transparent
proxy route management. It is disabled by default. Import the shared proxy
secret module and enable the service in `hosts/<hostname>/default.nix`:

```nix
imports = [
  ../../modules/public/secrets/proxy-clients
];

services.mihomo = {
  enable = true;
  configFile = config.sops.secrets."mihomo-config".path;
};
```

Keep the configuration outside this repository. Create or replace
the encrypted file:

```shell
mihomo_secret=modules/public/secrets/proxy-clients/mihomo.yaml
mihomo_encrypted_tmp="$(mktemp "${TMPDIR:-/tmp}/mihomo-secret.XXXXXX")"
sops encrypt \
  --filename-override "$mihomo_secret" \
  --input-type binary \
  --output-type binary \
  --output "$mihomo_encrypted_tmp" \
  path_to_mihomo_config.yaml
mv "$mihomo_encrypted_tmp" "$mihomo_secret"
```

Only commit the encrypted file. Validate the module, check the flake, build
the host, and then activate it

If Mihomo is already running, restart it to pick up the new configuration:

```shell
sudo launchctl kickstart -k system/org.nixos.mihomo
```
