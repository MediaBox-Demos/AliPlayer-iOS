//
//  BasicLiveStreamModule.h
//  BasicLiveStream
//
//  Created by 叶俊辉 on 2025/9/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class BasicLiveStreamModule
 *
 * @brief Independent basic playback module implementation
 * @note 完全独立的基础播放直播流模块实现
 */
@interface BasicLiveStreamModule : NSObject

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
