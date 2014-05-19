debug "Formatting filesystems."

for part in "${!PARTITIONS[@]}"; do
	echo "part ist: $part"
	if [ $part == "/boot" ]; then
		mkfs.ext3 "${PARTITIONS[$part]}" |& spin "Formatting '$part' filesystem"
		tune2fs -i 0 "${PARTITIONS[$part]}" >/dev/null 2>&1
		debug "Format /boot with ext3."
		continue
	fi
	if ! [[ "$part" =~ ^\/ ]]; then
		# Not a regular filesystem partition; leave it alone
		continue
	fi
	
	mkfs.ext4 -v "${PARTITIONS[$part]}" |& spin "Formatting '$part' filesystem"
	tune2fs -i 0 "${PARTITIONS[$part]}" >/dev/null 2>&1
	debug "Format / with ext4."
done
