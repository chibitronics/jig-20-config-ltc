#!/bin/sh -e

source ./00-test-lib.sh

killall -CONT openocd 2> /dev/null

# Export all pins so that we can use them
for pin in ${all_pins}
do
	unexport_pin ${pin}
done
