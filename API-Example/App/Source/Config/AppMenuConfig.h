//
//  AppMenuConfig.h
//  App
//
//  Created by keria on 2025/6/3.
//

#import <Foundation/Foundation.h>

@class AppMenuItem;

NS_ASSUME_NONNULL_BEGIN

/**
 * @class AppMenuConfig
 *
 * @brief Menu configuration manager for loading and managing menu items
 * @note 菜单配置管理，用于加载和管理菜单项
 */
@interface AppMenuConfig : NSObject

/**
 * @brief Get all menu items including headers and items
 *
 * 获取所有菜单项，包括标题和条目
 *
 * @return Array of MenuItem objects
 */
+ (NSArray<AppMenuItem *> *)getMenuItems;

@end

NS_ASSUME_NONNULL_END
