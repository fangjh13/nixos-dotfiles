# Overlays

This directory contains repository-local Nixpkgs overlays. The overlays are
loaded by `modules/public/system.nix` and applied through the NixOS
`nixpkgs.overlays` option, so packages defined or changed here are available
from the global `pkgs` set used by the system configuration.

Use this directory when you need to:

- add a local package to `pkgs`
- override an existing package from Nixpkgs
- expose a package from a flake input as part of the normal package set
- keep package customizations out of host, NixOS, or Home Manager modules

Do not use overlays for service configuration, user configuration, shell setup,
or module options. Those belong under `modules/`, `hosts/`, or the Home Manager
configuration.

## Loading Rules

`modules/public/system.nix` scans this directory and imports:

- every `*.nix` file
- every subdirectory that contains `default.nix`

Each imported file must evaluate to one of these forms:

1. A regular Nixpkgs overlay:

   ```nix
   final: prev: {
     # package overrides or additions
   }
   ```

2. A function that receives flake inputs and returns an overlay:

   ```nix
   {inputs}:
   final: prev: {
     # package overrides or additions that need inputs
   }
   ```

   This form is only needed when the overlay depends on a flake input.

The loader checks whether the imported function declares an `inputs` argument.
If it does, the loader calls the file with `{ inherit inputs; }`. Otherwise, the
imported value is used directly as a normal overlay.

## File Layout

For small overlays, use a single file:

```text
overlays/
  neovim-nightly.nix
  my-tools.nix
```

For overlays with multiple helper files or local package expressions, use a
directory with `default.nix`:

```text
overlays/
  my-packages/
    default.nix
    my-script.nix
```

The directory form keeps related package code together while still being picked
up automatically by the loader.

## Examples

### Add a Small Local Package

`overlays/my-tools.nix`:

```nix
_final: prev: {
  my-script = prev.writeShellApplication {
    name = "my-script";

    text = ''
      echo "Hello from a local overlay"
    '';
  };
}
```

After evaluation, the package is available as `pkgs.my-script`.

### Override an Existing Package

`overlays/fzf.nix`:

```nix
_final: prev: {
  fzf = prev.fzf.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or []) ++ [
      ./fzf-local.patch
    ];
  });
}
```

Use `prev` to refer to the package set before this overlay, and use `final`
when you need dependencies from the fully extended package set.

### Use a Flake Input Overlay

`overlays/neovim-nightly.nix`:

```nix
{inputs}:
inputs.neovim-nightly-overlay.overlays.default
```

This exposes the overlay provided by the `neovim-nightly-overlay` flake input
without keeping that input-specific logic inside a NixOS module.

### Add Packages from a Directory Overlay

`overlays/my-packages/default.nix`:

```nix
_final: prev: {
  my-script = prev.callPackage ./my-script.nix {};
}
```

`overlays/my-packages/my-script.nix`:

```nix
{writeShellApplication}:

writeShellApplication {
  name = "my-script";

  text = ''
    echo "Hello from a directory overlay"
  '';
}
```

## Temporarily Disabling an Overlay

The loader has an `excludedFiles` list in `modules/public/system.nix`. Add a file
or directory name there when an overlay should remain in the repository but not
be applied:

```nix
excludedFiles = [
  "experimental-package.nix"
];
`
```
