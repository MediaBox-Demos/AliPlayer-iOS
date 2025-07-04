//
//  MultiResolutionModule.m
//  Pods
//
//  Created by aqi on 2025/6/25.
//

#import "MultiResolutionModule.h"
#import "MultiResolutionViewController.h"
#import <Common/CommonConstants.h>
#import <Common/CommonLocalizedStrings.h>

@implementation MultiResolutionModule

+ (NSString *)moduleTitle {
    return AppGetString(@"app.advanced.multi.title");
}

+ (NSString *)moduleSchema {
    return kSchemaMultiResolution;
}

+ (NSString *)moduleDescription {
    return AppGetString(@"app.advanced.multi.description");
}

+ (NSString *)moduleCategory {
    return kModuleCategoryAdvanced;
}

+ (BOOL)handleURL:(NSString *)url fromVC:(UIViewController *)viewController {
    if (url && viewController && [kSchemaMultiResolution isEqualToString:url]) {
        MultiResolutionViewController *vc = [[MultiResolutionViewController alloc] init];

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
