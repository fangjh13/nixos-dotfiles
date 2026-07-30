# Secrets with sops-nix

[SOPS](https://github.com/getsops/sops) encrypts secret values before they are
committed, and [sops-nix](https://github.com/Mic92/sops-nix) decrypts them when
the system is activated. Every NixOS and nix-darwin host created through
`lib/mk_system.nix` already imports the appropriate system module and the
shared `modules/public/sops.nix` configuration. A new host only needs its own
recipient, creation rule, encrypted file, and `sops.secrets` declarations.
The shared Home Manager package list also installs `sops`, `age`, and
`ssh-to-age` for the primary user on both platforms.

Encrypted files belong in `secrets/<hostname>/`. Administrator and host private
keys, plaintext source files, and decrypted files must never be committed.
sops-nix writes decrypted secrets to `/run/secrets/<name>` by default, outside
the Nix store, with owner `root` and mode `0400`.

## Identities and recipients

This repository uses two recipients for each host:

- An administrator age identity allows a trusted user to create and edit the
  encrypted files.
- The target's SSH Ed25519 host identity allows that machine to decrypt its
  files unattended during activation.

Each host-specific rule in `.sops.yaml` includes the administrator recipient
and only that host's recipient. Therefore one machine does not automatically
gain access to another machine's secrets.

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
  - path_regex: ^secrets/atlas/[^/]+$
    key_groups:
      - age:
          - *admin_fython
          - *atlas

  - path_regex: ^secrets/MacBook-Air/[^/]+$
    key_groups:
      - age:
          - *admin_fython
          - *macbook_air
```

Use the real recipients and append the new entries without removing existing
hosts. The directory in `path_regex` must exactly match the host directory
under `secrets/`.

### 3. Create or import an encrypted file

For a structured YAML secret on the NixOS example host:

```shell
mkdir -p secrets/atlas
sops secrets/atlas/secrets.yaml
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
mkdir -p secrets/MacBook-Air
sops encrypt \
  --filename-override secrets/MacBook-Air/app-config.json \
  --input-type binary \
  --output-type binary \
  --output secrets/MacBook-Air/app-config.json.new \
  /path/to/plaintext-app-config.json
mv secrets/MacBook-Air/app-config.json.new \
  secrets/MacBook-Air/app-config.json
```

`--filename-override` makes SOPS select the creation rule for the final
repository path.

### 4. Declare the secret in the target host

Add declarations to `hosts/<hostname>/default.nix`. A structured secret name
must match the key inside the encrypted document. For example,
`hosts/atlas/default.nix` can declare the YAML value created above:

```nix
{
  config,
  ...
}: {
  sops.secrets."database-password" = {
    sopsFile = ../../secrets/atlas/secrets.yaml;
    format = "yaml";
  };

  # Pass this path to the service that consumes the secret:
  # config.sops.secrets."database-password".path
}
```

For a whole-file secret, set `format = "binary"`. For example,
`hosts/MacBook-Air/default.nix` can declare the imported JSON configuration:

```nix
{
  config,
  ...
}: {
  sops.secrets."app-config" = {
    sopsFile = ../../secrets/MacBook-Air/app-config.json;
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

## Daily operations

Edit an existing encrypted document in place:

```shell
sops secrets/<hostname>/<secret-file>
```

After adding, removing, or rotating a recipient in `.sops.yaml`, rewrap each
affected file's data key without exposing its plaintext:

```shell
sops updatekeys secrets/<hostname>/<secret-file>
```

sops-nix-managed files under `/run/secrets` should be treated as immutable. If
an application must update a credential or refresh token, copy the decrypted
seed into application-owned persistent state and explicitly synchronize
intentional changes back into an encrypted file.

## Repository examples

These examples document special handling already used by particular hosts.
New hosts should follow the generic workflow above and substitute their own
hostnames, recipients, secret names, and service options.

### NixOS: mutable rclone configuration

The `vmnixos` rclone configuration is a native SOPS-encrypted INI file:

```shell
sops secrets/vmnixos/rclone.ini
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
  --filename-override secrets/vmnixos/rclone.ini \
  --input-type ini \
  --output-type ini \
  --output secrets/vmnixos/rclone.ini.new \
  /var/lib/rclone/rclone.conf
mv secrets/vmnixos/rclone.ini.new secrets/vmnixos/rclone.ini
```

### nix-darwin: whole-file sing-box configuration

The `MacBook-Pro-2` sing-box JSONC configuration is encrypted as one binary
SOPS document so comments and formatting survive byte-for-byte:

```shell
sops encrypt \
  --filename-override secrets/MacBook-Pro-2/sing-box.jsonc \
  --input-type binary \
  --output-type binary \
  --output secrets/MacBook-Pro-2/sing-box.jsonc.new \
  /path/to/sing-box.jsonc
mv secrets/MacBook-Pro-2/sing-box.jsonc.new \
  secrets/MacBook-Pro-2/sing-box.jsonc
```

sops-nix decrypts it to `/run/secrets/sing-box-config` as a root-owned,
read-only file. Validate an update without writing plaintext to disk:

```shell
sops decrypt --output-type binary \
  secrets/MacBook-Pro-2/sing-box.jsonc |
  nix shell \
    '.?submodules=1#darwinConfigurations.MacBook-Pro-2.config.services.sing-box.package' \
    -c sing-box --disable-color -c stdin check
```

### Mihomo transparent proxy

The Darwin Mihomo module runs a root LaunchDaemon for TUN and transparent
proxy route management. It is disabled by default. Declare the whole YAML
configuration as a sops-nix binary secret in `hosts/<host>/default.nix`:

```nix
sops.secrets."<secret>" = {
  sopsFile = ../../secrets/<host>/<secret>.yaml;
  format = "binary";
  owner = "root";
  mode = "0400";
};

services.mihomo = {
  enable = true;
  configFile = config.sops.secrets."<secret>".path;
};
```

Keep the configuration outside this repository. Create or replace
the encrypted file:

```shell
mihomo_secret=secrets/<host>/<secret>.yaml
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
