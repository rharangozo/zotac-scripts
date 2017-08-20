#!/bin/bash

# Check disk space !

diskspacehigh=`df -k |awk '{print $5}' | egrep "1?[8-9][0-9]" | cut -c-2| wc -l`
if [ "$diskspacehigh" -gt "0" ]; then
	echo "Not enough disk space !"
	exit 1
fi

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!!!!!!!!!!!!TEMPORARY DISABLED !!!!!!!!!!!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# Check the age of the most recent snapshot

#mostRecentSnapshotAge=$(($(date +%s) - $(date +%s -r "/media/zotac/SAMSUNG/rsnapshot/daily.0")))
#if [ "$mostRecentSnapshotAge" -gt "172800" ]; then
#	echo "Most recent snapshot is older than 2 days!!!"
#	exit 1
#fi

#
# Check the age of the last image sync
#

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!!!!!!!!!!!!TEMPORARY DISABLED !!!!!!!!!!!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#lastSuccessfulSync=$(tail -n 1 /var/log/image-backup.log |grep succesful | cut -d' ' -f1-7)
#if [ -z "$lastSuccessfulSync" ]; then
#	echo "FAILING image backup!"
#	exit 1;
#fi
lastSuccessfulSyncAge=$(($(date +%s) - $(date +%s --date="$lastSuccessfulSync")))
if [ "$lastSuccessfulSyncAge" -gt "172800" ]; then
	echo "Last successful image sync is older than 2 days!!!"
	exit 1
fi

#
# Check the age of the disk health resports and status
#

lastSuccessfulReport=$(tail -n 1 /var/log/smart-test-status.log |grep OK | cut -d' ' -f1-6)
if [ -z "$lastSuccessfulReport" ]; then
	echo "FAILING disk test!"
	exit 1
fi
lastSuccessfulReportAge=$(($(date +%s) - $(date +%s --date="$lastSuccessfulReport")))
if [ "$lastSuccessfulSyncAge" -gt "86400" ]; then
        echo "Last successful disk test is older than 1 day!!!"
        exit 1
fi

exit 0
