//
//  ExternalSubtitleVttModule.m
//  ExternalSubtitleVttModule
//
//  Created by 叶俊辉 on 2025/10/20.
//

#import "ExternalSubtitleVttModule.h"
#import "ExternalSubtitleVttViewController.h"
#import <Common/CommonConstants.h>
#import <Common/CommonLocalizedStrings.h>
@implementation ExternalSubtitleVttModule

+ (BOOL)handleURL:(NSString *)url fromVC:(UIViewController *)viewController {
    if (url && viewController && [kSchemaExternalSubtitleVttStream isEqualToString:url]) {
        ExternalSubtitleVttViewController *vc = [[ExternalSubtitleVttViewController alloc] init];
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
