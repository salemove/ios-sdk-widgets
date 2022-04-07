source 'https://github.com/salemove/glia-ios-podspecs.git'
source 'https://github.com/CocoaPods/Specs.git'
project 'GliaWidgets.xcodeproj'
platform :ios, '12.0'

# ignore all warnings from all pods
inhibit_all_warnings!

use_frameworks!

target 'TestingApp' do
    pod 'PureLayout', '~> 3.1'
end

target 'GliaWidgets' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'PureLayout', '~> 3.1'
  pod 'SalemoveSDK'
  pod 'lottie-ios', '3.2.3'
end

target 'GliaWidgetsTests' do
  use_frameworks!
end

target 'SnapshotTests' do
  use_frameworks!

  pod 'AccessibilitySnapshot', '0.5.0'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
            config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
            config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
        end
    end
end
