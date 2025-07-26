#!/bin/bash

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

projectfolder=$(dirname "$0")
pkgName="<PKG_NAME>" ##Edit Here
version="<VERSION>" ##Edit Here
identifier="com.cantscript.${pkgName}"
install_location="/"
currentUser="$(stat -f "%Su" /dev/console)"
signId="<SIGNID>" #Edit Here - Optional, only required if signing pkg


##Set correct permissions for finishedScript before packaging
##Edit location and name if not using the suggested
finishScript="${projectfolder}/payload/Library/Application Support/JamfSetupManger/finishedScript.sh"

chown root:wheel "$finishScript"
chmod 755 "$finishScript"
xattr -d com.apple.quarantine "$finishScript" 2>dev/null


componentPackage(){
	pkgbuild --root "${projectfolder}/payload" \
	--identifier "${identifier}" \
	--version "${version}" \
	--install-location "${install_location}" \
	"${projectfolder}/${pkgName}-${version}.pkg"
}

componentPackageSigned(){
	pkgbuild --root "${projectfolder}/payload" \
	--identifier "${identifier}" \
	--version "${version}" \
	--install-location "${install_location}" \
	--sign ${signId} \
	"${projectfolder}/${pkgName}-${version}.pkg"
}

convertToDistribution(){
	productbuild --identifier "${identifier}" \
	--version "${version}" \
	--package "${projectfolder}/${pkgName}-${version}.pkg" \
	"/Users/$currentUser/Desktop/${pkgName}-${version}.pkg"
}

convertToDistributionSigned(){
	productbuild --identifier "${identifier}" \
	--version "${version}" \
	--package "${projectfolder}/${pkgName}-${version}.pkg" \
	--sign ${signId} \
	"/Users/$currentUser/Desktop/${pkgName}-${version}.pkg"
}


##Create pkg without signing (comment the below lines if you want to sign the pkg)
componentPackage 
convertToDistribution 

##Create pkg with signing (uncomment to use)
#componentPackageSigned 
#convertToDistributionSigned 


rm "${projectfolder}/${pkgName}-${version}.pkg"
