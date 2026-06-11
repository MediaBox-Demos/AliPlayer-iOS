//
//  AUIPlayer-Bridge-Header.h
//  Pods
//
//  Created by aqi on 2024/11/27.
//

/**
 *  @brief Swift 使用 Objective-C 的桥接头文件
 *
 *  @note
 *  当 Swift 项目需要使用 Objective-C 的第三方库或插件时，必须配置项目的 Build Settings
 *  中的 Objective-C Bridging Header。
 *
 *  项目名称示例：AlivcPlayerDemo。请将其替换为您自己的项目名称。
 *
 *  配置示例：
 *  SWIFT_OBJC_BRIDGING_HEADER = AlivcPlayerDemo/AlivcPlayerDemo-Bridge-Header.h
 *
 *  在 Pod 文件中修改 SWIFT_OBJC_BRIDGING_HEADER 的配置，以确保 Swift 能正确访问 Objective-C 的接口：
 *
 *  #import "AUIShortVideoList.h"
 *  #import "AUIShortDramaFeeds.h"
 *  #import "AUIShortDramaList.h"
 */

#ifndef AUIPlayer_Bridging_Header_h
#define AUIPlayer_Bridging_Header_h

// 在此处引入需要暴露给 Swift 的 Objective-C 头文件
//#import "AUIShortVideoList.h"
//#import "AUIShortDramaFeeds.h"
//#import "AUIShortDramaList.h"

#endif /* AUIPlayer_Bridging_Header_h */
