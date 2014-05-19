sfdisk -f -u S "$IMAGEFILE" <<EOF >/dev/null 2>&1
2048,524288,83
526336,,8e
EOF
