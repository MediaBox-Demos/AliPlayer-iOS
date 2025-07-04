//
//  CommonLocalizedStrings.m
//  Common
//
//  Created by keria on 2025/6/4.
//

#import "CommonLocalizedStrings.h"

@implementation CommonLocalizedStrings

// 获取Common模块的bundle实例
+ (NSBundle *)commonBundle {
    static NSBundle *commonBundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      // Get the main bundle first
      NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];

      // Try to find the Common.bundle
      NSString *bundlePath = [mainBundle pathForResource:@"Common" ofType:@"bundle"];
      if (bundlePath) {
          commonBundle = [NSBundle bundleWithPath:bundlePath];
      }

      // Fallback to main bundle if Common.bundle is not found
      if (!commonBundle) {
          commonBundle = mainBundle;
      }
    });
    return commonBundle;
}

// 从Common模块bundle中获取本地化字符串
+ (NSString *)localizedStringForKey:(NSString *)key {
    return [self localizedStringForKey:key defaultValue:key];
}

// 获取本地化字符串，如果找不到则返回默认值
+ (NSString *)localizedStringForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    if (!key || key.length == 0) {
        return defaultValue ?: @"";
    }

    NSBundle *bundle = [self commonBundle];
    NSString *localizedString = [bundle localizedStringForKey:key value:defaultValue table:nil];

    return localizedString ?: defaultValue ?
                                           : key;
}

@end
