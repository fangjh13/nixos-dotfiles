{pkgs}:
pkgs.writeShellScriptBin "memtop" ''
  sudo ps -e -o pid,user,pss,uss,rss,cmd | \
    awk 'NR>1 {cmd=$6; for(i=7;i<=NF;i++) cmd=cmd" "$i; printf "%-8s %-12s %-10s %-10s %-10s %s\n", $1, $2, $3, $4, $5, cmd}' | \
    sort -n -k3 | \
    awk 'BEGIN {printf "%-8s %-12s %-10s %-10s %-10s %s\n", "PID", "USER", "PSS(KB)", "USS(KB)", "RSS(KB)", "CMD"} {print}'
''
