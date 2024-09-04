WIDGETS_SDK_SEMVER=$1
CORE_SDK_SEMVER=$2
CORE_SDK_CHECKSUM=$3

# Copy a new podspec file from template
cp ../templates/GliaWidgets.podspec ../GliaWidgets.podspec

# Replace WIDGETS_SDK_VERSION_SEMVER with project_version value.
sed -i '' "s/\${WIDGETS_SDK_VERSION_SEMVER}/${WIDGETS_SDK_SEMVER}/g" "../GliaWidgets.podspec"

# Replace CORE_SDK_VERSION_SEMVER with passed value.
sed -i '' "s/\${CORE_SDK_VERSION_SEMVER}/${CORE_SDK_SEMVER}/g" "../GliaWidgets.podspec"

WIDGETS_SDK_CHECKSUM=$(awk '/GliaWidgetsXcf.xcframework.zip/{p=NR} NR==p+1' '../Package.swift' | grep 'checksum:' | awk -F'"' '{print $2}')

# Copy a new Package.swift file from template
cp ../templates/Package.swift ../Package.swift

# Replace WIDGETS_SDK_SEMVER with project_version value.
sed -i '' "s/\${WIDGETS_SDK_SEMVER}/${WIDGETS_SDK_SEMVER}/g" "../Package.swift"

# Replace WIDGETS_SDK_CHECKSUM with widgets_sdk_checksum value.
sed -i '' "s/\${WIDGETS_SDK_CHECKSUM}/${WIDGETS_SDK_CHECKSUM}/g" "../Package.swift"

# Replace CORE_SDK_SEMVER with passed value.
sed -i '' "s/\${CORE_SDK_SEMVER}/${CORE_SDK_SEMVER}/g" "../Package.swift"

# Replace CORE_SDK_CHECKSUM with passed value.
sed -i '' "s/\${CORE_SDK_CHECKSUM}/${CORE_SDK_CHECKSUM}/g" "../Package.swift"
