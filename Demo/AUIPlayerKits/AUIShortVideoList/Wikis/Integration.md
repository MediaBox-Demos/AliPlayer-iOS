# **集成准备**

下面介绍 **AUIShortVideoList** 组件的集成方法，帮助您快速将其整合到项目中。

## **前置条件**

您已获取音视频终端 SDK 的播放器的 License 授权和 License Key。获取方法，请参见[申请License](https://help.aliyun.com/zh/apsara-video-sdk/user-guide/license-authorization-and-management#13133fa053843)。

## **集成步骤**

1. 接入已授权播放器的音视频终端 SDK License。

   具体操作请参见[iOS端接入License](https://help.aliyun.com/zh/apsara-video-sdk/user-guide/access-to-license#5a555cb053usb)。

2. 短剧 Demo 目录结构如下：

```html
.
├── AUIBaseKits	// AUI基础组件模块
│   ├── AUIFoundation	// AUI基础组件
├── AUIPlayer.podspec // 框架配置文件
├── AUIPlayerKits	// 组件化功能模块
│   └── AUIShortVideoList	// 短视频列表基础播放组件
├── AUIPlayerMain	// Demo 首页模块
├── AUIPlayerScenes	// 场景化功能模块
│   ├── AUIShortDramaFeeds	// 短剧剧场场景化功能模块
│   └── AUIShortDramaList	// 短剧 Feeds 流场景化功能模块
├── AUIPlayerSettings	// Demo 后台设置页
├── AUIVideoFlow	// 信息流页
├── Example	// Demo 入口
│   ├── AlivcPlayerDemo
│   │   ├── license.crt	// License 文件
│   ├── AlivcPlayerDemo.xcodeproj
│   ├── AlivcPlayerDemo.xcworkspace
│   ├── Podfile
├── README.md
```

3. 将 AUIFoundation**（**AUI基础组件**）**、AUIShortVideoList**（**短视频列表基础播放组件**）**、AUIPlayer.podspec**（**框架配置文件**）**三个模块拷贝到您项目工程中。

4. 配置 Podfile

   请根据您项目中实际存放依赖库的路径进行相应修改。

   更改 PodFile 文件后请在 PodFile 相同目录下执行 `pod install --repo-update` 更新第三方库依赖。

```ruby
# Pod Example
install! 'cocoapods', :deterministic_uuids => false
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'

target 'Your ProjectName' do
  # 选取的SDK类型
  # 播放器SDK及版本，建议使用最新版本，详情参考官网：https://help.aliyun.com/zh/vod/developer-reference/release-notes-for-apsaravideo-player-sdk-for-ios
  # TODO：在此行替换 'x.x.x' 为具体的版本号，详细信息和版本号请参考上述文档链接
  pod 'AliPlayerSDK_iOS', '~> x.x.x'
  # 模块内依赖（可自定义版本，修改 AUIPlayer.podspec 文件）
  pod "AUIPlayer/AliPlayerSDK_iOS", :path => "../"
  # 您可以根据自己的业务去调整使用的SDK，增加自己要使用的SDK；或者修改 AUIPlayer.podspec 中 AliPlayerSDK_iOS 版本
  # pod "AUIPlayer/AliVCSDK_Standard", :path => "../"
  
  # AUI基础组件（必需）
  pod "AUIFoundation/All", :path => "../AUIBaseKits/AUIFoundation"

  # 短剧列表播放组件
  pod "AUIPlayer/AUIPlayerKits", :path => "../"
  
  # 可自定义第三方库版本
  pod 'SDWebImage', '5.18.1'
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
      config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
      config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
  end
end
```

注意： 如果您项目中已使用的第三方库的版本与当前源码依赖的版本存在冲突，请以您项目中使用的版本为准。

5. 项目配置

   如果您的项目是 Swift 工程并且需要使用 Objective-C 的第三方库，您必须配置项目的 Build Settings 中的 Objective-C Bridging Header，以确保 Swift 能够正确访问 Objective-C 的接口。请按照以下步骤进行配置：

* 设置 Bridging Header：

   在项目的 Build Settings 中找到 SWIFT_OBJC_BRIDGING_HEADER 设置，并将其指向您的桥接头文件。示例路径如下：

  ```
  <YourProjectName>/<YourProjectName>-Bridge-Header.h
  ```

- 引入 Objective-C 接口：

   在桥接头文件中，确保引入需要暴露给 Swift 的 Objective-C 接口，示例如下：

  ```swift
  #import "AUIShortVideoList.h"
  ```

   通过上述配置，您的 Swift 代码将能够正常访问和使用 AUIShortVideoList 模块中的 Objective-C 接口。

   您可以参考 AUIShortVideoList 模块中的 AUIPlayer-Brigde-Header.h 文件，获取更多示例和指导。

6. 编译与运行

完成配置后，请编译并运行项目，以确保 AUIShortVideoList 组件已被正确集成。

> **建议**：集成完成后，建议执行一次 `git commit` ，提交记录当前组件的最新 commit ID。这为将来的组件更新提供重要的追溯依据，也记录了组件更新前后的代码差异，有效把控集成准入质量。同时还可以在寻求技术支持时快速定位组件版本，从而提高技术支持的效率。

## **集成FAQ**

1. 如未配置正确的 SDK License，集成完毕后，会出现播放黑屏等异常问题。

2. Sandbox: rsync.samba(56557) deny(1) file-read-data 碰到项目集成错误时，请配置 BuildSetting 的 Use Script SandBoxing 为 NO。

3. 如果您的项目中已有相同第三方库，请调整 AUIPlayer.podspec 文件中的三方库版本，以确保兼容性并避免冲突。

4. 如果您在修改完 PodFile 之后找不到第三方依赖，请在 PodFile 所在目录下，执行 `pod install --repo-update`

5. 如果您的依赖集成很慢，可以在 PodFile 配置阿里云 Pod 仓库，解决第三方库集成慢的问题：

```ruby
   source 'https://github.com/CocoaPods/Specs.git'
   source 'https://github.com/aliyun/aliyun-specs.git'
```

6. 如果您不想使用 AUIPlayer.podspec 里面的播放器依赖，可以参考[iOS播放器SDK-快速集成](https://help.aliyun.com/zh/vod/developer-reference/quick-integration?#section-d7z-lvz-wvt)。
