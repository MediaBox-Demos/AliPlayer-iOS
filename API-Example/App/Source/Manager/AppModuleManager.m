//
//  AppModuleManager.m
//  App
//
//  Created by keria on 2025/6/4.
//

#import "AppModuleManager.h"
#import <Common/CommonConstants.h>
#import <objc/runtime.h>

@implementation AppModuleManager

// 获取共享管理器实例
+ (instancetype)sharedManager {
    static AppModuleManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instance = [[self alloc] init];
    });
    return instance;
}

// 通过模块处理URL导航
- (BOOL)handleURL:(NSString *)url fromVC:(UIViewController *)viewController {
    if (!url || !viewController) {
        return NO;
    }

    unsigned int classCount;
    Class *classes = objc_copyClassList(&classCount);

    for (unsigned int i = 0; i < classCount; i++) {
        Class class = classes[i];
        NSString *className = NSStringFromClass(class);

        if ([className hasSuffix:@"Module"]) {
            if ([class respondsToSelector:@selector(handleURL:fromVC:)]) {
                BOOL handled = [class handleURL:url fromVC:viewController];
                if (handled) {
                    free(classes);
                    return YES;
                }
            }
        }
    }

    free(classes);
    return NO;
}

@end
