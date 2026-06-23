Language: 中文简体 | [English](README-EN.md)

# **AliPlayerKit iOS 指南**

[![Platform](https://img.shields.io/badge/Platform-iOS%2011.0%2B-blue.svg)](https://developer.apple.com/ios/) [![Language](https://img.shields.io/badge/Language-Objective--C-orange.svg)](https://developer.apple.com/documentation/objectivec) [![CocoaPods](https://img.shields.io/badge/CocoaPods-compatible-green.svg)](https://cocoapods.org/) [![GitHub](https://img.shields.io/badge/GitHub-PlayerKit--iOS-blue?logo=github)](https://github.com/aliyun/PlayerKit-iOS) [![website](https://img.shields.io/badge/Product-VOD-FF6A00)](https://www.aliyun.com/product/vod)

------

## **📌 简介**

AliPlayerKit 是阿里云面向视频业务推出的 **播放器含 UI 集成方案**，提供**低代码、可扩展的播放器 UI 组件**与**场景化解决方案**。通过对播放器能力和 UI 交互的高度封装，帮助客户以极低的接入成本快速完成 App 播放能力建设，无需直接调用底层播放器 API，也无需自行实现复杂的播放器 UI。

---

## **✨ 核心特性**

- 🚀 **低代码接入** - 极简 API 设计，几行代码即可完成播放器集成
- 🎨 **丰富的 UI 组件** - 提供开箱即用的播放器 UI，支持自定义主题与插槽系统
- 📱 **场景化方案** - 内置中长视频、短视频、直播、播放列表等常见播放场景
- 🔧 **灵活可扩展** - 插槽系统支持 UI 自由组合，策略系统支持业务逻辑灵活扩展

------

## **🏗️ 架构概览**

AliPlayerKit 位于播放器内核之上，通过统一的 UI 组件体系与播放场景抽象，承载不同播放业务的共性能力：

```
┌─────────────────────────────────────────────────┐
│              业务应用层 (Your App)                │
├─────────────────────────────────────────────────┤
│       PlayerKitScenes（场景解决方案）              │
│   中长视频 / 短视频 / 直播 / 播放列表              │
├─────────────────────────────────────────────────┤
│         PlayerKit（核心 UI 组件层）                │
│   View / Controller / Model / Slot / Strategy    │
├─────────────────────────────────────────────────┤
│            AliPlayer SDK（播放器内核）             │
└─────────────────────────────────────────────────┘
```

AliPlayerKit 提供两种接入层级：

| 层级 | 模块 | 说明 | 适用场景 |
|-----|------|------|---------|
| **组件层** | `PlayerKit` | 核心 UI 组件，提供播放器视图、控制器、数据模型 | 需要自定义 UI 或灵活控制播放行为 |
| **场景层** | `PlayerKitScenes` | 完整场景解决方案，包含 UI 和业务逻辑 | 快速实现标准播放场景 |

------

## **🔗 相关链接**

- 📘 **在线文档**：[AliPlayerKit iOS 文档](https://aliyun.github.io/PlayerKit-iOS/)
- 💻 **GitHub 仓库**：[PlayerKit-iOS](https://github.com/aliyun/PlayerKit-iOS)

------

## **🚀 快速开始**

请访问 [GitHub 仓库](https://github.com/aliyun/PlayerKit-iOS) 获取源码，并结合 [在线文档](https://aliyun.github.io/PlayerKit-iOS/) 完成接入。

> **Swift 项目接入**：PlayerKit 使用 Objective-C 开发，对于 Swift 工程，推荐参考 [Swift-Call-OC-Example](../Swift-Call-OC-Example/README.md) 方案完成 PlayerKit 的集成与使用。

------

如需进一步帮助，请访问 [阿里云视频点播官方文档中心](https://help.aliyun.com/zh/vod) 获取更多资源支持。

-----
