create_user "avf" "Automatically created AVF user for Anchor Virtual Fleet"

grant_full_sudo "avf"
        
mkdir -p "${TARGET}/home/avf/.ssh"
        
# Do this in the chroot so we've got the UID/name mapping available
run_in_target chown -R avf:avf /home/avf/.ssh
        
# Don't require a TTY to sudo
sed -i '/^Defaults.*requiretty/d' ${TARGET}/etc/sudoers

echo "avf ALL=(ALL) NOPASSWD: ALL" >"${TARGET}/etc/sudoers.d/99_avf"

sed -i "s/^PermitRootLogin yes/PermitRootLogin no/" ${TARGET}/etc/ssh/sshd_config
