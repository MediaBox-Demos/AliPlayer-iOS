//
//  AppSchemaRouter.h
//  App
//
//  Created by keria on 2025/6/3.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class AppSchemaRouter
 *
 * @brief Schema-based navigation router
 * @note 基于Schema的导航路由器
 */
@interface AppSchemaRouter : NSObject

/**
 * @brief Navigate to a destination using schema URL
 *
 * 使用Schema URL导航到目标页面
 *
 * @param viewController The source view controller
 * @param schema The schema URL string
 *
 * @return YES if navigation was successful, NO otherwise
 */
+ (BOOL)navigateFromViewController:(UIViewController *)viewController
                        withSchema:(NSString *)schema;

@end

NS_ASSUME_NONNULL_END
