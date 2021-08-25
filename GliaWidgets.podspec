Pod::Spec.new do |s|
    s.name             = 'GliaWidgets'
    s.version          = '0.5.1'
    s.summary          = 'The Glia iOS Widgets library'
    s.description      = 'The Glia Widgets library allows to integrate easily a UI/UX for Glia\'s Digital Customer Service platform'
    s.homepage         = 'https://github.com/salemove/ios-sdk-widgets'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Glia' => 'support@glia.com' }
    s.source           = { :git => 'git@github.com:salemove/ios-sdk-widgets.git', :tag => s.version.to_s }
  
    s.module_name = 'GliaWidgets'
    s.ios.deployment_target = '12.0'
    s.ios.vendored_frameworks = 'GliaWidgets.xcframework'
    s.swift_version = '5.3'
  
    s.dependency 'SalemoveSDK', '0.30.1'
    s.dependency 'PureLayout', '~>3.1'
  end
