Language: [中文简体](README.md) | English

# **AliPlayerKit iOS Guide**

[![Platform](https://img.shields.io/badge/Platform-iOS%2011.0%2B-blue.svg)](https://developer.apple.com/ios/) [![Language](https://img.shields.io/badge/Language-Objective--C-orange.svg)](https://developer.apple.com/documentation/objectivec) [![CocoaPods](https://img.shields.io/badge/CocoaPods-compatible-green.svg)](https://cocoapods.org/) [![GitHub](https://img.shields.io/badge/GitHub-PlayerKit--iOS-blue?logo=github)](https://github.com/aliyun/PlayerKit-iOS) [![website](https://img.shields.io/badge/Product-VOD-FF6A00)](https://www.aliyun.com/product/vod)

------

## **📌 Overview**

AliPlayerKit is Alibaba Cloud's **player UI integration solution** for video applications, offering **low-code, extensible player UI components** and **scenario-based solutions**. By encapsulating player capabilities and UI interactions, it enables rapid development of app playback features with minimal integration effort — no need to call underlying player APIs directly or build complex player UIs from scratch.

---

## **✨ Core Features**

- 🚀 **Low-code Integration** - Minimalist API design, complete player integration with just a few lines of code
- 🎨 **Rich UI Components** - Out-of-the-box player UI with customizable themes and slot system
- 📱 **Scenario-based Solutions** - Built-in scenarios for mid/long video, short video, live streaming, playlists, etc.
- 🔧 **Highly Extensible** - Slot system for flexible UI composition, strategy system for business logic extension

------

## **🏗️ Architecture Overview**

AliPlayerKit sits on top of the player core, providing a unified UI component system and playback scenario abstraction:

```
┌─────────────────────────────────────────────────┐
│            Application Layer (Your App)           │
├─────────────────────────────────────────────────┤
│       PlayerKitScenes (Scenario Solutions)        │
│   Mid/Long Video / Short Video / Live / Playlist │
├─────────────────────────────────────────────────┤
│        PlayerKit (Core UI Component Layer)        │
│   View / Controller / Model / Slot / Strategy    │
├─────────────────────────────────────────────────┤
│           AliPlayer SDK (Player Core)            │
└─────────────────────────────────────────────────┘
```

AliPlayerKit provides two integration levels:

| Level | Module | Description | Use Case |
|-------|--------|-------------|----------|
| **Component** | `PlayerKit` | Core UI components: player view, controller, data model | Custom UI or flexible playback control |
| **Scene** | `PlayerKitScenes` | Complete scenario solutions with UI and business logic | Quickly implement standard playback scenarios |

------

## **🔗 Related Links**

- 📘 **Online Documentation**: [AliPlayerKit iOS Docs](https://aliyun.github.io/PlayerKit-iOS/)
- 💻 **GitHub Repository**: [PlayerKit-iOS](https://github.com/aliyun/PlayerKit-iOS)

------

## **🚀 Quick Start**

Visit the [GitHub Repository](https://github.com/aliyun/PlayerKit-iOS) to get the source code, and follow the [Online Documentation](https://aliyun.github.io/PlayerKit-iOS/) to complete integration.

> **Swift Projects**: PlayerKit is developed in Objective-C. For Swift projects, refer to the [Swift-Call-OC-Example](../Swift-Call-OC-Example/README-EN.md) for integration guidance.

------

For further assistance, visit the [Alibaba Cloud ApsaraVideo VOD Documentation Center](https://www.alibabacloud.com/help/en/vod/) for more resources.

-----
