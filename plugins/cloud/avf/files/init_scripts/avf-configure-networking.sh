#!/bin/bash
### BEGIN INIT INFO
# Provides:       avf-configure-networking
# X-Start-Before: $network
# Required-Start: $local_fs
# Required-Stop:  
# Should-Start:   
# Should-Stop:    
# Default-Start:  S
# Default-Stop:   
# Description:    Configure any network interface that isn't already
### END INIT INFO

if grep -q avfdebug /proc/cmdline; then
        set -x
        trap "sleep 10" EXIT
fi

MDS="http://[fc0f::fee]/2013-09-14/"

mds() {
        wget -qO - $MDS/$1
}

log() {
        local p="$(basename $0)"
        
        logger -t $p "$@"
}

nicparam() {
        local nic="$1"
        local param="$2"
        
        mds network/interfaces/$nic/$param
}

ENI="/etc/network/interfaces"

# Tell IPv6 to accept our specific route RAs
log "Setting max prefix length to /64"
for i in /proc/sys/net/ipv6/conf/*; do
        echo 64 >$i/accept_ra_rt_info_max_plen
done

# We've got to activate all NICs, so that we can maximise our chances of
# talking to the MDS
for iface in $(ip li sh |egrep -o ' eth[0-9]+'); do
        log "Bringing up $iface"
        ip link set $iface up
done

# We'll wait a little while to see if we get a route, but not forever
i=0
while [ $i -lt 10 ]; do
        if ip -6 ro sh | grep -q '^fc0f::/64'; then
                log "Found route to MDS"
                break
        fi
        i=$(($i+1))
        sleep 1
done

if [ "$i" = "10" ]; then
        log "Failed to find route to MDS.  Giving up."
        exit 1
fi

# If we're here, we can talk to the MDS.  Excellent.

# Let's setup /etc/hostname if it doesn't already exist
if [ ! -e /etc/hostname ]; then
        mds network/hostname >/etc/hostname
        hostname -F /etc/hostname
        echo "127.0.1.1 $(cat /etc/hostname) $(hostname -s)" >>/etc/hosts
fi

# A resolv.conf is always useful
if [ ! -e /etc/resolv.conf ]; then
        echo "domain $(cat /etc/hostname | sed 's/^[^.]*\.//')" >/etc/resolv.conf
        for ns in $(mds network/resolvers); do
                echo "nameserver $ns" >>/etc/resolv.conf
        done
fi

# Everything from here is only necessary if we don't have an
# /etc/network/interfaces file
if [ -e /etc/network/interfaces ]; then
        exit 0
fi

# Set up loopback reguardless of mds results
cat <<-EOF >>$ENI
auto lo
iface lo inet loopback

EOF

# Hokay, what NICs have we got?
niclist="$(mds network/interfaces | sed 's%/$%%')"

for nic in $niclist; do
        if grep -q "^iface $nic" $ENI; then
                # This NIC is already configured... cool
                continue
        fi

        log "Configuring $nic"
                
        ip4="$(nicparam $nic ip4)"
        ip6="$(nicparam $nic ip6)"
        gw="$(nicparam $nic gateway)"
        
        if [ -n "$ip4" ]; then
                cat <<-EOF >>$ENI
auto $nic
iface $nic inet static
        address $ip4
        netmask $(nicparam $nic netmask)
EOF
        elif [ -n "$ip6" ]; then
                cat <<-EOF >>$ENI
auto $nic
iface $nic inet6 static
        address $ip6
        netmask $(nicparam $nic masklen)
EOF
        fi
        
        if [ -n "$gw" ]; then
                echo "  gateway $gw" >>$ENI
        fi
done

