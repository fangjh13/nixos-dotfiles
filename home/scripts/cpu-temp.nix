{ pkgs, ... }:

pkgs.writeShellScriptBin "cpu-temp" ''
  # intel cpu
  temp=$(sensors | grep 'Package id 0:' | awk '{print $4}' | tr -d '+°C')
  # amd cpu
  if [ -z "$temp" ]; then
      temp=$(sensors | grep 'Tctl:' | awk '{print $2}' | tr -d '+°C')
  fi
  temp=''${temp%.*}
  echo $temp
''
