Pod::Spec.new do |s|
  s.name             = 'SwiftCurrent'
  s.version          = '4.0.0'
  s.summary          = 'Workflows that work, yo (blame Richard for this name)'
  s.description      = <<-DESC
iOS has a linear paradigm for navigation that doesn't support a lot of flexibility. This library attempts to create a dynamic way to define your workflows in code allowing for easy reordering.
                       DESC

  s.homepage         = 'https://github.com/wwt/SwiftCurrent'
  s.license          = { :type => 'Custom', :file => 'LICENSE' }
  s.author           = { 'World Wide Technology, Inc.' => 'SwiftCurrent@wwt.com' }
  s.source           = { :git => 'https://github.com/wwt/SwiftCurrent.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.1'

  s.module_name = 'SwiftCurrent'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Sources/Workflow/**/*.{swift,h,m}'
  end
  
  s.subspec 'UIKit' do |ss|
    ss.ios.deployment_target = '11.0'
    ss.source_files = 'Sources/WorkflowUIKit/**/*.{swift,h,m}'
    ss.dependency 'SwiftCurrent/Core'
  end

  s.pod_target_xcconfig = {
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "$(PLATFORM_DIR)/Developer/Library/Frameworks"',
  }
end