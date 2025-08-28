{pkgs, ...}: {
  programs.yazi = {
    enable = true;
    package = pkgs.yazi.override {
      _7zz = pkgs._7zz-rar; # Support for RAR extraction
    };
    enableZshIntegration = true;
    # press q to quit, CWD changed to the current directory
    # press Q to quit, CWD is not changed
    shellWrapperName = "y";
    plugins = {mediainfo = pkgs.yaziPlugins.mediainfo;};

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
    '';

    settings = {
      mgr = {
        linemode = "size_and_mtime";
        show_hidden = true;
        sort_by = "mtime";
        sort_dir_first = true;
        sort_reverse = true;
      };
    };

    keymap.mgr.prepend_keymap = [
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
  home.packages = with pkgs; [
    exiftool
  ];
}
