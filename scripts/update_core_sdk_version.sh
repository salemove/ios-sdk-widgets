set -euo pipefail

CORE_SDK_SEMVER=$1
CORE_SDK_CHECKSUM=$2

# Moves the binaries GliaCoreSDK links to the versions that release was built
# against, in the manifest the Xcode project uses and in the Package.swift
# template. WidgetsDependencies/Package.swift gets the GliaCoreSDK pin itself
# this way too.
ruby ../scripts/sync_core_binaries.rb "$CORE_SDK_SEMVER" \
    ../WidgetsDependencies/Package.swift \
    ../templates/Package.swift

# Retrieves XCFramework semmer from Package.swift file to prevent version changes.
# That's required because the project version is always higher than XCFramework semver
WIDGETS_SDK_XCFRAMEWORK_SEMVER=$(grep 'GliaWidgetsXcf.xcframework.zip' '../Package.swift' | awk -F"/" '{print $8}')
WIDGETS_SDK_XCFRAMEWORK_CHECKSUM=$(awk '/GliaWidgetsXcf.xcframework.zip/{p=NR} NR==p+1' '../Package.swift' | grep 'checksum:' | awk -F'"' '{print $2}')

# Copy a new Package.swift file from template
cp ../templates/Package.swift ../Package.swift

# Replace WIDGETS_SDK_SEMVER with the retrieved XCFramework semver.
sed -i '' "s/\${WIDGETS_SDK_SEMVER}/${WIDGETS_SDK_XCFRAMEWORK_SEMVER}/g" "../Package.swift"

# Replace WIDGETS_SDK_CHECKSUM with widgets_sdk_checksum value.
sed -i '' "s/\${WIDGETS_SDK_CHECKSUM}/${WIDGETS_SDK_XCFRAMEWORK_CHECKSUM}/g" "../Package.swift"

# Replace CORE_SDK_SEMVER with passed value.
sed -i '' "s/\${CORE_SDK_SEMVER}/${CORE_SDK_SEMVER}/g" "../Package.swift"

# Replace CORE_SDK_CHECKSUM with passed value.
sed -i '' "s/\${CORE_SDK_CHECKSUM}/${CORE_SDK_CHECKSUM}/g" "../Package.swift"
