#
# Be sure to run `pod lib lint AUIPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'API-Example'
  s.version          = '1.0.0'
  s.summary          = 'iOS Player API Example with modular architecture'

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'A modular iOS player API example application with basic and advanced features'
  
  s.homepage         = 'https://www.aliyun.com/solution/media/short-drama'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :text => 'LICENSE' }
  s.author           = { 'aliyunvideo' => 'videosdk@service.aliyun.com' }
  s.source           = { :git => 'https://github.com/aliyunvideo/MONE_demo_opensource_iOS.git', :tag => "v#{s.version}" }
  
  s.ios.deployment_target = '9.0'
  s.static_framework = true
  
  # Common module (base module)
  s.subspec 'Common' do |ss|
    ss.dependency 'Common'
  end
  
  # Main App module
  s.subspec 'App' do |ss|
    ss.dependency 'App'
  end

  # Basic feature modules
  s.subspec 'BasicPlayback' do |ss|
    ss.dependency 'BasicPlayback'
  end
  
  # RTS LiveStream modules
  s.subspec 'RtsLiveStream' do |ss|
    ss.dependency 'RtsLiveStream'
  end
  
  # Thumbnail feature modules
  s.subspec 'Thumbnail' do |ss|
    ss.dependency 'Thumbnail'
  end
  
  # ExternalSubtitle feature modules
  s.subspec 'ExternalSubtitle' do |ss|
    ss.dependency 'ExternalSubtitle'
  end
  
  # Preload feature modules
  s.subspec 'Preload' do |ss|
    ss.dependency 'Preload'
  end
  
  # Preload feature modules
  s.subspec 'PictureInPicture' do |ss|
    ss.dependency 'PictureInPicture'
  end
  
  # FloatWindow feature modules
  s.subspec 'FloatWindow' do |ss|
    ss.dependency 'FloatWindow'
  end
  
  # Multi-Resolution feature modules
  s.subspec 'MultiResolution' do |ss|
    ss.dependency 'MultiResolution'
  end
  
  # Downloader feature modules
  s.subspec 'Downloader' do |ss|
      ss.dependency 'Downloader'
  end
  
  # All-in-one subspec
  s.subspec 'All' do |ss|
    ss.dependency 'API-Example/Common'
    ss.dependency 'API-Example/App'
    ss.dependency 'API-Example/BasicPlayback'
    ss.dependency 'API-Example/RtsLiveStream'
    ss.dependency 'API-Example/Thumbnail'
    ss.dependency 'API-Example/ExternalSubtitle'
    ss.dependency 'API-Example/Preload'
    ss.dependency 'API-Example/FloatWindow'
    ss.dependency 'API-Example/MultiResolution'
    ss.dependency 'API-Example/Downloader'
  end
  
  # AliVCSDK subspecs for additional functionalities
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
  
  # AliPlayerSDK subspecs for additional functionalities
  s.subspec 'AliPlayerSDK_iOS' do |ss|
    ss.dependency 'AliPlayerSDK_iOS'
  end
  
  s.subspec 'AliPlayerPartSDK_iOS' do |ss|
    ss.dependency 'AliPlayerPartSDK_iOS'
    ss.dependency 'QuCore-ThirdParty'
  end
end
