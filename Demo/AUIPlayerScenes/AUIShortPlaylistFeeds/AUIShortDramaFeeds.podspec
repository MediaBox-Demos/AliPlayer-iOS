#
# Be sure to run `pod lib lint AUIShortVideoList.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AUIShortDramaFeeds'
  s.version          = '2.0.0'
  s.summary          = 'The scene solution of short drama flow feeds based on AUIShortVideoList.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
The AUIShortDramaFeeds library provides a powerful and efficient way to display and manage short drama content in a feed layout. This component is designed to offer seamless integration with existing video streaming and management frameworks, ensuring smooth playback and interaction for end-users. Leveraging AFNetworking for robust network calls and SDWebImage for efficient image loading and caching, AUIShortDramaFeeds is ideal for developers aiming to create engaging and dynamic media feeds for short drama videos.
                       DESC

  s.homepage         = 'https://www.aliyun.com/solution/media/short-drama'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :text => 'LICENSE' }
  s.author           = { 'aliyunvideo' => 'videosdk@service.aliyun.com' }
  s.source           = { :git => 'https://github.com/MediaBox-Demos/amdemos-android-player.git', :tag =>"v#{s.version}" }

  s.ios.deployment_target = '9.0'
  s.static_framework = true
  
  s.subspec 'AUIShortDramaFeeds' do |ss|
    ss.source_files = 'Source/**/*.{h,m,mm}'
    ss.resource = 'Resources/AUIShortDramaFeeds.bundle'
    ss.dependency 'AUIFoundation/All'
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
