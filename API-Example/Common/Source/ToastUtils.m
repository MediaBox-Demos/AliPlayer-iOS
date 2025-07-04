//
//  ToastUtils.m
//  Common
//
//  Created by 叶俊辉 on 2025/7/3.
//

#import "ToastUtils.h"

@implementation ToastUtils
+ (void)showToastWithMessage:(NSString *)message inView:(UIView *)view {
    // 创建 UILabel
    UILabel *toastLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 35)];
    toastLabel.text = message;
    toastLabel.textColor = [UIColor whiteColor];
    toastLabel.textAlignment = NSTextAlignmentCenter;
    toastLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds = YES;

    // 设置 UILabel 的位置
    toastLabel.center = CGPointMake(view.center.x, view.center.y);
    [view addSubview:toastLabel];

    // 动画
    toastLabel.alpha = 0.0;
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         toastLabel.alpha = 1.0;
                     } completion:nil];

    // 移除 toast
    [UIView animateWithDuration:0.5
                          delay:2.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         toastLabel.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [toastLabel removeFromSuperview];
                     }];
}
@end
