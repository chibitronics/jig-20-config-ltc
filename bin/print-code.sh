#!/bin/sh

width_max=696
height_max=271
initial_pixel_size=10
tmpfile=file.png
tmppath=/tmp/

main() {
	local url="$1"
	local size=${initial_pixel_size}
	while true
	do
		qrencode \
			-s ${size} \
			-o "${tmppath}qr-${tmpfile}" \
			"${url}"

		output_size=$(gm identify "${tmppath}qr-${tmpfile}" | awk '{print $3}' | cut -d+ -f1)
		width=$(echo ${output_size} | cut -dx -f1)
		height=$(echo ${output_size} | cut -dx -f2)

		if [ ${width} -le ${width_max} ] && [ ${height} -le ${height_max} ]
		then
			break
		fi
		size=$((${size}-1))
	done
	echo "Final pixel size: ${size}  Image size: ${output_size}"

	if [ ${width_max} -le ${height_max} ]
	then
		gm convert "${tmppath}qr-${tmpfile}" -extent ${width_max}x "${tmppath}gm-${tmpfile}"
	else
		gm convert "${tmppath}qr-${tmpfile}" -extent x${height_max} "${tmppath}gm-${tmpfile}"
	fi
	gm convert \
		"${tmppath}gm-${tmpfile}" \
		-gravity West \
		-extent "${width_max}x${height_max}" \
		-pointsize 56 \
		-draw "text ${width},-40 \"Bitmark\"" \
		-draw "text ${width},40 \"serial number\"" \
		"${tmppath}fl-${tmpfile}"

	brother_ql_create \
		--model QL-570 \
		--label-size 62x29 \
		"${tmppath}fl-${tmpfile}" \
		> output.bin
}

main 'https://chibitronics.com/love-to-code-signup/'
