#!/bin/sh

# example client down script for darwin
# will be executed when client is down

# all key value pairs in ShadowVPN config file will be passed to this script
# as environment variables, except password

# user-defined variables
remote_tun_ip=10.7.0.1

# revert routing table
echo reverting default route
route delete -net 128.0.0.0 $remote_tun_ip -netmask 128.0.0.0
route delete -net 0.0.0.0 $remote_tun_ip -netmask 128.0.0.0
route delete -net $server

# revert dns server
services=$(networksetup -listnetworkserviceorder | grep 'Hardware Port')

while read line; do
    sname=$(echo $line | awk -F  "(, )|(: )|[)]" '{print $2}')
    sdev=$(echo $line | awk -F  "(, )|(: )|[)]" '{print $4}')
    # echo "Current service: $sname, $sdev, $currentservice"
    if [ -n "$sdev" ]; then
        ifconfig $sdev 2>/dev/null | grep 'status: active' > /dev/null 2>&1
        rc="$?"
        if [ "$rc" -eq 0 ]; then
            currentservice="$sname"
        fi
    fi
done <<< "$(echo "$services")"

if [ -n $currentservice ]; then
    echo "current service is $currentservice"
    networksetup -getdnsservers $currentservice
    networksetup -setdnsservers $currentservice empty
    echo "DNS has been revert"
else
    >&2 echo "Could not find current service"
    exit 1
fi

echo $0 done
