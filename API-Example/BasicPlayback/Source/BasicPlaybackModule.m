//
//  BasicPlaybackModule.m
//  BasicPlayback
//
//  Created by keria on 2025/6/4.
//

#import "BasicPlaybackModule.h"
#import "BasicPlaybackViewController.h"
#import <Common/CommonConstants.h>
#import <Common/CommonLocalizedStrings.h>

@implementation BasicPlaybackModule

+ (NSString *)moduleTitle {
    return AppGetString(@"app.basic.playback.title");
}

+ (NSString *)moduleSchema {
    return kSchemaBasicPlayback;
}

+ (NSString *)moduleDescription {
    return AppGetString(@"app.basic.playback.description");
}

+ (NSString *)moduleCategory {
    return kModuleCategoryBasic;
}

+ (BOOL)handleURL:(NSString *)url fromVC:(UIViewController *)viewController {
    if (url && viewController && [kSchemaBasicPlayback isEqualToString:url]) {
        BasicPlaybackViewController *vc = [[BasicPlaybackViewController alloc] init];

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
