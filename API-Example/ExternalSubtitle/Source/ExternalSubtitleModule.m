//
//  ExternalSubtitleModule.m
//  ExternalSubtitle
//
//  Created by 叶俊辉 on 2025/6/17.
//

#import "ExternalSubtitleModule.h"
#import "ExternalSubtitleViewController.h"
#import <Common/CommonConstants.h>
#import <Common/CommonLocalizedStrings.h>
@implementation ExternalSubtitleModule

+ (NSString *)moduleTitle {
    return AppGetString(@"app.advanced.externalSubtitle.title");
}

+ (NSString *)moduleSchema {
    return kSchemaExternalSubtitleStream;
}

+ (NSString *)moduleDescription {
    return AppGetString(@"app.advanced.externalSubtitle.description");
}

+ (NSString *)moduleCategory {
    return kModuleCategoryAdvanced;
}

+ (BOOL)handleURL:(NSString *)url fromVC:(UIViewController *)viewController {
    if (url && viewController && [kSchemaExternalSubtitleStream isEqualToString:url]) {
        ExternalSubtitleViewController *vc = [[ExternalSubtitleViewController alloc] init];
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
