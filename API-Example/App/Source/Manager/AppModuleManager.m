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

// 获取所有模块信息
- (NSArray *)allModuleInfos {
    NSMutableArray *moduleInfos = [NSMutableArray array];

    // 运行时发现所有模块
    unsigned int classCount;
    Class *classes = objc_copyClassList(&classCount);

    for (unsigned int i = 0; i < classCount; i++) {
        Class class = classes[i];
        NSString *className = NSStringFromClass(class);

        if ([className hasSuffix:@"Module"]) {
            if ([class respondsToSelector:@selector(moduleTitle)] &&
                [class respondsToSelector:@selector(moduleSchema)] &&
                [class respondsToSelector:@selector(moduleDescription)] &&
                [class respondsToSelector:@selector(moduleCategory)]) {
                NSString *title = [class performSelector:@selector(moduleTitle)];
                NSString *schema = [class performSelector:@selector(moduleSchema)];
                NSString *description = [class performSelector:@selector(moduleDescription)];
                NSString *category = [class performSelector:@selector(moduleCategory)];

                // 确保所有必要信息都不为空
                if (title && schema && description && category) {
                    NSDictionary *moduleInfo = @{
                        kModuleInfoKeyTitle : title,
                        kModuleInfoKeySchema : schema,
                        kModuleInfoKeyDescription : description,
                        kModuleInfoKeyCategory : category
                    };
                    [moduleInfos addObject:moduleInfo];
                }
            }
        }
    }

    free(classes);
    return [moduleInfos copy];
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
