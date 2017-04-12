#!/bin/sh -e

max=3
success=0
audiofile="$1"

source ./00-test-lib.sh

if [ -z "${audiofile}" ]
then
	echo "Usage: $0 [audiofile].wav" 1>&2
	exit 1
fi

echo "Audio test:"
for try in $(seq 1 ${max})
do
	echo "    Download mode (try ${try})"
	enter_programming_mode

	if get_value ${status_green} || ! get_value ${status_red}
	then
		if get_value ${status_green}
		then
			echo "        status_green is on when it should be off"
		fi
		if ! get_value ${status_red}
		then
			echo "        status_red is off when it should be on"
		fi
	else
		success=1
		break
	fi
done
if [ ${success} -eq 0 ]
then
	echo "        Unable to enter download mode after ${try} tries"
	exit 1
fi

echo "    Programming"
aplay -q "${audiofile}"

# Wait for status_green, which gets turned on
# as soon as the program starts running.
if ! get_value ${status_green} || get_value ${status_red}
then
	if ! get_value ${status_green}
	then
		echo "        status_green is off when it should be on"
	fi
	if get_value ${status_red}
	then
		echo "        status_red is on when it should be off"
	fi
	echo "        Program never loaded"
	exit 1
fi

echo "Program uploaded"
