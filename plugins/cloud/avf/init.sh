cloud_avf_usage() {
	usage_section "avf box"
	
	usage_description "This plugin builds a raw image suitable for
	                  use with the Anchor Virtual Fleet - AVF."
}

register_usage "cloud_avf_usage"
	
load_plugin_or_die "misc/raw-image-file"
load_plugin_or_die "package/grub"
load_plugin_or_die "package/lvm2"
load_plugin_or_die "package/kpartx"
load_plugin_or_die "package/sshd"
load_plugin_or_die "package/sudo"
load_plugin_or_die "package/puppet"
load_plugin_or_die "package/openssh"
load_plugin_or_die "partitioner/with-lvm"
load_plugin_or_die "misc/ext4-filesystem-ext3-bootpartition"
