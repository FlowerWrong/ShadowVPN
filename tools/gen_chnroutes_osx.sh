#!/bin/sh

path=$(dirname $0)

list=$(grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}" $path/chnroute.txt |\
    sed -e "s/^/route -n \$action -net /" -e "s/$/ \$suf/")

cat <<-EOH > $path/chnroutes_osx.sh
	#!/bin/sh

	if [ "\$1" = "down" -o "\$1" = "del" ]; then
	    action=delete
	else
	    action=add
	    suf="\$(netstat -nr | grep --color=never '^default' | grep -v 'utun' | sed 's/default *\([0-9\.]*\) .*/\1/' | head -1)"
	fi

dscacheutil -flushcache

	$list
EOH
