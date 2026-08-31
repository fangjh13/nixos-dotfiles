# Modified from: https://gist.github.com/antifuchs/10138c4d838a63c0a05e725ccd7bccdd
{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.local.dock;
  inherit (pkgs) stdenv dockutil;
in {
  options = {
    local.dock.enable = mkOption {
      description = "Enable dock";
      default = stdenv.isDarwin;
      example = false;
    };

    local.dock.autohide = mkOption {
      description = "Automatically hide and show the Dock";
      type = types.bool;
      default = false;
    };

    local.dock.showRecents = mkOption {
      description = "Show recent applications in the Dock";
      type = types.bool;
      default = true;
    };

    local.dock.orientation = mkOption {
      description = "Position of the Dock on screen";
      type = types.enum ["bottom" "left" "right"];
      default = "bottom";
    };

    local.dock.tilesize = mkOption {
      description = "Size of the Dock icons";
      type = types.ints.positive;
      default = 48;
    };

    local.dock.entries =
      mkOption
      {
        description = "Entries on the Dock";
        type = with types;
          listOf (submodule {
            options = {
              type = lib.mkOption {
                type = str;
                default = "app";
              };
              path = lib.mkOption {
                type = str;
                default = "";
              };
              view = lib.mkOption {
                type = str;
                default = "auto";
              };
              display = lib.mkOption {
                type = str;
                default = "folder";
              };
              sort = lib.mkOption {
                type = str;
                default = "datemodified";
              };
              section = lib.mkOption {
                type = str;
                default = "apps";
              };
            };
          });
        readOnly = true;
      };
  };

  config =
    mkIf cfg.enable
    (
      let
        # dockutil reports application and folder URLs with a trailing slash.
        normalize = entry:
          if (entry.type == "folder" || hasSuffix ".app" entry.path) && !hasSuffix "/" entry.path
          then entry.path + "/"
          else entry.path;
        # Compare URLs in the same encoded form emitted by dockutil --list.
        entryURI = entry:
          "file://"
          + (
            builtins.replaceStrings
            [" " "!" "\"" "#" "$" "%" "&" "'" "(" ")"]
            ["%20" "%21" "%22" "%23" "%24" "%25" "%26" "%27" "%28" "%29"]
            (normalize entry)
          );
        wantURIs =
          concatMapStrings
          (entry: "${entryURI entry}\n")
          cfg.entries;
        regularEntries = filter (entry: !hasSuffix "spacer" entry.type) cfg.entries;
        spacerEntries = filter (entry: hasSuffix "spacer" entry.type) cfg.entries;
        folderEntries = filter (entry: entry.type == "folder") regularEntries;
        # A single dockutil transaction applies one set of display options to all folders.
        folderSettings =
          if folderEntries == []
          then null
          else head folderEntries;
        matchingFolderSettings = entry:
          entry.view
          == folderSettings.view
          && entry.display == folderSettings.display
          && entry.sort == folderSettings.sort;
        expectedAutohide =
          if cfg.autohide
          then "1"
          else "0";
        expectedShowRecents =
          if cfg.showRecents
          then "1"
          else "0";
        # Keep these preferences in the same activation as the layout. Using
        # system.defaults.dock would restart Dock before Home Manager and can
        # let a newly started Dock restore stale values from CFPrefsD.
        dockSettingsMatch = concatStringsSep " && " [
          ''[ "$(/usr/bin/defaults read com.apple.dock autohide 2>/dev/null || true)" = ${escapeShellArg expectedAutohide} ]''
          ''[ "$(/usr/bin/defaults read com.apple.dock orientation 2>/dev/null || true)" = ${escapeShellArg cfg.orientation} ]''
          ''[ "$(/usr/bin/defaults read com.apple.dock show-recents 2>/dev/null || true)" = ${escapeShellArg expectedShowRecents} ]''
          ''[ "$(/usr/bin/defaults read com.apple.dock tilesize 2>/dev/null || true)" = ${escapeShellArg (toString cfg.tilesize)} ]''
        ];
        writeDockSettings = ''
          /usr/bin/defaults write com.apple.dock autohide -bool ${boolToString cfg.autohide}
          /usr/bin/defaults write com.apple.dock orientation -string ${escapeShellArg cfg.orientation}
          /usr/bin/defaults write com.apple.dock show-recents -bool ${boolToString cfg.showRecents}
          /usr/bin/defaults write com.apple.dock tilesize -int ${toString cfg.tilesize}
        '';
        # Build regular entries in one dockutil process so it persists the
        # complete layout before restarting Dock.
        createRegularEntries =
          "${dockutil}/bin/dockutil --remove all"
          + concatMapStrings
          (entry: " --add ${escapeShellArg entry.path}")
          regularEntries
          + optionalString (folderSettings != null) (
            " --view ${escapeShellArg folderSettings.view}"
            + " --display ${escapeShellArg folderSettings.display}"
            + " --sort ${escapeShellArg folderSettings.sort}"
          )
          + optionalString (spacerEntries != []) " --no-restart";
        createSpacerEntries =
          concatMapStrings
          (
            entry: "${dockutil}/bin/dockutil --add '' --type ${escapeShellArg entry.type} --section ${escapeShellArg entry.section}\n"
          )
          spacerEntries;
      in {
        assertions = [
          {
            assertion = folderSettings == null || all matchingFolderSettings folderEntries;
            message = "All local.dock folder entries must use the same view, display, and sort settings.";
          }
        ];

        home.activation.dockPersistent = lib.hm.dag.entryAfter ["writeBoundary"] ''
          echo >&2 "Setting up the Dock..."
          # Recent applications are dynamic and are not part of the declared layout.
          haveURIs="$(${dockutil}/bin/dockutil --list | ${pkgs.gawk}/bin/awk -F '\t' '$3 == "persistentApps" || $3 == "persistentOthers" { print $2 }')"
          if ! diff -wu <(echo -n "$haveURIs") <(echo -n '${wantURIs}') >&2 || ! ( ${dockSettingsMatch} ); then
            echo >&2 "Resetting Dock."
            # Write preferences first; dockutil performs the final Dock restart.
            ${writeDockSettings}
            ${createRegularEntries}
            ${createSpacerEntries}
          else
            echo >&2 "Dock setup complete."
          fi
        '';
      }
    );
}
