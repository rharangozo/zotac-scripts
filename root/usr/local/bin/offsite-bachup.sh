#!/bin/bash

# Script to sync local directory with a remote S3 bucket

IMG_SRC=/media/zotac/se/safedrive/pictures
S3_IMG_BACKUP=s3://roland-image-backup

function sync {
	tail -n 20000 /var/log/$1-offsite-sync.log | sponge /var/log/$1-offsite-sync.log
	sudo su zotac -c "s3cmd sync -r $2 $3" >> /var/log/$1-offsite-sync.log 2>&1
	local result=$?
	echo $result
}

renice -n -19 -p $$ > /dev/null

tail -n 100 /var/log/offsite-sync-status.log | sponge /var/log/offsite-sync-status.log

result[0]=$(sync image $IMG_SRC $S3_IMG_BACKUP)

for i in ${result[@]}
do
	if [ "$i" -ne "0" ]; then
		echo "$(date) SYNC: FAILED (arg: ${result[@]})" >> /var/log/offsite-sync-status.log
		exit 1
	fi
done

echo "$(date) SYNC: OK" >> /var/log/offsite-sync-status.log
