{ pkgs, ... }:

pkgs.writeShellScriptBin "cpu-temp" ''
  temp=$(sensors | grep 'Package id 0:' | awk '{print $4}' | tr -d '+°C')
  temp=''${temp%.*}
  echo $temp
''
