# **AUIShortDramaFeeds**

## **一、场景介绍**

**AUIShortDramaFeeds** 模块是短剧 Feeds 流场景化模块，基于 **AUIShortVideoList** 组件实现。该模块提供 Feeds 流 TAB 页，支持 TAB 页嵌套、TAB 页上下左右滑动播放，实现了播放器实例共享。

## **二、场景集成**

### **集成准备**

在进行短剧 Feeds 流场景搭建之前，请确保已完成 **AUIShortVideoList** 组件的集成准备。

### **集成步骤**

1. 拷贝模块

   将 AUIShortDramaFeeds 模块复制到您的项目工程中。

2. 配置 Podfile

   在项目的 Podfile 中添加对 AUIShortDramaFeeds 模块的引用和依赖。示例配置如下：

   ```ruby
   # Pod Example
   install! 'cocoapods', :deterministic_uuids => false
   source 'https://github.com/CocoaPods/Specs.git'
   
   platform :ios, '9.0'
   
   target 'Your ProjectName' do
     
     # 短剧场景（包含剧场/Feed流）两个模块，可单独集成。
     pod "AUIPlayer/AUIPlayerScenes", :path => "../"
     # 短剧Feeds流场景
   #  pod "AUIPlayer/AUIPlayerScenes/AUIShortDramaFeeds", :path => "../"
   
   end
   
   post_install do |installer|
     installer.pods_project.build_configurations.each do |config|
         config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
         config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
     end
   end
   ```

   请根据您项目中实际存放依赖库的路径进行相应修改。

   注意： 如果您项目中已使用的第三方库的版本与 AUIShortDramaFeeds 源码依赖的版本存在冲突，请以您项目中使用的版本为准。

3. 项目配置

   如果您的项目是 Swift 工程并且需要使用 Objective-C 的第三方库，您必须配置项目的 Build Settings 中的 Objective-C Bridging Header，以确保 Swift 能够正确访问 Objective-C 的接口。请按照以下步骤进行配置：

   * 设置 Bridging Header：

     在项目的 Build Settings 中找到 SWIFT_OBJC_BRIDGING_HEADER 设置，并将其指向您的桥接头文件。示例路径如下：

     ```
     <YourProjectName>/<YourProjectName>-Bridge-Header.h
     ```

   * 引入 Objective-C 接口：

     在桥接头文件中，确保引入需要暴露给 Swift 的 Objective-C 接口，示例如下：

     ```swift
     #import "AUIShortDramaFeeds.h"
     ```

   通过上述配置，您的 Swift 代码将能够正常访问和使用 AUIShortDramaFeeds 模块中的 Objective-C 接口。

   您可以参考 AUIShortVideoList 模块中的 AUIPlayer-Bridging-Header.h 文件，获取更多示例和指导。

4. 编译与运行

   完成配置后，请编译并运行项目，以确保 AUIShortDramaFeeds 组件已被正确集成。

## **三、快速开始**

### **使用方法**

您可以通过以下方式将短剧 Feeds 流的 ViewController 页面直接提供给外部进行跳转。

Objective-C 示例：

```objective-c
- (void)openShortDramaFeeds {
    AUIShortDramaFeedsViewController *vc = [[AUIShortDramaFeedsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
```

Swift 示例：

```swift
func openShortDramaFeeds() {
    let vc = AUIShortDramaFeedsViewController()
    navigationController?.pushViewController(vc, animated: true)
}
```

### **获取数据**

AUIShortDramaFeeds 模块使用的数据结构为 `NSArray<AUIShortVideoInfo *>`，其中 `AUIShortVideoInfo` 是一个存储视频信息的数据类。该数组包含多个 `AUIShortVideoInfo` 实例，每个实例代表一个视频的信息。如需了解更详细的内容，建议查阅 AUIShortVideoList 组件的完整文档。