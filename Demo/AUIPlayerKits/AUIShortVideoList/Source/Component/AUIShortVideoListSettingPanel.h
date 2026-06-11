//
//  AUIShortVideoListViewController.h
//  AUIShortVideoList
//
//  Created by Bingo on 2023/9/14.
//

#import "AUIFoundation.h"
#import <UIKit/UIKit.h>

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

NS_ASSUME_NONNULL_BEGIN

@interface AUIShortVideoListSettingPanel : AVBaseControllPanel

- (instancetype)initWithFrame:(CGRect)frame dataArray:(NSArray *)dataArray;

@property (nonatomic, copy) void(^onRateChange)(CGFloat value);

@property (nonatomic, copy) void(^onTrackSelect)(AVPTrackInfo *info);

@end

NS_ASSUME_NONNULL_END
