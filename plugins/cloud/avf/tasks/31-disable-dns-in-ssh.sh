if [ -e "${TARGET}/etc/ssh/sshd_config" ]; then
	echo "UseDNS no" >> "${TARGET}/etc/ssh/sshd_config"
fi
