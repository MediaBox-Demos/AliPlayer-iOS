# **iOS示例工程插件化架构开发指引**

## **📌 概述**

本文档基于 **iOS 示例工程**，介绍如何在现有的插件化架构中，快速添加与集成新的功能模块。该架构基于运行时自动发现机制，支持完全独立的模块开发和部署。

------

## **🔧 架构特点**

- **模块独立**：功能模块只依赖 Common 模块，无主项目耦合
- **自动发现**：运行时自动发现所有以 "Module" 结尾的类
- **分类管理**：支持基础/进阶功能区的自动归类
- **极简接入**：新模块只需约 15 行代码即可完成集成

------

## **🚀 开发流程概览**

### **Step 1：创建模块目录结构**

```bash
YourNewModule/
├── Source/
│   ├── YourNewModule.h                    # 模块公共头文件
│   ├── YourNewModuleModule.h              # 模块插件接口
│   ├── YourNewModuleModule.m              # 模块插件实现
│   ├── YourNewModuleViewController.h      # 功能界面头文件
│   └── YourNewModuleViewController.m      # 功能界面实现
└── YourNewModule.podspec                  # CocoaPods 配置
```

### **Step 2：配置 Podspec 文件**

创建 `YourNewModule.podspec`:

```ruby
Pod::Spec.new do |s|
  s.name             = 'YourNewModule'
  s.version          = '1.0.0'
  s.summary          = 'Your new module description'
  s.description      = 'Detailed description of your new module functionality'
  
  s.homepage         = 'https://github.com/your-repo'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Your Name' => 'your.email@example.com' }
  s.source           = { :git => 'https://github.com/your-repo.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '9.0'
  s.source_files = 'Source/**/*'
  
  # 只依赖 Common 模块，确保完全独立
  s.dependency 'Common'
end
```

### **Step 3：注册 Schema 常量**

在 `Common/Source/CommonConstants.h` 中添加：

```objective-c
// 在现有常量后添加
extern NSString * const kSchemaYourNewModule;
```

在 `Common/Source/CommonConstants.m` 中实现:

```objective-c
// 在现有实现后添加
NSString * const kSchemaYourNewModule = @"your-new-module://";
```

### **Step 4：本地化配置**

在 `Common/Resources/Common.bundle/zh-Hans.lproj/Localizable.strings` 中添加:

```
"app.your_new_module.title" = "您的新模块";
"app.your_new_module.description" = "新模块功能描述";
```

在 `Common/Resources/Common.bundle/en.lproj/Localizable.strings` 中添加:

```
"app.your_new_module.title" = "Your New Module";
"app.your_new_module.description" = "Description of your new module";
```

### **Step 5：实现插件接口**

**接口定义** (`YourNewModuleModule.h`)

```objective-c
@interface YourNewModuleModule : NSObject
+ (NSString *)moduleTitle;
+ (NSString *)moduleSchema;
+ (NSString *)moduleDescription;
+ (NSString *)moduleCategory;
+ (BOOL)handleURL:(NSString *)url fromVC:(UIViewController *)viewController;
@end
```

### **Step 6：创建功能界面**

创建标准的 UIViewController 子类，设置标题、背景色和界面内容即可。

### **Step 7：创建模块公共头文件**

创建 `YourNewModule.h`:

```objc
#ifndef YourNewModule_h
#define YourNewModule_h

#import "YourNewModuleViewController.h"
#import "YourNewModuleModule.h"

#endif /* YourNewModule_h */
```

### **Step 8：更新主项目 Podfile**

在主项目的 `Podfile` 中添加新模块:

```ruby
# 在现有 pod 后添加
pod 'YourNewModule', :path => './YourNewModule'
```

### **Step 9：安装依赖并测试**

```bash
cd Example
pod install
```

打开 `.xcworkspace`，编译运行即可看到新模块自动出现在对应分类中。

----

## **📚 示例参考**

可参考 `BasicPlayback` 模块了解完整实现结构，包括标准目录、接口实现、Podspec 配置等。

---

## **🧾 总结**

通过以上步骤，你可以快速开发一个符合插件化架构的新模块，仅需：

- 实现 4 个核心方法（约15行代码）
- 标准的视图控制器实现
- 简单的配置文件

新模块会自动被系统发现并集成到主应用中，无需修改任何现有代码。

----

