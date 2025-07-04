//
//  FloatWindowModule.m
//  Pods
//
//  Created by aqi on 2025/6/24.
//

#import "FloatWindowModule.h"
#import "FloatWindowViewController.h"
#import <Common/CommonConstants.h>
#import <Common/CommonLocalizedStrings.h>

@implementation FloatWindowModule

+ (NSString *)moduleTitle {
    return AppGetString(@"app.advanced.flow.title");
}

+ (NSString *)moduleSchema {
    return kSchemaFloatWindow;
}

+ (NSString *)moduleDescription {
    return AppGetString(@"app.advanced.flow.description");
}

+ (NSString *)moduleCategory {
    return kModuleCategoryAdvanced;
}

+ (BOOL)handleURL:(NSString *)url fromVC:(UIViewController *)viewController {
    if (url && viewController && [kSchemaFloatWindow isEqualToString:url]) {
        FloatWindowViewController *vc = [[FloatWindowViewController alloc] init];

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
