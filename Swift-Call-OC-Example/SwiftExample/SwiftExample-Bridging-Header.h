//
//  SwiftExample-Bridging-Header.h
//  SwiftExample
//
//  Created by keria on 2025/6/6.
//

/**
 *  Swift 与 Objective-C 桥接头文件 (Swift-Objective-C Bridging Header)
 *
 *  作用 (Purpose)：
 *  - 让 Swift 代码能够直接访问和使用 Objective-C 类、方法和属性
 *  - Enable Swift code to directly access and use Objective-C classes, methods, and properties
 *
 *  配置 (Configuration)：
 *  Build Settings -> Objective-C Bridging Header -> $(PROJECT_NAME)/$(PROJECT_NAME)-Bridging-Header.h
 *
 *  使用方法 (Usage)：
 *  1. 在此文件中导入需要的 OC 头文件 (Import required OC headers in this file)
 *  2. Swift 代码中可直接使用导入的 OC 类 (Use imported OC classes directly in Swift)
 *  3. 使用 NSClassFromString() 动态获取 OC 类 (Use NSClassFromString() for dynamic class loading)
 *
 *  示例 (Example)：
 *  // 直接使用 (Direct usage)
 *  let homeVC = AppHomeViewController()
 *  
 *  // 动态创建 (Dynamic creation) - 推荐用于可选依赖 (Recommended for optional dependencies)
 *  if let vcClass = NSClassFromString("AppHomeViewController") as? UIViewController.Type {
 *      let homeVC = vcClass.init()
 *  }
 */

#ifndef SwiftExample_Bridging_Header_h
#define SwiftExample_Bridging_Header_h

#pragma mark - API-Example Headers
#import <App/App.h>
#import <Common/Common.h>
#import <BasicPlayback/BasicPlayback.h>

#pragma mark - AliVCSDK Headers
// AliVCSDK Standard
#if __has_include(<AliVCSDK_Standard/AliVCSDK_Standard.h>)
#import <AliVCSDK_Standard/AliVCSDK_Standard.h>

// AliVCSDK Interactive Live
#elif __has_include(<AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>)
#import <AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>

// AliVCSDK Basic Live
#elif __has_include(<AliVCSDK_BasicLive/AliVCSDK_BasicLive.h>)
#import <AliVCSDK_BasicLive/AliVCSDK_BasicLive.h>

// AliVCSDK UGC
#elif __has_include(<AliVCSDK_UGC/AliVCSDK_UGC.h>)
#import <AliVCSDK_UGC/AliVCSDK_UGC.h>

#endif

#pragma mark - AliPlayerSDK Headers

// AliPlayerSDK Full Version
#if __has_include(<AliyunPlayer/AliyunPlayer.h>)
#import <AliyunPlayer/AliyunPlayer.h>

#endif

#endif /* SwiftExample_Bridging_Header_h */
