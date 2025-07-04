//
//  CommonLocalizedStrings.h
//  Common
//
//  Created by keria on 2025/6/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class CommonLocalizedStrings
 *
 * @brief Utility class for accessing localized strings from Common module
 * @note 用于访问Common模块本地化字符串的工具类
 */
@interface CommonLocalizedStrings : NSObject

/**
 * @brief Get localized string from Common module bundle
 *
 * 从Common模块bundle中获取本地化字符串
 *
 * @param key The key for the localized string
 * @return The localized string
 */
+ (NSString *)localizedStringForKey:(NSString *)key;

/**
 * @brief Get localized string with default value
 *
 * 获取本地化字符串，如果找不到则返回默认值
 *
 * @param key The key for the localized string
 * @param defaultValue The default value if key is not found
 *
 * @return The localized string or default value
 */
+ (NSString *)localizedStringForKey:(NSString *)key defaultValue:(NSString *)defaultValue;

@end

// Convenience macros for common strings
#define AppGetString(key) [CommonLocalizedStrings localizedStringForKey:key]
#define AppGetStringWithDefault(key, defaultValue) [CommonLocalizedStrings localizedStringForKey:key defaultValue:defaultValue]

NS_ASSUME_NONNULL_END
