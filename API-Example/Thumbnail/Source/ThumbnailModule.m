//
//  ThumbnailModule.m
//  Thumbnail
//
//  Created by 叶俊辉 on 2025/6/13.
//

#import "ThumbnailModule.h"
#import "ThumbnailViewController.h"
#import <Common/CommonConstants.h>
#import <Common/CommonLocalizedStrings.h>

@implementation ThumbnailModule

/**
 * @brief 处理 URL 导航
 *
 * 当 URL 匹配缩略图模块的 schema 时，创建 ThumbnailViewController 并打开。
 * 优先使用 navigationController push；不存在导航控制器时使用 present。
 *
 * @param url 需要处理的 URL
 * @param viewController 源视图控制器
 *
 * @return 处理成功返回 YES，否则返回 NO
 */
+ (BOOL)handleURL:(NSString *)url fromVC:(UIViewController *)viewController {
    if (url && viewController && [kSchemaThumbnailStream isEqualToString:url]) {
        ThumbnailViewController *vc = [[ThumbnailViewController alloc] init];
        // 优先使用导航控制器 push
        if (viewController.navigationController) {
            [viewController.navigationController pushViewController:vc animated:YES];
        } else {
            // 无导航控制器时使用 present
            [viewController presentViewController:vc animated:YES completion:nil];
        }
        return YES;
    }
    return NO;
}

@end
