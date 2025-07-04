//
//  CommonSDKHeaders.h
//  Common
//
//  Created by keria on 2025/6/5.
//

#ifndef CommonSDKHeaders_h
#define CommonSDKHeaders_h

/**
 * @file CommonSDKHeaders.h
 * @brief Unified SDK headers
 * @note 统一的SDK头文件
 */

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

#endif /* CommonSDKHeaders_h */
