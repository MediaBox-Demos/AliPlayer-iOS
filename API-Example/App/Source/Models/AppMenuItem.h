//
//  AppMenuItem.h
//  App
//
//  Created by keria on 2025/6/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Menu item type enumeration
 *
 * 菜单项类型枚举
 */
typedef NS_ENUM(NSInteger, AppMenuItemType) {
    AppMenuItemTypeHeader = 0, // 标题类型
    AppMenuItemTypeItem = 1    // 项目类型
};

/**
 * @class AppMenuItem
 *
 * @brief Model class representing a menu item in the application
 * @note 应用程序中菜单项的模型类
 */
@interface AppMenuItem : NSObject

@property (nonatomic, assign, readonly) AppMenuItemType type;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly, nullable) NSString *schema;
@property (nonatomic, strong, readonly, nullable) NSString *itemDescription;

/**
 * @brief Initialize menu item with specified parameters
 *
 * 使用指定参数初始化菜单项
 *
 * @param type The type of menu item
 * @param title The title of menu item
 * @param schema The schema URL for navigation (optional)
 * @param description The description of menu item (optional)
 *
 * @return Initialized menu item instance
 */
- (instancetype)initWithType:(AppMenuItemType)type
                       title:(NSString *)title
                      schema:(nullable NSString *)schema
                 description:(nullable NSString *)description;

/**
 * @brief Create a header type menu item
 *
 * 创建标题类型的菜单项
 *
 * @param title The title of header
 *
 * @return Header menu item instance
 */
+ (instancetype)createHeaderWithTitle:(NSString *)title;

/**
 * @brief Create an item type menu item
 *
 * 创建项目类型的菜单项
 *
 * @param title The title of item
 * @param schema The schema URL for navigation
 * @param description The description of item
 *
 * @return Item menu item instance
 */
+ (instancetype)createItemWithTitle:(NSString *)title
                             schema:(NSString *)schema
                        description:(NSString *)description;

@end

NS_ASSUME_NONNULL_END
