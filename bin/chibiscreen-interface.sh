#!/bin/sh
uart=/dev/ttyAMA0
baud=9600
reset_pulse=23
mode=stopped

stty -F ${uart} ${baud} -icrnl -imaxbel -opost -onlcr -isig -icanon -echo

clear_screen_process() {
	gpio -g mode ${reset_pulse} down
	while true
	do
		gpio -g wfi ${reset_pulse} rising
		if [ -e /tmp/test-running ]
		then
			continue
		fi
		echo '#SYN' > ${uart}
		echo 'Ready.' > ${uart}
	done
}

clear_screen_process &

rmdir /tmp/test-running 2> /dev/null
echo "HELLO bash-chibiscreen-logger 1.0"
while read line
do
	if echo "${line}" | grep -iq '^start'
	then
		# On start, issue a 'SYN' to clear the screen
		echo '#SYN' > ${uart}
		echo 'Running...' > ${uart}
		mkdir /tmp/test-running
	elif echo "${line}" | grep -iq '^hello'
	then
		echo '#SYN' > ${uart}
		echo "${line}" | awk '{ sub(/([^ ]+ +){1}/,"") }1' > ${uart}
		echo "Ready to test" > ${uart}
		rmdir /tmp/test-running
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
		else
                        echo 'Fail' > ${uart}
                fi
		rmdir /tmp/test-running
	elif echo "${line}" | grep -iq '^exit'
	then
		rmdir /tmp/test-running
		exit 0
	fi
done
