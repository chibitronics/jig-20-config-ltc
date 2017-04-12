#!/bin/sh -e

source ./00-test-lib.sh
reset_board
wait_for_banner

echo "RGB LED tests:"
echo w > ${uart}

# Wait for the board to enter RGB test mode
grep -q "RGB LED test" ${uart}

error_msg=""
for color in r g b REx GEx BEx
do
	# Send the color name to the UART, selecting it.
	echo ${color} | cut -c 1 > ${uart}
	echo "    ${color}"
	if ! pulse_count rgb 128
	then
		echo "        Pulse out of range: ${range_val}"
		error_msg="${error_msg} ${color}:${range_diff}"
		error_count=$((${error_count} + 1))
#	else
#		echo "        Pulse is in range: ${range_val}"
	fi
done

if ! [ -z "${error_msg}" ]
then
	echo "RGB: ${error_msg}"
	exit ${error_count}
fi

echo "RGB LED Okay"
exit 0
