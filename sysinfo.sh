#!/bin/bash
case $1 in
	hd) df -h / | awk 'NR == 2 { gsub("G", ""); gsub("\\.0", ""); print $3 "/" $2 }' ;;
	uptime) uptime | sed "s/.* up \([^,]*\).*/\1/;s/  / /;s/ days,/d/" ;;
	procs) ps axe --no-headers | wc -l ;;
	mem) free -m | awk 'NR==2 { print $3 "/" $2}' ;;
	load) uptime | sed 's/.*load average: //;s/,//g' ;;
esac
