source 'https://cdn.cocoapods.org/'
plugin 'cocoapods-no-autoimports'
# cocoapods-no-autoimports__pods = ['Pods-GliaWidgets.debug']
project 'GliaWidgets.xcodeproj'

DEPLOYMENT_TARGET = '15.5'

platform :ios, DEPLOYMENT_TARGET

use_frameworks!
inhibit_all_warnings! # ignore all warnings from all pods

def swiftlint
   pod 'SwiftLint'
end

target 'TestingApp' do
end

target 'GliaWidgets' do
  pod 'GliaCoreSDK', :path => '../ios-sdk/GliaCoreSDK.sources.podspec'
  pod 'GliaOpenTelemetry', :path => '../ios-telemetry/GliaOpenTelemetry.sources.podspec'
  swiftlint
end

target 'GliaWidgetsTests' do
end

target 'SnapshotTests' do
  pod 'AccessibilitySnapshot', '0.5.0'
  pod 'GliaCoreSDK', :path => '../ios-sdk/GliaCoreSDK.sources.podspec'
  pod 'GliaOpenTelemetry', :path => '../ios-telemetry/GliaOpenTelemetry.sources.podspec'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = DEPLOYMENT_TARGET
    end
  end
end
