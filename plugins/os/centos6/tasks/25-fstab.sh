cat <<EOF >"${TARGET}/etc/fstab"
/dev/vda1 / ext4 defaults 1 1
tmpfs   /dev/shm        tmpfs   defaults        0       0
devpts  /dev/pts        devpts  gid=5,mode=620  0       0
sysfs   /sys    sysfs   defaults        0       0
proc    /proc   proc    defaults        0       0
EOF