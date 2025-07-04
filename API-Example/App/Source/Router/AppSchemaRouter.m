//
//  AppSchemaRouter.m
//  App
//
//  Created by keria on 2025/6/3.
//

#import "AppSchemaRouter.h"
#import "AppModuleManager.h"
#import <Common/CommonConstants.h>

@implementation AppSchemaRouter

// 使用Schema URL导航到目标页面
+ (BOOL)navigateFromViewController:(UIViewController *)viewController
                        withSchema:(NSString *)schema {
    if (!viewController || !schema || schema.length == 0) {
        return NO;
    }

    @try {
        // 首先尝试通过模块系统处理路由
        if ([[AppModuleManager sharedManager] handleURL:schema fromVC:viewController]) {
            return YES;
        }

        // 如果模块路由失败，尝试外部URL
        NSURL *url = [NSURL URLWithString:schema];
        if (!url) {
            [self showSchemaNotSupportedMessage:viewController schema:schema];
            return NO;
        }

        // 检查是否可以打开URL
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:url
                                                   options:@{}
                                         completionHandler:^(BOOL success) {
                                           if (!success) {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                 [self showSchemaNotSupportedMessage:viewController schema:schema];
                                               });
                                           }
                                         }];
            } else {
                BOOL success = [[UIApplication sharedApplication] openURL:url];
                if (!success) {
                    [self showSchemaNotSupportedMessage:viewController schema:schema];
                    return NO;
                }
            }
            return YES;
        } else {
            [self showSchemaNotSupportedMessage:viewController schema:schema];
            return NO;
        }
    } @catch (NSException *exception) {
        [self showSchemaNotSupportedMessage:viewController schema:schema];
        return NO;
    }
}

// 当Schema不被支持时显示错误消息
+ (void)showSchemaNotSupportedMessage:(UIViewController *)viewController
                               schema:(NSString *)schema {
    if (!viewController) {
        return;
    }

    NSString *schemaText = schema ?: @"(null)";
    NSString *message = [NSString stringWithFormat:@"Schema not supported: %@", schemaText];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Navigation Error"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];

    [viewController presentViewController:alert animated:YES completion:nil];
}

@end
