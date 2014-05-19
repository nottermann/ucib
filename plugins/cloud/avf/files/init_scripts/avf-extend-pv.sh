#!/bin/bash
### BEGIN INIT INFO
# Provides:       avf-extend-pv
# Required-Start: $local_fs
# Required-Stop:  
# Should-Start:   
# Should-Stop:    
# Default-Start:  S
# Default-Stop:   
# Description:    Make sure our PV is the whole size of the partition
### END INIT INFO

if grep -q avfdebug /proc/cmdline; then
        set -x
        trap "sleep 10" EXIT
fi

log() {
        local p="$(basename $0)"
        
        logger -t $p "$@"
}

# We really, *really* only want to do this on our first boot, because
# randomly mangling a partition table at startup is going to end so
# very, *very* badly sooner or later
if [ -f "/etc/resize-partition-table-please" ]; then
        log "Rewriting /dev/vda partition table for full capacity"
        sfdisk -f -u S /dev/vda <<EOF
2048,524288,83
526336,,8e
EOF
        rm -f /etc/resize-partition-table-please
fi

# We'll do this on every boot, because there's a good chance that after our
# first boot, the partition table change that sfdisk did above won't be
# visible
log "Running pvresize /dev/vda2"
log "$(pvresize /dev/vda2)"
