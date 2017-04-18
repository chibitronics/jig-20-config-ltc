#!/bin/sh
if [ ! -e /dev/usb/lp0 ]
then
	exit
fi
./bitmark-get-key.sh | ./bitmark-print-code.sh
