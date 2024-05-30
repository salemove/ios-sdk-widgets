Pod::Spec.new do |s|
  s.name                  = 'GliaWidgets'
  s.version               = '${WIDGETS_SDK_VERSION_SEMVER}'
  s.summary               = 'The Glia iOS Widgets library'
  s.description           = 'The Glia Widgets library allows to integrate easily a UI/UX for Glia\'s Digital Customer Service platform'
  s.homepage              = 'https://github.com/salemove/ios-sdk-widgets'
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.author                = { 'Glia' => 'support@glia.com' }
  s.source                = { :git => 'https://github.com/salemove/ios-sdk-widgets.git', :tag => s.version.to_s }

  s.module_name           = 'GliaWidgets'
  s.ios.deployment_target = '13.0'
  s.source_files          = 'GliaWidgets/**/*.swift'
  s.swift_version         = '5.3'

  s.resources             = ['GliaWidgets/Resources/*.{xcassets}', 'GliaWidgets/Resources/**/*.{strings}']
  s.resource_bundle       = {
    'GliaWidgets' => ['GliaWidgets/Resources/*.{xcassets}', 'GliaWidgets/Resources/**/*.{strings}']
  }
  s.exclude_files         = ['GliaWidgets/Window/**']

  s.dependency 'GliaCoreSDK', '1.5.0'
end
