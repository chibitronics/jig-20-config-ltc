#!/bin/sh

# The three GND pins on the board are isolated behind a reverse voltage
# protection FET.  One failure mode is that the FET gets incorrectly
# placed on the board, causing the three GND pins to effectively "float".
#
# This test functions by probing two different spots on this GND plane.
# It sends out a low-current signal "high", and measures the other
# spot.  If the FET is properly installed, then this location will read 0.
# If, however, the Pi is able to drive this net high, then the FET is
# improperly installed.

# Set pins for Ground Test 1 and Ground Test 2
gt1=20
gt2=21
errors=0

setup() {
	gpio -g mode ${gt1} in
	gpio -g mode ${gt2} out
}

cleanup() {
	gpio -g mode ${gt1} in
	gpio -g mode ${gt2} in
}

trap cleanup EXIT
setup

echo "Testing RV FET"

# Drive the output low, and verify that the other end is 0.
# This should always be the case, but this is a sanity check.
gpio -g write ${gt2} 0
if [ "x$(gpio -g read ${gt1})" != "x0" ]
then
	echo "!! GT1 !lo"
	errors=1
else
	echo "OK GT2 lo"
fi

gpio -g write ${gt2} 1
if [ "x$(gpio -g read ${gt1})" != "x0" ]
then
	echo "!! GT1 hi!"
	errors=1
else
	echo "OK GT2 hi"
fi

exit ${errors}
