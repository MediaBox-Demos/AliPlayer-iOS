//
//  RtsLiveStreamModule.m
//  Pods
//
//  Created by aqi on 2025/6/11.
//

#import "RtsLiveStreamModule.h"
#import "RtsLiveStreamViewController.h"
#import <Common/CommonConstants.h>
#import <Common/CommonLocalizedStrings.h>

@implementation RtsLiveStreamModule

+ (NSString *)moduleTitle {
    return AppGetString(@"app.basic.rts.title");
}

+ (NSString *)moduleSchema {
    return kSchemaRtsLiveStream;
}

+ (NSString *)moduleDescription {
    return AppGetString(@"app.basic.rts.description");
}

+ (NSString *)moduleCategory {
    return kModuleCategoryBasic;
}

+ (BOOL)handleURL:(NSString *)url fromVC:(UIViewController *)viewController {
    if (url && viewController && [kSchemaRtsLiveStream isEqualToString:url]) {
        RtsLiveStreamViewController *vc = [[RtsLiveStreamViewController alloc] init];
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
