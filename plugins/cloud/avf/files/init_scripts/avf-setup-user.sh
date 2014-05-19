#!/bin/bash
### BEGIN INIT INFO
# Provides:       avf-setup-user
# Required-Start: $network
# Required-Stop:  
# Should-Start:   
# Should-Stop:    
# Default-Start:  S
# Default-Stop:   
# Description:    Retrieve SSH user keys and seed the avf user's authorized_keys
### END INIT INFO

if grep -q avfdebug /proc/cmdline; then
        set -x
        trap "sleep 10" EXIT
fi

MDS="http://[fc0f::fee]/server-metadata/"

mds() {
        wget -qO - $MDS/$1
}

log() {
        local p="$(basename $0)"
        
        logger -t $p "$@"
}

ssh_dir="/home/avf/.ssh"
authorized_keys="$ssh_dir/authorized_keys"

# We don't want to do anything if the avf user has been removed
if ! getent passwd avf >/dev/null; then
        exit 0
fi

# We don't want to setup any keys if the user has SSH keys already
if [ -e "$authorized_keys" ]; then
        exit 0
fi

# OK, time to do our thing

if [ ! -d "$ssh_dir" ]; then
        # Need to make absolutely sure this is a directory
        rm -rf "$ssh_dir"
        mkdir -p "$ssh_dir" -m 0700
        chown avf:avf "$ssh_dir"
fi

pklist="$(mds public_keys)"

for pk in $pklist; do
        mds "public_keys/$pk/openssh-key" >> "$authorized_keys"
        log "Added public key $pk to avf account"
done
