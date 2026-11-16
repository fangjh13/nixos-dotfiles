{pkgs, ...}: let
  zippity = pkgs.callPackage ./zippity.nix {};
  upstreamConfig = name: builtins.fromTOML (builtins.readFile "${zippity.src}/examples/${name}.toml");
in {
  programs.yazi = {
    enable = true;
    package = pkgs.yazi.override {
      _7zz = pkgs._7zz-rar; # Support for RAR extraction
    };
    enableZshIntegration = true;
    # press q to quit, CWD changed to the current directory
    # press Q to quit, CWD is not changed
    shellWrapperName = "y";
    extraPackages = with pkgs; [
      mediainfo
      exiftool
      ouch
      binutils-unwrapped
      coreutils
      glow
      zippity
    ];
    plugins = {
      inherit (pkgs.yaziPlugins) mediainfo ouch piper;
      zippity = "${zippity}/share/yazi/plugins/zippity.yazi";
    };
    vfs = upstreamConfig "vfs";

    initLua = ''
      function Linemode:size_and_mtime()
        local time = math.floor(self._file.cha.mtime or 0)
        if time == 0 then
          time = ""
        elseif os.date("%Y", time) == os.date("%Y") then
          time = os.date("%b %d %H:%M", time)
        else
          time = os.date("%b %d  %Y", time)
        end

        local size = self._file:size()
        return string.format("%s %s", size and ya.readable_size(size) or "-", time)
      end

      -- Display the target path of a symbolic link in real time to the right of the filename in the bottom status bar.
      Status:children_add(function(self)
        local hovered = self._current.hovered
        if hovered and hovered.link_to then
          return " -> " .. ui.printable(tostring(hovered.link_to))
        end
        return ""
      end, 3300, Status.LEFT)

      -- Add a display of the current file's User:Group ownership/permissions to the right side of the bottom status bar.
      Status:children_add(function(self)
        local hovered = self._current.hovered
        -- Archive members do not expose filesystem ownership metadata.
        if not hovered or ya.target_family() ~= "unix" or hovered.url.spec.scheme == "zippity" then
          return ""
        end

        local user = ya.user_name(hovered.cha.uid) or tostring(hovered.cha.uid)
        local group = ya.group_name(hovered.cha.gid) or tostring(hovered.cha.gid)
        return ui.Line {
          ui.Span(ui.printable(user .. ":" .. group)):fg("magenta"),
          " ",
        }
      end, 500, Status.RIGHT)
    '';

    settings = {
      mgr = {
        linemode = "size_and_mtime";
        show_hidden = true;
        sort_by = "mtime";
        sort_dir_first = true;
        sort_reverse = true;
      };
      plugin.prepend_fetchers = (upstreamConfig "yazi").plugin.prepend_fetchers;
      plugin.prepend_previewers =
        (upstreamConfig "yazi").plugin.prepend_previewers
        ++ [
          {
            mime = "application/{*zip,tar,bzip*,7z*,rar,xz,zstd,lzma,java-archive}";
            run = "ouch";
          }
          {
            mime = "application/{executable,pie-executable,sharedlib,object,x-executable,x-pie-executable,x-sharedlib,x-object}";
            run = ''piper -- readelf --wide --file-header --dynamic -- "$1" | fold --spaces --width="$w"'';
          }
          {
            url = "*.{md,MD,markdown,mdown,mkdn,mkd}";
            run = ''piper -- CLICOLOR_FORCE=1 glow --width="$w" --style=dark -- "$1"'';
          }
          {
            mime = "text/markdown";
            run = ''piper -- CLICOLOR_FORCE=1 glow --width="$w" --style=dark -- "$1"'';
          }
        ];
    };

    keymap.mgr.prepend_keymap =
      (upstreamConfig "keymap").mgr.prepend_keymap
      ++ [
        # quick access Go to
        {
          run = "cd ~";
          on = ["g" "h"];
          desc = "Go to home";
        }
        {
          run = "cd /tmp";
          on = ["g" "t"];
          desc = "Go to /tmp";
        }
        # compress selected files
        {
          on = ["c" "a"];
          run = ''
            shell 'ouch compress -- %s "archive-$(date -I).tar.gz"' --confirm
          '';
          desc = "Compress selected files to dated tar.gz";
        }
        # image processor
        {
          run = ''
            shell 'image-processor 80 "4096x4096>" 6 "$@"' --confirm
          '';
          on = ["e" "e"];
          desc = "Convert (4K, method 6, q80)";
        }
        {
          on = ["e" "q"];
          run = ''
            shell 'image-processor "" "4096x4096>" 6 "$@"' --confirm --block
          '';
          desc = "Convert - custom quality";
        }
        {
          on = ["e" "r"];
          run = ''
            shell 'image-processor 80 "" 6 "$@"' --block --confirm
          '';
          desc = "Convert - custom resolution";
        }
        {
          on = ["e" "x"];
          run = ''
            shell 'image-processor "" "" "" "$@"' --block --confirm
          '';
          desc = "Convert - all custom";
        }
      ];
  };
}
