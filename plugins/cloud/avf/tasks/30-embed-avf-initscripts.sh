touch "${TARGET}"/etc/resize-partition-table-please

install_init_script "$(plugin_file cloud/avf init_scripts/avf-extend-pv.sh)"
install_init_script "$(plugin_file cloud/avf init_scripts/avf-configure-networking.sh)"
install_init_script "$(plugin_file cloud/avf init_scripts/avf-setup-user.sh)"
