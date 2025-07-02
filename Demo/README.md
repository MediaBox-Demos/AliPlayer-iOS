Language: 中文简体 | [English](README-EN.md)

# **amdemos-ios-player**

阿里视频云播放器SDK示例代码

## **🔐 License 配置说明**

本项目未包含正式 License，请根据以下步骤完成配置以启用完整功能。

### ✅ 正式使用前配置

1. **获取并接入 License**

   请先参考 [接入 License](https://help.aliyun.com/zh/apsara-video-sdk/user-guide/access-to-license) 文档，获取已授权的播放器 SDK License，并按照指引完成接入。

2. **更新 License 信息**

   在 `Example/AlivcPlayerDemo/Info.plist` 文件中，找到如下代码并替换为你自己的 License：

```xml
	<key>AlivcLicenseKey</key>
	<string>YOUR_LICENSE_KEY</string>
	<key>AlivcLicenseFile</key>
	<string>YOUR_LICENSE_FILE_PATH</string>
```

* License Key：填写从控制台获取到的 License 密钥字符串。
* License File：填写 License 文件名称（如 license.crt），并将该 .crt 文件添加到 Example/AlivcPlayerDemo/ 目录下。

> 💡 提示：确保 `.crt` 文件已正确添加到 Xcode 项目资源中，并参与编译打包。

3. **重新编译运行项目**

   完成配置后，请重新编译并运行项目，SDK 将自动加载 License 并启用完整功能。

> **⚠️ 注意**：若未正确配置 License，播放器功能将会受限或无法使用。

----

## **短剧Demo源码公告**

该版本为 2024年10月前发布的旧版本短剧场景Demo源码，阿里云已于2025年2月正式发布最新版「微短剧场景化多实例Demo」，并包含完整源码。新版Demo相比旧版本，集成易用性更高，播放体验更加丝滑，在播放性能和体验上达到了最佳平衡。

当前目录下的旧版短剧场景Demo源码已不再更新维护，若需获取最新版「微短剧场景化多实例Demo」，请先购买播放器专业版License，并提工单联系我们获取Demo源码，详见：

[集成最新「微短剧场景化多实例Demo」](https://help.aliyun.com/zh/vod/use-cases/micro-drama-integration-ios-player-sdk?spm=a2c4g.11186623.help-menu-29932.d_3_0_0_1_1.6afd523cYfdJM7)

[播放器SDK专业版License获取](https://help.aliyun.com/zh/vod/developer-reference/obtain-the-player-sdk-license?spm=a2c4g.11186623.help-menu-search-29932.d_15)

----

## 代码结构

```
├── 根目录                                 // Demo根目录
│   ├── AUIPlayerMain                     // Demo壳组件代码，将其他功能组件UI以列表的形式展示
│   ├── AUIVideoFlow                      // 信息流播放、全屏播放组件代码
│   ├── AUIPlayer.podspec                 // 本地pod文件
│   ├── Example                           // 示例代码工程
│   ├── README.md                         // Readme   

```

## 环境要求
- Xcode 12.0 及以上版本，推荐使用最新正式版本
- CocoaPods 1.9.3 及以上版本
- 准备 iOS 10.0 及以上版本的真机

## 前提条件
获取播放器SDK的License和key，需要包含播放的授权。
参考[获取License](https://help.aliyun.com/zh/vod/developer-reference/license-authorization-and-management)

## 跑通Example Demo

1. 源码下载后，解压进入目录AlivcPlayerDemo
2. 修改Podfile中依赖的播放器SDK为最新版本，版本号参考[iOS播放器SDK](https://help.aliyun.com/zh/vod/developer-reference/release-notes-for-apsaravideo-player-sdk-for-ios)
3. 在Example目录下执行“pod install  --repo-update”，自动安装依赖SDK
4. 打开工程文件“AlivcPlayerDemo.xcworkspace”，修改包Id
5. 在控制台上申请试用License，获取License文件和LicenseKey，如果已有直接进入下一步
6. 把License文件放到AlivcPlayerDemo/目录下，并修改文件名为“license.crt”
7. 把“LicenseKey”（如果没有，请在控制台拷贝），打开“AlivcPlayerDemo/Info.plist”，填写到字段“AlivcLicenseKey”的值中
8. 在真机上编译运行
