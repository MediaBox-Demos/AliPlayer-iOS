//
//  PictureInPictureModule.m
//  Pods
//
//  Created by aqi on 2025/6/23.
//

#import "PictureInPictureModule.h"
#import "PictureInPictureViewController.h"
#import <Common/CommonConstants.h>
#import <Common/CommonLocalizedStrings.h>

@implementation PictureInPictureModule

+ (NSString *)moduleTitle {
    return AppGetString(@"app.advanced.pip.title");
}

+ (NSString *)moduleSchema {
    return kSchemaPipDemo;
}

+ (NSString *)moduleDescription {
    return AppGetString(@"app.advanced.pip.description");
}

+ (NSString *)moduleCategory {
    return kModuleCategoryAdvanced;
}

+ (BOOL)handleURL:(NSString *)url fromVC:(UIViewController *)viewController {
    if (url && viewController && [kSchemaPipDemo isEqualToString:url]) {
        PictureInPictureViewController *vc = [[PictureInPictureViewController alloc] init];

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
