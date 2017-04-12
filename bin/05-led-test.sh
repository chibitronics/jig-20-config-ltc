#!/bin/sh -e

source ./00-test-lib.sh
reset_board
wait_for_banner

set_input 0
set_input 1
set_input 2
set_input 3
set_input 4
set_input 5

echo "PWM LED tests:"
echo -n 'l' > ${uart}

grep -q "PWM LED test" ${uart}

error_msg=""
for pin in $(seq 0 5)
do
	echo "    Pin A${pin}"
	echo -n ${pin} > ${uart}
	if ! pulse_count ${pin} 256
	then
		echo "        Pulse out of range: ${range_val}"
		error_msg="${error_msg}  ${pin}:${range_diff}"
		error_count=$((${error_count} + 1))
#	else
#		echo "        Pulse is in range: ${range_val}"
	fi
done
echo -n q > ${uart}

if ! [ -z "${error_msg}" ]
then
	echo "LED: ${error_msg}"
	exit ${error_count}
fi

echo "All LEDs okay"
exit 0
