#!/bin/sh -e

source ./00-test-lib.sh
reset_board
wait_for_banner

echo "Status LEDs:"

echo "    Green On"
wait_for_green_on
echo -n 'g' > ${uart}

echo "    Green Off"
wait_for_green_off
echo -n 'q' > ${uart}

echo "    Red Off"
wait_for_red_off
echo -n 'r' > ${uart}

echo "    Red On"
wait_for_red_on
echo -n 'q' > ${uart}
