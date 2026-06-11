#
# Be sure to run `pod lib lint AUIPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AUIPlayer'
  s.version          = '7.6.0'
  s.summary          = 'A short description of AUIPlayer.'
  
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  s.homepage         = 'https://github.com/aliyunvideo/MONE_demo_opensource_iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :text => 'LICENSE' }
  s.author           = { 'aliyunvideo' => 'videosdk@service.aliyun.com' }
  s.source           = { :git => 'https://github.com/aliyunvideo/MONE_demo_opensource_iOS.git', :tag =>"v#{s.version}" }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
  s.ios.deployment_target = '9.0'
  s.static_framework = true
  
  # All-in-one subspec for easy integration
  s.subspec 'All' do |ss|
    ss.dependency 'AUIPlayer/Main'
    ss.dependency 'AUIPlayer/VideoFlow'
    ss.dependency 'AUIPlayer/AUIPlayerKits'
    ss.dependency 'AUIPlayer/AUIPlayerScenes'
    ss.dependency 'AUIPlayer/AUIPlayerSettings'
  end
  
  # Main subspec for core player functionality
  s.subspec 'Main' do |ss|
    ss.resource = 'AUIPlayerMain/Resources/AlivcPlayer.bundle'
    ss.source_files = 'AUIPlayerMain/Class/**/*.{h,m,mm}'
    ss.dependency 'AUIFoundation/All'
    ss.prefix_header_contents = '#import "AlivcPlayerDemo.h"'
  end
  
  # VideoFlow subspec for video streaming functionalities
  s.subspec 'VideoFlow' do |ss|
    ss.source_files = 'AUIVideoFlow/Class/**/*.{h,m,mm}'
    ss.resource = 'AUIVideoFlow/Resources/AUIVideoFlow.bundle'
    ss.dependency 'AUIFoundation/All'
    ss.dependency 'MJRefresh'
    ss.dependency 'SDWebImage'
    ss.dependency 'Masonry'
    ss.dependency 'MBProgressHUD'
    ss.dependency 'FMDB'
    ss.prefix_header_contents = '#import "AUIVideoFlow.h"'
  end
  
  # Player Kits subspec for additional player features
  s.subspec "AUIPlayerKits" do |ss|
    ## Subspec for AUIShortVideoList
    ss.subspec 'AUIShortVideoList' do |sss|
      sss.source_files = 'AUIPlayerKits/AUIShortVideoList/Source/**/*.{h,m,mm}'
      sss.resource = 'AUIPlayerKits/AUIShortVideoList/Resources/AUIShortVideoList.bundle'
      sss.dependency 'AUIFoundation/All'
      sss.dependency 'SDWebImage'
      sss.dependency 'AFNetworking'
      sss.dependency 'MJRefresh'
      sss.prefix_header_contents = '#import "AUIShortVideoList.h"'
    end
  end
  
  # Player Scenes subspec for room management and scene display
  s.subspec "AUIPlayerScenes" do |ss|
    ## Subspec for AUIShortDramaList
    ss.subspec "AUIShortDramaList" do |sss|
      sss.source_files = 'AUIPlayerScenes/AUIShortDramaList/Source/**/*.{h,m,mm}'
      sss.resource = 'AUIPlayerScenes/AUIShortDramaList/Resources/AUIShortDramaList.bundle'
      sss.dependency 'AUIPlayer/AUIPlayerKits/AUIShortVideoList'
      sss.prefix_header_contents = '#import "AUIShortDramaList.h"'
    end
    
    ## Subspec for AUIShortDramaFeeds
    ss.subspec "AUIShortDramaFeeds" do |sss|
      sss.source_files = 'AUIPlayerScenes/AUIShortDramaFeeds/Source/**/*.{h,m,mm}'
      sss.resource = 'AUIPlayerScenes/AUIShortDramaFeeds/Resources/AUIShortDramaFeeds.bundle'
      sss.dependency 'AUIPlayer/AUIPlayerKits/AUIShortVideoList'
      sss.prefix_header_contents = '#import "AUIShortDramaFeeds.h"'
    end
  end
  
  # Settings subspec for player configuration and management
  s.subspec "AUIPlayerSettings" do |ss|
    # AUIBackstage subspec for settings interface
    ss.subspec "AUIBackstage" do |sss|
      sss.source_files = 'AUIPlayerSettings/AUIBackstage/Source/*.{h,m,mm}'
    end
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
