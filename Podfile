source 'https://github.com/CocoaPods/Specs.git'
project 'GliaWidgets.xcodeproj'
platform :ios, '12.0'

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
  pod 'PureLayout', '~> 3.1'
  pod 'SalemoveSDK'
  pod 'lottie-ios', '3.2.3'
  swiftlint
end

target 'GliaWidgetsTests' do
end

target 'SnapshotTests' do
  pod 'AccessibilitySnapshot', '0.5.0'
end
