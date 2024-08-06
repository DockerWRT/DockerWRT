#!/bin/sh

[ "$(uci -q get system.@system[0].ttylogin)" = 1 ] || exec /bin/ash --login
trap '' INT TSTP QUIT
exec /bin/login
