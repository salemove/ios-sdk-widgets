SEMVER=$1
CHECKSUM=$2
BRANCH_NAME=$3

git checkout -b "$BRANCH_NAME"

# This script takes template file from templates/Package.swift
# and replaces next placeholders:
# - WIDGETS_SDK_SEMVER: actual value is passed in SEMVER;
# - WIDGETS_SDK_CHECKSUM: actual value is passed in CHECKSUM;
# - CORE_SDK_SEMVER: actual value is taken from GliaWidgets.podspec file;
# - CORE_SDK_CHECKSUM: actual value is taken from Package.swift file;
# Since templates/Package.swift file has placeholders for both CoreSDK and WidgetsSDK version
# we need to replace them all.

# Gets CoreSDK version from GliaWidgets.podspec file:
# - `grep` command searches for the line containing "GliaCoreSDK', '" string.
# - `awk` command splits `grep` output line into parts using "'" field separator (FS)
# and returns 4th object in the result array.
CORE_SDK_SEMVER=$(grep "GliaCoreSDK',\s*'" 'GliaWidgets.podspec' | awk -F"'" '{print $4}')

# Gets CoreSDK xcframework checksum from Package.swift file:
# - `awk` command searches for the line containing "GliaCoreSDK.xcframework.zip"
# and returns the next line. By some reason it also returns 3rd line 🤷‍♂️.
# - `grep` command searches in `awk` output for the line containing "checksum:".
# - `awk` command splits `grep` output line into parts using "'" field separator (FS)
# and returns 2nd object in the result array.
CORE_SDK_CHECKSUM=$(awk '/GliaCoreSDK.xcframework.zip/{p=NR} NR==p+1' 'Package.swift' | grep 'checksum:' | awk -F'"' '{print $2}')

# Replaces actual Package.swift file with template.
cp templates/Package.swift Package.swift

# `sed` command replaces placeholders in copied template file
# with actual values.
sed -i '' "s/\${CORE_SDK_SEMVER}/${CORE_SDK_SEMVER}/g" "Package.swift"
sed -i '' "s/\${CORE_SDK_CHECKSUM}/${CORE_SDK_CHECKSUM}/g" "Package.swift"
sed -i '' "s/\${WIDGETS_SDK_SEMVER}/${SEMVER}/g" "Package.swift"
sed -i '' "s/\${WIDGETS_SDK_CHECKSUM}/${CHECKSUM}/g" "Package.swift"

# Commits and pushes the changes.
git add .
git commit -m "Update Widgets SDK xcframework version"
git push origin "$BRANCH_NAME":"$BRANCH_NAME"
