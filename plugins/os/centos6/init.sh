os_centos6_plugin_usage() {
	usage_section "CentOS 6"
	
	usage_description "This plugin installs a minimal CentOS 6.x."
	
	usage_option "--arch <arch>" \
	             "The architecture to build for."      \
	             "(Default: amd64)"                    \
	             "Valid values are 'i386' or 'amd64'." \
	
	usage_option "--mirror <url>" \
	             "The site from which packages will be fetched." \
	             "If not specified, a sane default will be used."
	
	usage_option "--proxy <url>" \
	             "Use the given URL as an HTTP proxy."
}

register_usage "os_centos6_plugin_usage"

parseopt "arch" "true" "amd64"
parseopt "mirror" "true"
parseopt "proxy" "true"

if optval proxy >/dev/null; then
	export http_proxy="$(optval proxy)"
fi

install_packages_in_target() {
	run_in_target yum install -y "$@" | spin "Installing $*"
}

create_user() {
	local user="$1"
	local gecos="${2:-$user}"
	local pw="$3"

	run_in_target useradd --comment "$gecos" \
	        --shell /bin/bash "$user" >/dev/null 2>&1

	if [ -n "$pw" ]; then
		echo "$user:$pw" | run_in_target chpasswd
	fi
}

dhcp_interface() {
	local if="$1"

	cat <<EOF >>"${TARGET}/etc/sysconfig/network-scripts/ifcfg-$if"
DEVICE="$if"
ONBOOT="yes"
BOOTPROTO="dhcp"
EOF

	touch "${TARGET}/etc/sysconfig/network"
	
	if grep -q ^NETWORKING= "${TARGET}/etc/sysconfig/network"; then
		sed -i "s/^NETWORKING=.*$/NETWORKING=\"yes\"/" "${TARGET}/etc/sysconfig/network"
	else
		echo "NETWORKING=\"yes\"" >>"${TARGET}/etc/sysconfig/network"
	fi
}

disable_consoles() {
	local keep1="$1"

	if [ -n "$keep1" ]; then
		sed -i 's%^ACTIVE_CONSOLES=.*$%/ACTIVE_CONSOLES=/dev/tty1%' "${TARGET}/etc/inittab"
	else
		sed -i 's/^ACTIVE_CONSOLES=.*$/ACTIVE_CONSOLES=/' "${TARGET}/etc/inittab"
	fi
}		

install_init_script() {
	local file="$1"

	debug "Installing '$file' as an init script"
	cp "$file" "${TARGET}/etc/init.d/"
	chmod 0755 "${TARGET}/etc/init.d/$(basename "$file")"
	run_in_target chkconfig --add "$(basename "$file")" >/dev/null
}

install_package_containing() {
	for file in "$@"; do
		debug "Looking for a package that provides $file"
		if ! run_in_target yum whatprovides "$file" | grep -iq "^No Matches found"; then
			install_packages_in_target "$file"
			return 0
		fi
	done
	
	debug "No package found for any of: $*"
	return 1
}

install_kernel() {
	install_packages_in_target "kernel"
}
	
set_hostname() {
	touch "${TARGET}/etc/sysconfig/network"
	
	if grep -q ^HOSTNAME= "${TARGET}/etc/sysconfig/network"; then
		sed -i "s/^HOSTNAME=.*$/HOSTNAME=\"$1\"/" "${TARGET}/etc/sysconfig/network"
	else
		echo "HOSTNAME=\"$1\"" >>"${TARGET}/etc/sysconfig/network"
	fi
}

set_password() {
	echo "$1:$2" | run_in_target chpasswd
}

grant_full_sudo() {
	echo "$1 ALL=(ALL) NOPASSWD: ALL" >>"${TARGET}/etc/sudoers"
}
