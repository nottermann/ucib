cleanup_refresh_partitions() {
        if [ -e /dev/avf-vg0 ]; then
               	vgchange -an avf-vg0
       	fi

	kpartx -d "$BLOCK_DEVICE"

	if [ -n "$BLOCK_DEVICE" ]; then
	     	losetup -d $BLOCK_DEVICE
	fi
}

register_cleanup "cleanup_refresh_partitions"

kpartx -a "$BLOCK_DEVICE"

# kpartx has a nasty habit of putting all its partitions under /dev/mapper,
# which, of course, the partitioner isn't expected to know.  So, we need to
# manually mangle the partition names to correspond to the kpartx-created
# names.
for partname in "${!PARTITIONS[@]}"; do
		debug "Converting $partname (${PARTITIONS[$partname]}) to kpartx-created device name"
		PARTITIONS[$partname]="/dev/mapper/$(basename "${PARTITIONS[$partname]}")"
done
