#!/bin/bash

##Script requires macOS 15+
##Older macOS can run script but requires jq to be installed

#API details for Jamf School
schoolInstance="<INSTANCENAME>"
apiNetwork=123409876
apiKey=qwerty0987
#Create API Auth
base64Key=$(echo -n "$apiNetwork:$apiKey" | base64 )

#Find UDID of device
udid=$(system_profiler SPHardwareDataType | awk '/Hardware UUID/ {print $3}')

###############

# Functions 

###############

getUserAssignment() {
	# Logic to enable script to work in both standard and debug modes
	local prodLoc="/private/var/db/SetupManagerUserData.txt"
	local debugLoc=""
	local file
	
	# Check which file exists
	if [[ -f "$prodLoc" ]]; then
		file="$prodLoc"
	elif [[ -f "$debugLoc" ]]; then
		file="$debugLoc"
	else
		#Throw error if file not found
		echo "Error: SetupManagerUserData.txt not found in expected locations." >&2
		return 1
	fi
	
	# Extract realname value
	local userAssignment
	userAssignment=$(awk -F': ' '/^realname:/ {print $2}' "$file")
	echo "$userAssignment" #Return realname value from file
}

getUserId() {
	local inputUser="$1"  # Accepts the username as an argument
	
	# Fetch the users from the API
	local getUsers=$(curl -s -X GET https://"$schoolInstance".jamfcloud.com/api/users -H "Authorization: Basic $base64Key")
	
	# Extract user ID using jq
	local userId=$(echo "$getUsers" | jq --arg name "$inputUser" -r '.users[] | select(.name == $name) | .id')
	
	#Check to see if userID is found, if not assume user was not found in Jamf School
	#and throw error
	if [[ -z "$userId" ]]; then
		echo "Error: $inputUser not found in Jamf School." >&2
		return 1
	fi

	echo "$userId"  # Return userId from API Call
}


assignAUser() {
	curl -X PUT https://"$schoolInstance".jamfcloud.com/api/devices/"$udid"/owner \
	-H "Authorization: Basic $base64Key" \
	-H "content-type: application/json" \
	-d "{ \"user\": \"$assignedUserId\" }"
}
		
updateDeviceDetails() {
	curl -X POST https://"$schoolInstance".jamfcloud.com/api/devices/"$udid"/refresh \
	-H "Authorization: Basic $base64Key" 
}

updateAssetTag() {
	curl -X POST https://"$schoolInstance".jamfcloud.com/api/devices/"$udid"/details \
	-H "Authorization: Basic $base64Key" \
	-H "content-type: application/json" \
	-d "{ \"assetTag\": \"User Details Entered\" }"
}
		
############
		
# Logic
	
############

#Read User input from file
userAssignment=$(getUserAssignment)
if [[ $? -ne 0 ]]; then
	exit 1 #Exit if SetupManagerUserData.txt file isn't available
fi

#Obtain Jamf School User ID for the inputed user
assignedUserId=$(getUserId "$userAssignment")
if [[ $? -ne 0 ]]; then
	exit 1 #Exit if user ID is not returned in API call
fi

#Sanity check of details
echo "$userAssignment User ID: $assignedUserId"

#Chill for a second and then API call to assign user to device
sleep 2
assignAUser
#Chill for a second and API call to refresh the device details so that user
#assignment is updated in device record
sleep 2
updateDeviceDetails
#Chill for a little longer and then API call to assign AssetTag which is used
#as a trigger to install Jamf Connect User Details profile
sleep 5
updateAssetTag