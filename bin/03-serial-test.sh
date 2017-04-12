#!/bin/sh -e
max=3

source ./00-test-lib.sh

for i in $(seq 1 ${max})
do
	reset_board
	wait_for_banner

	# Check to see if serial is working.  Look for the string
	# 'LTC factory test is running', and echo back 'q'.
	echo "Serial test:"
	echo "    Sending"
	echo u > ${uart}
	echo "    Receiving"
	if timeout 3 grep -q "serial test" ${uart}
	then
		echo q > ${uart}
		echo "Serial OK"
		exit 0
	fi
	echo "Timed out, trying again..."
done

echo "Failed to talk to serial port."
exit 1
