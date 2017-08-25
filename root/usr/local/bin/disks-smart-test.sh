#!/bin/bash

# Script to run S.M.A.R.T test - It logs out the details and the status of the test

function runsmartctl {
	tail -n 10000 /var/log/$1-smart.log | sponge /var/log/$1-smart.log
	local output="$(/usr/sbin/smartctl -a $2 /dev/$1)"
	echo "$output" >> /var/log/$1-smart.log 2>&1
	if [[ $output == *"SMART overall-health self-assessment test result: PASSED"* ]]; then
		local result=0
	else
		local result=1
	fi

	echo $result
}

renice -n -19 -p $$ > /dev/null

tail -n 100 /var/log/smart-test-status.log | sponge /var/log/smart-test-status.log

result[0]=$(runsmartctl sdb)
result[1]=$(runsmartctl sda '-d sat')

for i in "${result[@]}"
do
	if [ "$i" -ne "0" ]; then
		echo "$(date) DISK SMART TEST: FAILED (arr: ${result[*]})" >> /var/log/smart-test-status.log
		exit 1
	fi
done

echo $(date) DISK SMART TEST: OK >> /var/log/smart-test-status.log
exit 0
