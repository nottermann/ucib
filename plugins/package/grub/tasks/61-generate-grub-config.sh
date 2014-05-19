if [ -x "${TARGET}/usr/sbin/update-grub" ]; then
	echo "update-grub is executable"

	### Here I tried to get a bit more debug information, and fool grub probe a bit as it had problems checking loop0p1 against the device map:

	#sed -i "s/\/bin\/sh/\/bin\/sh -x/g" "${TARGET}/usr/sbin/grub-mkconfig"
	#mv "${TARGET}/usr/sbin/grub-probe" "${TARGET}/usr/sbin/grub-probe.orig"
	#curl edoceo.com/pub/grub-probe.sh > "${TARGET}/usr/sbin/grub-probe"
	#chmod 0755 "${TARGET}/usr/sbin/grub-probe"

	run_in_target "/usr/sbin/update-grub"
else
	if ! [ -e "${TARGET}/etc/grub.conf" ]; then
		ln -s "/boot/grub/grub.conf" "${TARGET}/etc/grub.conf"
	fi
	
	if ! [ -e "${TARGET}/boot/grub/menu.lst" ]; then
		ln -s "/boot/grub/grub.conf" "${TARGET}/boot/grub/menu.lst"
	fi
	
	if ! [ -e "${TARGET}/boot/grub/grub.conf" ]; then
		kernel="$(basename $(ls "${TARGET}/boot/"vmlinuz*))"
		if [ -z "$kernel" ]; then
			fatal "No kernel found"
		fi
		
		initrd="$(basename $(ls "${TARGET}/boot/"init*img*))"
		if [ -z "$initrd" ]; then
			fatal "No initrd found"
		fi
		echo "writing into grub.conf directly instead"	
		cat <<EOF >"${TARGET}/boot/grub/grub.conf"
default=0
timeout=1
title Linux
	root (hd0,0)
	kernel /boot/$kernel ro root=/dev/vda1
	initrd /boot/$initrd
EOF
	fi
fi

	
