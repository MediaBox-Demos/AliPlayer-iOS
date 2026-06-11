//
//  AUIShortVideoRateView.h
//  Pods
//
//  Created by wyq on 2024/11/11.
//
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN



@interface AUIShortVideoRateView : UIView

@property (nonatomic, copy) void(^onRateChange)(CGFloat value);

@end

NS_ASSUME_NONNULL_END
