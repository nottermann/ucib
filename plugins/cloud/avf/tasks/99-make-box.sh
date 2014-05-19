#qemu-img convert -f raw -O qcow2 "$IMAGEFILE" "${WORKSPACE}/box.img"

mv "$IMAGEFILE" "/var/cache/box.img"
#bzip2 -q "${WORKSPACE}/box.img" >/dev/null 2>&1 

info "Your box is now available in '/var/cache/box.img.bz2'"

# Ask: Do you want to upload the raw image onto trove?

# If yes ; do vim ~/.s3cfg ; echo into there:
# host_base = beta.anchortrove.com
# host_bucket = %(bucket)s.beta.anchortrove.com
# if OS is wheezy: os-version = debian-7
# s3cmd put -P ${WORKSPACE}/box.imgi.bz2 s3://avfimages/linux-${os-version}-puppet-${date}-${revision}.img.bz2
