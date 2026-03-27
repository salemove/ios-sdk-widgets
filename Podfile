source 'https://cdn.cocoapods.org/'
load 'LocalPods.rb' if File.exist?('LocalPods.rb')
plugin 'cocoapods-no-autoimports'
# cocoapods-no-autoimports__pods = ['Pods-GliaWidgets.debug']
project 'GliaWidgets.xcodeproj'

DEPLOYMENT_TARGET = '15.1'

platform :ios, DEPLOYMENT_TARGET

use_frameworks!
inhibit_all_warnings! # ignore all warnings from all pods

def swiftlint
   pod 'SwiftLint'
end

def glia_core_sdk
  defined?(local_core_sdk) ? local_core_sdk : pod('GliaCoreSDK')
end

def glia_telemetry_sdk
  local_telemetry_sdk if defined?(local_telemetry_sdk)
end

target 'TestingApp' do
end

target 'GliaTestApp' do
end

target 'GliaWidgets' do
  glia_core_sdk
  glia_telemetry_sdk
  swiftlint
end

target 'GliaWidgetsTests' do
end

target 'SnapshotTests' do
  pod 'AccessibilitySnapshot', '0.5.0'
  glia_core_sdk
  glia_telemetry_sdk
end

post_install do |installer|
  # Set up git hooks
  system("bash #{Dir.pwd}/scripts/setup-git-hooks.sh") || true

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = DEPLOYMENT_TARGET
    end
  end
end
