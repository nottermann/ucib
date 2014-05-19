debug "Loopback device for AVF image is $BLOCK_DEVICE"

#boot_device_path="/dev/mapper/$(basename "$BLOCK_DEVICE")p1"
#echo "boot device path ist: $boot_device_path"
#
#pv_device_path="/dev/mapper/$(basename "$BLOCK_DEVICE")p2"
#echo "pv device path ist: $pv_device_path"
#
#pvcreate "$pv_device_path"
#vgcreate avf-vg0 "$pv_device_path"

pvcreate "${PARTITIONS[/]}"
vgcreate avf-vg0 "${PARTITIONS[/]}"

lvcreate "-L$(( ${OPTS[image-size]} - 1 ))G" -n root avf-vg0

#device_path="/dev/avf-vg0/root"
PARTITIONS[/]="/dev/avf-vg0/root"
