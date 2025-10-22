Language: 中文简体 | [English](README-EN.md)

# **API-Example (iOS)**

阿里云播放器 SDK iOS 示例工程

## **📖 项目简介**

本项目为阿里云播放器 SDK 的 iOS 示例工程，基于 Objective-C 开发，旨在帮助开发者快速了解并集成 SDK 提供的核心功能。

项目采用**插件化架构设计**，具有良好的**扩展性**和**可维护性**。

## **✨ 功能特性**

### **🎯 单功能演示设计**
- **聚焦单一功能** - 每个模块仅展示一个核心功能，便于快速理解与验证。
- **极简代码实现** - 仅保留核心逻辑，去除冗余代码，提升示例可读性。
- **统一接入入口** - 支持 Schema 路由跳转，实现模块间解耦导航。

### **🔧 技术特性**
- **插件化架构** - 各功能插件独立封装，便于管理与复用。
- **CocoaPods 集成** - 基于 CocoaPods 实现插件化管理，支持独立开发测试。
- **运行时发现** - 自动发现功能插件，无需手动注册，支持动态扩展。
- **国际化适配** - 支持中英文自动切换，适配多语言环境。
- **灵活 SDK 切换** - 支持多种阿里云播放器 SDK 无缝切换。

## **🏗️ 项目架构**

本项目采用插件化组织方式，结构清晰、易于扩展：

| 模块                 | 说明           | 主要功能                     | 入口文件 |
| ----------------------- | -------------- | ------------------------------- | -------- |
| **Example**             | 工程入口     | 初始化与启动 App 主框架                | ViewController |
| **App**                 | 主应用框架    | 应用入口、插件管理、路由导航            | AppHomeViewController |
| **Common**              | 公共基础模块  | 常量定义、工具类、SDK 头文件            | Common.h |
| **BasicPlayback**       | 单功能演示模块 | 视频播放演示、播放控制                 | BasicPlaybackViewController |
| **BasicLiveStream**     | 单功能演示模块 | 基础直播演示、播放控制                 | BasicLiveStreamViewController |
| **Download**            | 单功能演示模块 | 视频下载与离线播放                    | DownloaderViewController |
| **ExternalSubtitle**    | 单功能演示模块 | 外挂字幕演示与切换（UILabel）          | ExternalSubtitleViewController |
| **ExternalSubtitleVtt** | 单功能演示模块 | 外挂字幕演示与切换（推荐）              | ExternalSubtitleVttViewController |
| **FloatWindow**         | 单功能演示模块 | 悬浮窗播放                           | FloatWindowViewController |
| **MultiResolution**     | 单功能演示模块 | 多码率/分辨率切换                     | MultiResolutionViewController |
| **PictureInPicture**    | 单功能演示模块 | 画中画播放（默认方案）                 | PictureInPictureViewController |
| **PipDisplayLayer**     | 单功能演示模块 | 画中画播放（SampleBufferDisplayLayer）| PipDisplayLayerViewController |
| **Preload**             | 单功能演示模块 | 视频预加载（Direct URL/VOD）          | PreloadViewController |
| **RtsLiveStream**       | 单功能演示模块 | RTS 超低延迟直播播放                  | RtsLiveStreamViewController |
| **Thumbnail**           | 单功能演示模块 | 视频缩略图预览                        | ThumbnailViewController |

> 📌 功能模块将根据业务和演示需求不断扩展，表格仅列举部分代表模块，更多功能请关注项目后续更新。

## **🔐 License 配置说明**

本项目未包含正式 License，请根据以下步骤完成配置以启用完整功能。

### ✅ 正式使用前配置

1. **获取并接入 License**

   请先参考 [接入 License](https://help.aliyun.com/zh/apsara-video-sdk/user-guide/access-to-license) 文档，获取已授权的播放器 SDK License，并按照指引完成接入。

2. **更新 License 信息**

   在 `Example/Example/Info.plist` 文件中，找到如下代码并替换为你自己的 License：

```xml
	<key>AlivcLicenseKey</key>
	<string>YOUR_LICENSE_KEY</string>
	<key>AlivcLicenseFile</key>
	<string>YOUR_LICENSE_FILE_PATH</string>
```

* License Key：填写从控制台获取到的 License 密钥字符串。
* License File：填写 License 文件名称（如 license.crt），并将该 .crt 文件添加到 Example/Example/ 目录下。

> 💡 提示：确保 `.crt` 文件已正确添加到 Xcode 项目资源中，并参与编译打包。

3. **重新编译运行项目**

   完成配置后，请重新编译并运行项目，SDK 将自动加载 License 并启用完整功能。

> **⚠️ 注意**：若未正确配置 License，播放器功能将会受限或无法使用。

## **🚀 快速开始**

### **🧰 环境要求**

| 工具    | 版本要求 |
| ------- | -------- |
| Xcode   | 12.0+    |
| iOS     | 9.0+     |
| CocoaPods | 1.10+  |

### **📦 编译运行**

1. **下载项目**

   ```bash
   git clone [your-repo-url]
   cd API-Example
   ```

2. **安装依赖**

   ```bash
   cd Example
   pod install
   ```

3. **打开项目**

   ```bash
   open Example.xcworkspace
   ```

   > **⚠️ 注意**：请使用 `.xcworkspace` 文件打开项目，而不是 `.xcodeproj` 文件。

4. **连接设备并运行**
   
   - 使用 USB 连接 **iOS 真机设备**，并确保设备已信任开发者证书
   - 在 Xcode 中选择目标设备
   - 点击运行按钮 (⌘+R) 或选择 `Product` → `Run`
   - 等待应用编译并安装到设备

### **🧪 验证结果**
应用启动后将进入主功能菜单页面，点击任意功能项即可跳转至对应的播放演示页面。

