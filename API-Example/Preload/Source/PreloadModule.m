//
//  PreloadModule.m
//  Preload
//
//  Created by 叶俊辉 on 2025/6/19.
//

#import "PreloadModule.h"
#import "PreloadViewController.h"
#import <Common/CommonConstants.h>
#import <Common/CommonLocalizedStrings.h>
@implementation PreloadModule

+ (NSString *)moduleTitle {
    return AppGetString(@"app.advanced.preload.title");
}

+ (NSString *)moduleSchema {
    return kSchemaPreloadStream;
}

+ (NSString *)moduleDescription {
    return AppGetString(@"app.advanced.preload.description");
}

+ (NSString *)moduleCategory {
    return kModuleCategoryAdvanced;
}

+ (BOOL)handleURL:(NSString *)url fromVC:(UIViewController *)viewController {
    if (url && viewController && [kSchemaPreloadStream isEqualToString:url]) {
        PreloadViewController *vc = [[PreloadViewController alloc] init];
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
