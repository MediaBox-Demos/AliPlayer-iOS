//
//  ExternalSubtitleModule.m
//  ExternalSubtitle
//
//  Created by 叶俊辉 on 2025/6/17.
//

#import "ExternalSubtitleModule.h"
#import "ExternalSubtitleViewController.h"
#import "CustomStyleExternalSubtitleViewController.h"
#import <Common/CommonConstants.h>
#import <Common/CommonLocalizedStrings.h>

@implementation ExternalSubtitleModule

+ (BOOL)handleURL:(NSString *)url fromVC:(UIViewController *)viewController {
    // 参数校验
    if (!url || !viewController) {
        return NO;
    }
    
    // 路由1: 内置字幕 - 播放器内置渲染方式
    else if ([kSchemaExternalSubtitleStream isEqualToString:url]) {
        ExternalSubtitleViewController *vc = [[ExternalSubtitleViewController alloc] init];
        [self navigateToViewController:vc fromVC:viewController];
        return YES;
    }
    
    // 路由2: 自定义样式字幕 - 高级样式定制方式
    else if ([kSchemaCustomStyledSubtitleStream isEqualToString:url]) {
        CustomStyleExternalSubtitleViewController *vc = [[CustomStyleExternalSubtitleViewController alloc] init];
        [self navigateToViewController:vc fromVC:viewController];
        return YES;
    }
    
    return NO;
}

#pragma mark - Private Methods

/**
 * @brief 统一的页面导航方法
 * @note 优先使用push方式,无导航控制器时使用present方式
 *
 * @param targetVC 目标视图控制器
 * @param sourceVC 源视图控制器
 */
+ (void)navigateToViewController:(UIViewController *)targetVC
                          fromVC:(UIViewController *)sourceVC {
    if (sourceVC.navigationController) {
        // 有导航控制器,使用push方式
        [sourceVC.navigationController pushViewController:targetVC animated:YES];
    } else {
        // 无导航控制器,使用present方式
        [sourceVC presentViewController:targetVC animated:YES completion:nil];
    }
}

@end
