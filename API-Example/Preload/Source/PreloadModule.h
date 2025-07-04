//
//  PreloadModule.h
//  Preload
//
//  Created by 叶俊辉 on 2025/6/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PreloadModule : NSObject
/**
 * @brief Get module title
 * @note 获取模块标题
 */
+ (NSString *)moduleTitle;

/**
 * @brief Get module schema URL
 * @note 获取模块Schema URL
 */
+ (NSString *)moduleSchema;

/**
 * @brief Get module description
 * @note 获取模块描述
 */
+ (NSString *)moduleDescription;

/**
 * @brief Get module category
 * @note 获取模块分类
 */
+ (NSString *)moduleCategory;

/**
 * @brief Handle URL navigation
 * @note 处理URL导航
 *
 * @param url The URL to handle
 * @param viewController The source view controller
 *
 * @return YES if handled successfully, NO otherwise
 */
+ (BOOL)handleURL:(NSString *)url fromVC:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
