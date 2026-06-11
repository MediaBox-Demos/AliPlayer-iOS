#
# Be sure to run `pod lib lint AUIShortVideoList.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AUIShortDramaList'
  s.version          = '2.0.0'
  s.summary          = 'The scene solution of short drama theater based on AUIShortVideoList.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
The AUIShortDramaList library offers a comprehensive solution for creating and managing lists of short drama videos within an application. Featuring advanced playback capabilities, optimized video data handling, and seamless integration with prominent network and image caching libraries such as AFNetworking and SDWebImage, AUIShortDramaList is perfect for developers looking to incorporate high-performance video lists into their projects. This library facilitates enhanced user experiences through smooth interaction and efficient content delivery.
                       DESC

  s.homepage         = 'https://www.aliyun.com/solution/media/short-drama'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :text => 'LICENSE' }
  s.author           = { 'aliyunvideo' => 'videosdk@service.aliyun.com' }
  s.source           = { :git => 'https://github.com/MediaBox-Demos/amdemos-android-player.git', :tag =>"v#{s.version}" }

  s.ios.deployment_target = '9.0'
  s.static_framework = true
  
  s.subspec 'AUIShortDramaList' do |ss|
    ss.source_files = 'Source/**/*.{h,m,mm}'
    ss.resource = 'Resources/AUIShortDramaList.bundle'
    ss.dependency 'AUIFoundation/All'
    ss.dependency 'SDWebImage'
    ss.dependency 'AFNetworking'
    ss.dependency 'AUIPlayer/ShortVideoList'
  end
  
  s.subspec 'AliPlayerSDK_iOS' do |ss|
    ss.dependency 'AliPlayerSDK_iOS'
  end
  
  s.subspec 'AliVCSDK_Standard' do |ss|
    ss.dependency 'AliVCSDK_Standard'
  end
  
  s.subspec 'AliVCSDK_BasicLive' do |ss|
    ss.dependency 'AliVCSDK_BasicLive'
  end
  
  s.subspec 'AliVCSDK_InteractiveLive' do |ss|
    ss.dependency 'AliVCSDK_InteractiveLive'
  end
  
  s.subspec 'AliVCSDK_UGC' do |ss|
    ss.dependency 'AliVCSDK_UGC'
  end
  
end
