//
//  AUIShortVideoList.h
//  AUIPlayer
//
//  Created by keria on 2024/12/9.
//

#ifndef AUIShortVideoList_h
#define AUIShortVideoList_h

#import "AUIShortVideoListViewController.h"
#import "AUIShortVideoListDataManager.h"
#import "AUIShortVideoListConstants.h"
#import "AUIShortVideoListGlobalSetting.h"
#import "AUIShortVideoListUtils.h"

#if __has_include(<AliVCSDK_Standard/AliVCSDK_Standard.h>)
#import <AliVCSDK_Standard/AliVCSDK_Standard.h>

#elif __has_include(<AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>)
#import <AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>

#elif __has_include(<AliVCSDK_BasicLive/AliVCSDK_BasicLive.h>)
#import <AliVCSDK_BasicLive/AliVCSDK_BasicLive.h>

#elif __has_include(<AliVCSDK_UGC/AliVCSDK_UGC.h>)
#import <AliVCSDK_UGC/AliVCSDK_UGC.h>

#endif

#if __has_include(<AliyunPlayer/AliyunPlayer.h>)
#import <AliyunPlayer/AliyunPlayer.h>
#endif

#endif /* AUIShortVideoList_h */
