Pod::Spec.new do |s|

  s.name         = 'CLCamera'
  s.version      = '1.0.1'
  s.summary      = 'Swift版自定义相机'
  s.description  = <<-DESC
                   CLCarmera是自定义相机的封装.
                   DESC
  s.homepage     = 'https://github.com/JmoVxia/CLCamera'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = {'JmoVxia' => 'JmoVxia@gmail.com'}
  s.social_media_url = 'https://github.com/JmoVxia'
  s.swift_versions = ['5.0']
  s.ios.deployment_target = '12.0'
  s.source       = {:git => 'https://github.com/JmoVxia/CLCamera.git', :tag => s.version}
  s.source_files = ['Camera/**/*.swift']
  s.resource     = 'Camera/Resource/CLCamera.bundle'
  s.requires_arc = true
  s.dependency 'SnapKit'

end