#!/bin/sh
tries=1
sudo /bin/sh -c 'source ./00-test-lib.sh; reset_board'
while true
do
	sudo ./01-test-setup.sh
	if sudo timeout 15 ./05-led-test.sh
	then
		echo "PWM succeeded (${tries})"
		tries=$((${tries} + 1))
	else
		sudo ./99-test-teardown.sh 2> /dev/null
		break
	fi
	sudo ./99-test-teardown.sh 2> /dev/null
done
echo "PWM failed after ${tries} tries"
