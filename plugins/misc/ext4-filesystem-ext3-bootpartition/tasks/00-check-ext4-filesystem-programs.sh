check_program_available "(mkfs.ext4 || true) |& grep 'Usage: mkfs.ext4'" "mkfs.ext4"
check_program_available "(mkfs.ext3 || true) |& grep 'Usage: mkfs.ext3'" "mkfs.ext3"
