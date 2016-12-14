#!/bin/sh

# example client up script for darwin
# will be executed when client is up

# all key value pairs in ShadowVPN config file will be passed to this script
# as environment variables, except password

# user-defined variables
local_tun_ip=10.7.0.2
remote_tun_ip=10.7.0.1
dns_server=8.8.8.8

# get current gateway
orig_gw=$(netstat -nr | grep --color=never '^default' | grep -v 'utun' | sed 's/default *\([0-9\.]*\) .*/\1/' | head -1)
route add -net $server $orig_gw

# configure IP address and MTU of VPN interface
ifconfig $intf $local_tun_ip $remote_tun_ip mtu $mtu netmask 255.255.255.0 up

# change routing table
echo changing default route
route add -net 128.0.0.0 $remote_tun_ip -netmask 128.0.0.0
route add -net 0.0.0.0 $remote_tun_ip -netmask 128.0.0.0
route add -net $remote_tun_ip $orig_gw -netmask 255.255.255.255
echo default route changed to $remote_tun_ip

# change dns server
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
    networksetup -setdnsservers $currentservice $dns_server
    echo "DNS has been seted to $dns_server"
else
    >&2 echo "Could not find current service"
    exit 1
fi

echo $0 done
