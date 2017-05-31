#!/bin/sh
max=5
for i in $(seq 1 5)
do
	echo "Programming OS (try ${i}/${max})"
	echo "reset" | ncat localhost 4444 > /dev/null
	echo "kinetis fcf_source write" | ncat localhost 4444 > /dev/null
	echo "halt" | ncat localhost 4444 > /dev/null
	if echo program $(pwd)/orchard-pvt1c.elf | ncat localhost 4444 | grep -q "Programming Finished" 2> /dev/null
	then
		echo "Programmed successfully"

		# Disable reset, so we can use it in future tests
		echo "reset_config none" | ncat localhost 4444 > /dev/null
		killall -STOP openocd
		exit 0
	fi
	echo "Failed to program.  Trying a mass_erase"

	# This sleep seems required, otherwise it will fail if called
	# immediately after a "program" has failed.
#	sleep .5
	echo "kinetis mdm mass_erase" | ncat localhost 4444 > /dev/null
#	echo "Failed to program."
done

echo "Failed to program OS after ${max} tries"
exit 1
