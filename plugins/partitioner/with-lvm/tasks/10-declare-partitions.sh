#sfdisk -f -u S "$BLOCK_DEVICE" <<EOF >/dev/null 2>&1
#2048,524288,83
#526336,,8e
#EOF

declare -A PARTITIONS

PARTITIONS[/boot]="${BLOCK_DEVICE}p1"
PARTITIONS[/]="${BLOCK_DEVICE}p2"

#debug
echo "partitions an der stelle array ist: ${!PARTITIONS[@]}"
echo "partitions an der stelle stern ist: ${!PARTITIONS[*]}"

for part in "${!PARTITIONS[@]}"; do
	echo ${PARTITIONS[$part]} 
done
