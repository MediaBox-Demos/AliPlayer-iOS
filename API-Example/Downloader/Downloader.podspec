Pod::Spec.new do |s|
  s.name             = 'Downloader'
  s.version          = '1.0.0'
  s.summary          = 'Downloader functionality module'
  s.description      = 'Downloader functionality demonstration, core SDK showcase'
  
  s.homepage         = 'https://github.com/aliyunvideo/MONE_demo_opensource_iOS'
  s.license          = { :type => 'MIT', :text => 'LICENSE' }
  s.author           = { 'aliyunvideo' => 'videosdk@service.aliyun.com' }
  s.source           = { :git => 'https://github.com/aliyunvideo/MONE_demo_opensource_iOS.git', :tag => "v#{s.version}" }
  
  s.ios.deployment_target = '9.0'
  s.static_framework = true
  
  s.source_files = 'Source/**/*.{h,m,mm}'
  # Resources moved to Common module
  # s.resource = 'Resources/Downloader.bundle'
  
  s.dependency 'Common'
  s.dependency 'AliPlayerSDK_iOS'
end
