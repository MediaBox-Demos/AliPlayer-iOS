//
//  DownloaderModule.m
//  Downloader
//
//  Created by 叶俊辉 on 2025/6/26.
//

#import "DownloaderModule.h"
#import "DownloaderViewController.h"
#import <Common/CommonConstants.h>
#import <Common/CommonLocalizedStrings.h>
@implementation DownloaderModule

+ (NSString *)moduleTitle {
    return AppGetString(@"app.advanced.downloader.title");
}

+ (NSString *)moduleSchema {
    return kSchemaDownloader;
}

+ (NSString *)moduleDescription {
    return AppGetString(@"app.advanced.downloader.description");
}

+ (NSString *)moduleCategory {
    return kModuleCategoryAdvanced;
}

+ (BOOL)handleURL:(NSString *)url fromVC:(UIViewController *)viewController {
    if (url && viewController && [kSchemaDownloader isEqualToString:url]) {
        DownloaderViewController *vc = [[DownloaderViewController alloc] init];

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
