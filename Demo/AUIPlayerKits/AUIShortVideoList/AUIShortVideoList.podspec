#
# Be sure to run `pod lib lint AUIShortVideoList.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AUIShortVideoList'
  s.version          = '2.0.0'
  s.summary          = 'Short video list solution based on multi-instance.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Based on Alibaba Cloud's practical experience in micro drama scenes, AUI Kits has encapsulated business for micro drama scenes, accumulated best practices such as local caching and intelligent preloading of audio and video terminal SDKs, and provided low code integration kits to help integrators quickly build micro drama apps and achieve better audio-visual experiences.
                       DESC

  s.homepage         = 'https://www.aliyun.com/solution/media/short-drama'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :text => 'LICENSE' }
  s.author           = { 'aliyunvideo' => 'videosdk@service.aliyun.com' }
  s.source           = { :git => 'https://github.com/MediaBox-Demos/amdemos-android-player.git', :tag =>"v#{s.version}" }

  s.ios.deployment_target = '9.0'
  s.static_framework = true
  
  s.subspec 'AUIShortVideoList' do |ss|
    ss.source_files = 'Source/**/*.{h,m,mm}'
    ss.resource = 'Resources/AUIShortVideoList.bundle'
    ss.dependency 'AUIFoundation/All'
    ss.dependency 'AFNetworking'
    ss.dependency 'SDWebImage'
    ss.dependency 'MJRefresh'
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
