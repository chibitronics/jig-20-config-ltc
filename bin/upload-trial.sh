#!/bin/sh
tries=1
while sudo ./program-os-pvt1c.sh
do

	if sudo ./02-upload-program.sh
	then
		echo "Upload succeeded (${tries})"
		tries=$((${tries} + 1))
	else
		break
	fi
done
echo "Upload failed after ${tries} tries"
