#!/bin/sh
count=0
while ./get-key.sh
do
	count=$((${count} + 1))
done
echo "Processed ${count} URLs"
