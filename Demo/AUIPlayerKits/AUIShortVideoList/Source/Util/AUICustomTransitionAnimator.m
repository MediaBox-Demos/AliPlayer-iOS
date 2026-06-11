//
//  AUICustomTransitionAnimator.m
//  Pods
//
//  Created by wyq on 2024/11/15.
//
#import "AUICustomTransitionAnimator.h"

@implementation AUICustomTransitionAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5; // 动画持续时间
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    UIView *containerView = [transitionContext containerView];
    
    // 设置toViewController的起始状态
    toViewController.view.alpha = 0.0;
    toViewController.view.center = containerView.center;
    [containerView addSubview:toViewController.view];
    
    // 执行动画
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toViewController.view.alpha = 1.0; // 渐变透明度
    } completion:^(BOOL finished) {
        // 完成后调用
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end
