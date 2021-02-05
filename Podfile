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
  pod 'SalemoveSDK', :git => 'https://github.com/salemove/ios-bundle', :tag => "0.26.1"
end

post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end
end