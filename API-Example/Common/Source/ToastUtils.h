//
//  ToastUtils.h
//  Common
//
//  Created by 叶俊辉 on 2025/7/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ToastUtils : NSObject
+ (void)showToastWithMessage:(NSString *)message inView:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
