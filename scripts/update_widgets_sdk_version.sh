WIDGETS_SDK_SEMVER=$1

# This script takes template file from templates/GliaWidgets.podspec
# and replaces next placeholders:
# - WIDGETS_SDK_VERSION_SEMVER: actual value is passed in WIDGETS_SDK_SEMVER;
# - CORE_SDK_VERSION_SEMVER: actual value is taken from GliaWidgets.podspec file;
# Since templates/GliaWidgets.podspec file has placeholders for both CoreSDK and WidgetsSDK version
# we need to replace them all.

# Gets CoreSDK version from GliaWidgets.podspec file:
# - `grep` command searches for the line containing "GliaCoreSDK', '" string.
# - `awk` command splits `grep` output line into parts using "'" field separator (FS)
# and returns 4th object in the result array.
CORE_SDK_SEMVER=$(grep "GliaCoreSDK',\s*'" '../GliaWidgets.podspec' | awk -F"'" '{print $4}')

# Copy a new podspec file from template
cp ../templates/GliaWidgets.podspec ../GliaWidgets.podspec

# Replace WIDGETS_SDK_VERSION_SEMVER with WIDGETS_SDK_SEMVER value.
sed -i '' "s/\${WIDGETS_SDK_VERSION_SEMVER}/${WIDGETS_SDK_SEMVER}/" "../GliaWidgets.podspec"

# Replace CORE_SDK_VERSION_SEMVER with retrieved value.
sed -i '' "s/\${CORE_SDK_VERSION_SEMVER}/${CORE_SDK_SEMVER}/g" "../GliaWidgets.podspec"
