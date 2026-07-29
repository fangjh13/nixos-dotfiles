## Secrets with sops-nix

Both NixOS and nix-darwin systems import the system-level
[sops-nix](https://github.com/Mic92/sops-nix) module. Encrypted files are
committed to `secrets/<hostname>/`, while private keys and decrypted files stay
outside the repository and the Nix store.

### Bootstrap an administrator identity

Create one personal age identity on a trusted machine and back up
`keys.txt` to a password manager or encrypted offline storage before using it:

```shell
mkdir -p ~/.config/sops/age
chmod 700 ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt
```

On macOS, SOPS also supports
`$HOME/Library/Application Support/sops/age/keys.txt` as its native user
configuration path.

Each target uses its existing SSH Ed25519 host key for unattended decryption.
Only add the converted public recipient to `.sops.yaml`; never copy a host
private key into this repository:

```shell
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
```

Add the administrator and host recipients to one `creation_rules` entry for
that host. When recipients change, rewrap the data key without exposing the
plaintext:

```shell
sops updatekeys secrets/<hostname>/<secret-file>
```

## Encrypted Files

### rclone configuration

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
