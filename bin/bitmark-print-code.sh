#!/bin/sh

tmppath=/tmp/
inpath=/disk/jig-20-config-ltc/bm
outpath=/disk/jig-20-config-ltc/coupons

main() {
	mkdir -p "${outpath}"
	srcfile=$(ls -1 ${inpath} | head -1)
	mv "${inpath}/${srcfile}" "${tmppath}/${srcfile}"
	brother_ql_create \
		--model QL-570 \
		--label-size 29 \
		"${tmppath}/${srcfile}" \
		> "${tmppath}brother-code.bin"
	mv "${tmppath}/${srcfile}" "${outpath}/${srcfile}"

	sudo dd if="${tmppath}brother-code.bin" of=/dev/usb/lp0
}

main
