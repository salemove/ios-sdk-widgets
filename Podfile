source 'https://github.com/CocoaPods/Specs.git'
project 'GliaWidgets.xcodeproj'

DEPLOYMENT_TARGET = '13.0'

platform :ios, DEPLOYMENT_TARGET

use_frameworks!
inhibit_all_warnings! # ignore all warnings from all pods

def swiftlint
   pod 'SwiftLint'
end

target 'TestingApp' do
    pod 'PureLayout', '~> 3.1'
end

target 'GliaWidgets' do
  pod 'GliaCoreSDK'
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
