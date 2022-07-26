Pod::Spec.new do |s|
    s.name                  = 'GliaWidgets'
    s.version               = '0.9.2'
    s.summary               = 'The Glia iOS Widgets library'
    s.description           = 'The Glia Widgets library allows to integrate easily a UI/UX for Glia\'s Digital Customer Service platform'
    s.homepage              = 'https://github.com/salemove/ios-sdk-widgets'
    s.license               = { :type => 'MIT', :file => 'LICENSE' }
    s.author                = { 'Glia' => 'support@glia.com' }
    s.source                = { :git => 'https://github.com/salemove/ios-sdk-widgets.git', :tag => s.version.to_s }
  
    s.module_name           = 'GliaWidgets'
    s.ios.deployment_target = '12.0'
    s.source_files          = 'GliaWidgets/**/*.swift'
    s.swift_version         = '5.3'
  
    s.resources             = ['GliaWidgets/Resources/*.{xcassets}', 'GliaWidgets/Resources/**/*.{strings}', 'GliaWidgets/Resources/Font/*.{ttf}']
    s.resource_bundle       = {
      'GliaWidgets' => ['GliaWidgets/Resources/*.{xcassets}', 'GliaWidgets/Resources/**/*.{strings}', 'GliaWidgets/Resources/Font/*.{ttf}'] 
    }
    s.exclude_files         = ['GliaWidgets/Window/**']
    
    s.dependency 'SalemoveSDK', '0.34.2'
    s.dependency 'PureLayout', '~>3.1'
    s.dependency 'lottie-ios', '3.2.3'
  end
