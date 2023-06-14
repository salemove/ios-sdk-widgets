source 'https://github.com/CocoaPods/Specs.git'
project 'GliaWidgets.xcodeproj'

DEPLOYMENT_TARGET = '12.0'

platform :ios, DEPLOYMENT_TARGET

# ignore all warnings from all pods
inhibit_all_warnings!

use_frameworks!

def swiftlint
   pod 'SwiftLint'
end

target 'TestingApp' do
    pod 'PureLayout', '~> 3.1'
end

target 'GliaWidgets' do
  pod 'SalemoveSDK'
  swiftlint
end

target 'GliaWidgetsTests' do
end

target 'SnapshotTests' do
  pod 'AccessibilitySnapshot', '0.5.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = DEPLOYMENT_TARGET
    end
  end
end
