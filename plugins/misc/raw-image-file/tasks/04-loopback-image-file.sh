cleanup_loopback_image_file() {
	losetup -d "$BLOCK_DEVICE"
}

register_cleanup "cleanup_loopback_image_file"

BLOCK_DEVICE="$(losetup --show -f "$IMAGEFILE")"

if ! [ -b "$BLOCK_DEVICE" ]; then
	fatal "Block device '$BLOCK_DEVICE' is not available... WTF?"
fi
