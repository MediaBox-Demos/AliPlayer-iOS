//
//  AppModuleManager.h
//  App
//
//  Created by keria on 2025/6/4.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class AppModuleManager
 *
 * @brief Module manager for dynamic module discovery and management
 * @note 模块管理器，通过运行时动态发现功能模块
 */
@interface AppModuleManager : NSObject

/**
 * @brief Get shared manager instance
 * @note 获取共享管理器实例
 */
+ (instancetype)sharedManager;

/**
 * @brief Get all module information
 * @note 获取所有模块信息
 *
 * @return Array of module info dictionaries containing title, schema, description, category
 */
- (NSArray *)allModuleInfos;

/**
 * @brief Handle URL navigation through modules
 * @note 通过模块处理URL导航
 *
 * @param url The URL to handle
 * @param viewController The source view controller
 *
 * @return YES if handled successfully, NO otherwise
 */
- (BOOL)handleURL:(NSString *)url fromVC:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
