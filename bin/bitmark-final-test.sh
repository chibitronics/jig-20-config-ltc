#!/bin/sh
if [ ! -e /dev/usb/lp0 ]
then
	exit
fi
./bitmark-print-code.sh
