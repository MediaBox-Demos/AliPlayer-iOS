//
//  AUIShortVideoTrackView.h
//  Pods
//
//  Created by wyq on 2024/11/11.
//
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

@interface AUIShortVideoTrackView : UIView

@property (nonatomic, strong) UIScrollView *groupView;
@property (nonatomic, copy) void(^onTrackSelect)(AVPTrackInfo *value);

- (instancetype)initWithFrame:(CGRect)frame dataArray:(NSArray<AVPTrackInfo *> *)dataArray;

@end

NS_ASSUME_NONNULL_END
