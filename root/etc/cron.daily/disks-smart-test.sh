#!/bin/bash

# Script to run S.M.A.R.T test - It logs out the details and the status of the test

function runsmartctl {
	tail -n 10000 /var/log/$1-smart.log | sponge /var/log/$1-smart.log
	local output="$(smartctl -a $2 /dev/$1)"
	echo $output >> /var/log/$1-smart.log 2>&1
	local result="$(echo $output | grep 'SMART overall-health self-assessment test result: PASSED' | wc -l)"
	echo "$result"
}

tail -n 100 /var/log/smart-test-status.log | sponge /var/log/smart-test-status.log

result[0]=$(runsmartctl sdb)
result[1]=$(runsmartctl sda '-d sat')

for i in "${result[@]}"
do
	if [ "$i" -ne "1" ]; then
		echo $(date) DISK SMART TEST: FAILED >> /var/log/smart-test-status.log
		exit 1
	fi
done

echo $(date) DISK SMART TEST: OK >> /var/log/smart-test-status.log
exit 0
