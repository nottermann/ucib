sfdisk -f -u S "$BLOCK_DEVICE" <<EOF >/dev/null 2>&1
2048,,83
EOF

declare -A PARTITIONS

PARTITIONS[/]="${BLOCK_DEVICE}p1"

#debug:
echo "partitions an der stelle array ist: $PARTITIONS[@]"
echo "partitions an der stelle stern ist: $PARTITIONS[*]"

for part in "${!PARTITIONS[@]}"; do
	echo "part ist: $part"
        echo ${PARTITIONS[$part]} 
done
