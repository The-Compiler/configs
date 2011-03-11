#!/bin/bash
case $1 in
	hd) df -h | grep $(mount | grep "on / " | cut -d " " -f 1) | sed 's/[^ ]* *\([^ ]*\) *\([^ ]*\).*/\2\/\1/;s/G//g;s/\.0//g' ;;
	irc) netstat | grep -c ircd ;;
	hilights) tail -n 0 -f ~/.irssihilights ;;
	uptime) uptime | sed "s/.* up \([^,]*\),.*user.*/\1/;s/  / /;s/ days,/d/" ;;
	procs) ps axue | grep -vE "^USER|grep|ps" | wc -l ;;
	mem) free -m | head -n 2 | tail -n 1 | sed 's/[^ ]* *\([^ ]*\) *\([^ ]*\).*/\2\/\1/;s/G//g' ;;
	who) echo \($(whoami)\) $(who | cut -d " " -f 1 | sort | uniq | sed ':a;N;$!ba;s/\n/, /g') ;;
esac
exit 0
