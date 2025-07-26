# Advanced Setup Manager Flows in Jamf School


<p align="center">
<img width="512" alt="CantScript Logo" src="https://github.com/cantscript/AxM_API/blob/main/CantScript_Full_DotComV7.png">
</p>


Jamf Setup Manager powered up macOS deployment workflows for Jamf School but what happens when you power up the power up? In this blog, [Advanced Setup Manager Flows in Jamf School, Part 1]() we look at some advanced Setup Manager workflows aimed specifically at Jamf School


#### Blog Resources
**[EnrollmentPkgPackager]()** <br>

* Clone or download repo
* Keep EnrollmentPkgPackager.sh in the folder enclosed folder
* Add required scripts to `payload/Library/Application Support/JamfSetupManager`
* Run EnrollmentPkgPackager.sh, a resulting pkg will be saved to your desktop.
* EnrollmentPkgPackager script setting correct permissions for the `finishedScript.sh` prior to running the pack command
* There are a number of attributes that should be edited by an Admin to set the name and other attributes of the package
* Logic within the script to produce signed or unsigned pkg depending on your needs


**[Example Setup Manager Configuration Profile]()** <br>
Basic configuration profile for Setup Manager that shows 

- `enrolment actions` that call scripts from the `/Library/Application Support/JamfSetupManager` folder
- `finishedScript` key in the top level of the profile which will run a script once Setup Manager has completed

**Example Scripts** <br>

- [RefreshDetails.sh]() - A script that uses an API call to refresh the details of the device it runs on
- [finishedScript]() - The final script that is ran after Setup Manager completes and deletes the `/Library/Application Support/JamfSetupManager` folder