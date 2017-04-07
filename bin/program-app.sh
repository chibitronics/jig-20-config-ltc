#!/bin/sh
success=0
max=5
for i in $(seq 1 5)
do
	echo "Programming try ${i}/${max}..."
	echo "reset" | ncat localhost 4444 > /dev/null
	echo "halt" | ncat localhost 4444 > /dev/null
	if echo program $(pwd)/larson.elf | ncat localhost 4444 | grep -q "Programming Finished"
	then
		echo "Programmed successfully"
		exit 0
	fi
done

echo "Failed to program"
exit 1
