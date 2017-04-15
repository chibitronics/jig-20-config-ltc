#!/bin/sh
uart=/dev/ttyAMA0
baud=9600

stty -F ${uart} ${baud} -icrnl -imaxbel -opost -onlcr -isig -icanon -echo

echo "HELLO bash-chibiscreen-logger 1.0"
while read line
do
	if echo "${line}" | grep -iq '^start'
	then
		# On start, issue a 'SYN' to clear the screen
		echo '#SYN' > ${uart}
		echo 'Running...' > ${uart}
	elif echo "${line}" | grep -iq '^hello'
	then
		echo '#SYN' > ${uart}
		echo -n "Jig: " > ${uart}
		echo "${line}" | awk '{ sub(/([^ ]+ +){1}/,"") }1' > ${uart}
	elif echo "${line}" | grep -iq '^fail'
	then
		# awk command from http://stackoverflow.com/questions/2626274/print-all-but-the-first-three-columns
		echo "${line}" | awk '{ sub(/([^ ]+ +){2}/,"") }1' > ${uart}
        elif echo "${line}" | grep -iq '^finish'
        then
                result=$(echo ${line} | awk '{print $3}')
                if [ ${result} -ge 200 -a ${result} -lt 300 ]
                then
                        echo 'Pass' > ${uart}
                fi

	elif echo "${line}" | grep -iq '^exit'
	then
		exit 0
	fi
done
