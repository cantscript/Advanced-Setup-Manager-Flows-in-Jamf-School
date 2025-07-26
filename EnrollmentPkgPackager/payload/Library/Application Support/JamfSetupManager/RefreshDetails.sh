#!/bin/bash

#Find UDID of device
udid=$(system_profiler SPHardwareDataType | awk '/Hardware UUID/ {print $3}')

#API details for SchoolOverview 
schoolInstance="<INSTANCENAME>" ##Edit Here
apiNetwork=12335 #Edit Here
apiKey=qwerty0987 #Edit Here

base64Key=$(echo -n "$apiNetwork:$apiKey" | base64 )

#Optional addtional param available, directly after refresh
clearErrors="?clearErrors=true"

#Make the call
curl -X POST https://"$schoolInstance".jamfcloud.com/api/devices/"$udid"/refresh \
-H "Authorization: Basic $base64Key" \

sleep 5