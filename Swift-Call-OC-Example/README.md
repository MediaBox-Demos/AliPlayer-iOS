Language: 中文简体 | [English](README-EN.md)

# **Swift-Call-OC-Example**

Swift 调用 Objective-C 模块示例工程

## **📖 项目简介**

本项目为 Swift 调用 Objective-C 模块的示例工程，基于 Swift 开发，旨在帮助开发者快速了解并掌握 Swift 与 Objective-C 混合编程技术。

项目采用**极简化设计**，具有良好的**可读性**和**可维护性**。

## **✨ 功能特性**

### **🎯 极简演示设计**
- **直接启动到 OC 界面** - 应用启动后直接进入 Objective-C 主页，无中间页面。
- **极简代码实现** - 仅保留核心桥接逻辑，去除冗余代码，提升示例可读性。
- **动态类创建** - 使用 `NSClassFromString` 实现 Swift 动态调用 OC 类。

### **🔧 技术特性**
- **桥接头文件配置** - 标准的 Swift-OC 桥接头文件，支持中英文注释。
- **CocoaPods 集成** - 基于 CocoaPods 实现本地依赖管理，支持模块化开发。
- **错误处理机制** - 完善的错误处理，当找不到 OC 类时显示友好提示。
- **iOS 11.0+ 兼容** - 完全支持 iOS 11.0 及以上版本，使用传统 AppDelegate 模式。
- **权限配置精简** - 仅包含必要的网络和文件访问权限。

## **🏗️ 项目架构**

当前项目采用极简化组织方式，主要组件如下：

| 组件                              | 说明                 | 主要功能                           |
| --------------------------------- | -------------------- | ---------------------------------- |
| **AppDelegate.swift**             | Swift 应用入口       | 直接启动到 OC 界面、错误处理       |
| **SwiftExample-Bridging-Header.h** | Swift-OC 桥接头文件  | 导入 OC 模块、类型桥接             |
| **Podfile**                       | 依赖管理配置         | 管理 API-Example 本地依赖          |
| **Info.plist**                    | 应用配置文件         | 权限配置、应用信息                 |

>  📌 本项目专注于演示 Swift 调用 OC 的核心技术，可作为混合编程项目的基础模板。

## **🔗 依赖关系说明**

本项目依赖于 API-Example 项目中的 Objective-C 模块，通过 CocoaPods 本地路径依赖的方式进行集成。

### 📁 目录结构要求

```
AliPlayer-iOS/
├── API-Example/          # Objective-C 示例项目
│   ├── App/
│   ├── Common/
│   └── BasicPlayback/
└── Swift-Call-OC-Example/  # 本 Swift 项目
    ├── SwiftExample/
    ├── Podfile
    └── README.md
```

> **⚠️ 注意**：请确保 API-Example 项目与本项目位于同一目录下，否则 CocoaPods 无法找到本地依赖。

## **🔐 License 配置说明**

本项目未包含正式 License，请根据以下步骤完成配置以启用完整功能。

### ✅ 正式使用前配置

1. **获取并接入 License**

   请先参考 [接入 License](https://help.aliyun.com/zh/apsara-video-sdk/user-guide/access-to-license) 文档，获取已授权的播放器 SDK License，并按照指引完成接入。

2. **更新 License 信息**

   在 `SwiftExample/Info.plist` 文件中，找到如下代码并替换为你自己的 License：

```xml
	<key>AlivcLicenseKey</key>
	<string>YOUR_LICENSE_KEY</string>
	<key>AlivcLicenseFile</key>
	<string>YOUR_LICENSE_FILE_PATH</string>
```

* License Key：填写从控制台获取到的 License 密钥字符串。
* License File：填写 License 文件名称（如 license.crt），并将该 .crt 文件添加到 SwiftExample/ 目录下。

> 💡 提示：确保 `.crt` 文件已正确添加到 Xcode 项目资源中，并参与编译打包。

3. **重新编译运行项目**

   完成配置后，请重新编译并运行项目，SDK 将自动加载 License 并启用完整功能。

> **⚠️ 注意**：若未正确配置 License，播放器功能将会受限或无法使用。

## **🚀 快速开始**

### **🧰 环境要求**

| 工具        | 版本要求 |
| ----------- | -------- |
| Xcode       | 13.0+    |
| iOS         | 11.0+    |
| Swift       | 5.0+     |
| CocoaPods   | 1.10+    |

### **📦 编译运行**

1. **确认目录结构**

   ```bash
   # 确保目录结构正确
   ls -la
   # 应该看到 API-Example 和 Swift-Call-OC-Example 两个目录
   ```

2. **安装依赖**

   ```bash
   cd Swift-Call-OC-Example
   pod install
   ```

3. **打开项目**

   ```bash
   open SwiftExample.xcworkspace
   ```

   > **⚠️ 注意**：请使用 `.xcworkspace` 文件打开项目，而不是 `.xcodeproj` 文件。

4. **连接设备并运行**
   
   - 使用 USB 连接 **iOS 真机设备**，并确保设备已信任开发者证书
   - 在 Xcode 中选择目标设备
   - 点击运行按钮 (⌘+R) 或选择 `Product` → `Run`
   - 等待应用编译并安装到设备

### **🧪 验证结果**

应用启动后将直接进入 Objective-C 的 AppHomeViewController 界面，证明 Swift 成功调用了 OC 模块。

## **🔧 如何实现桥接**

### **步骤 1：创建桥接头文件**

在 Swift 项目中创建桥接头文件 `SwiftExample-Bridging-Header.h`：

```objc
#ifndef SwiftExample_Bridging_Header_h
#define SwiftExample_Bridging_Header_h

// 导入需要在 Swift 中使用的 OC 头文件
#import <App/App.h>
#import <Common/Common.h>
#import <BasicPlayback/BasicPlayback.h>

#endif /* SwiftExample_Bridging_Header_h */
```

### **步骤 2：配置 Xcode 项目**

在 Xcode 项目设置中配置桥接头文件路径：

1. 选择项目 Target
2. 进入 `Build Settings`
3. 搜索 `Objective-C Bridging Header`
4. 设置路径为：`SwiftExample/SwiftExample-Bridging-Header.h`

### **步骤 3：在 Swift 中调用 OC 类**

在 Swift 代码中直接使用 OC 类：

```swift
// 方式 1：直接使用（如果在桥接头文件中已导入）
let homeVC = AppHomeViewController()

// 方式 2：动态创建（推荐用于可选依赖）
if let vcClass = NSClassFromString("AppHomeViewController") as? UIViewController.Type {
    let homeVC = vcClass.init()
    homeVC.title = "App Home"
    // 使用 OC 控制器
}
```

### **步骤 4：配置 CocoaPods 依赖**

在 `Podfile` 中添加本地依赖：

```ruby
platform :ios, '11.0'

target 'SwiftExample' do
  use_frameworks!
  
  # 本地依赖 API-Example 模块
  pod 'App', :path => '../API-Example'
  pod 'Common', :path => '../API-Example'
  pod 'BasicPlayback', :path => '../API-Example'
end
```

### **关键技术点**

1. **桥接头文件**：Swift 编译器通过桥接头文件了解 OC 类的接口
2. **动态类创建**：`NSClassFromString` 允许运行时动态获取 OC 类
3. **类型转换**：将 OC 类转换为 Swift 可用的类型
4. **错误处理**：检查类是否存在，提供友好的错误提示

> **💡 提示**：桥接是双向的，OC 代码也可以调用 Swift 类，但需要在 Swift 类前添加 `@objc` 标记。