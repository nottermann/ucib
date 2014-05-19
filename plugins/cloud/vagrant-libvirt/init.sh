cloud_vagrant_libvirt_usage() {
	usage_section "vagrant-libvirt box"
	
	usage_description "This plugin builds a 'Vagrant box' suitable for
	                  use with the vagrant-libvirt plugin."
}

register_usage "cloud_vagrant_libvirt_usage"
	
load_plugin_or_die "misc/raw-image-file"
load_plugin_or_die "package/grub"
load_plugin_or_die "package/sshd"
load_plugin_or_die "package/sudo"
load_plugin_or_die "partitioner/full-disk"
load_plugin_or_die "misc/ext4-filesystem"
