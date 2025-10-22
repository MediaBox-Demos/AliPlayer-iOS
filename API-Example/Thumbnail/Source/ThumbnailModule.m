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

+ (BOOL)handleURL:(NSString *)url fromVC:(UIViewController *)viewController {
    if (url && viewController && [kSchemaThumbnailStream isEqualToString:url]) {
        ThumbnailViewController *vc = [[ThumbnailViewController alloc] init];
        // 确保有导航控制器才进行push操作
        if (viewController.navigationController) {
            [viewController.navigationController pushViewController:vc animated:YES];
        } else {
            // 如果没有导航控制器，使用present方式
            [viewController presentViewController:vc animated:YES completion:nil];
        }
        return YES;
    }
    return NO;
}

@end
