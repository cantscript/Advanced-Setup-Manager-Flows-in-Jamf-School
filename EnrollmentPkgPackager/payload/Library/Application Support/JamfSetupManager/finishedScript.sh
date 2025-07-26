#!/bin/bash

# Setup Manager Finished Script 

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# wait just a bit more for good measure
sleep 2


#Remove the JSM Script folder from the device
rm -rf /Library/Application\ Support/JamfSetupManager

