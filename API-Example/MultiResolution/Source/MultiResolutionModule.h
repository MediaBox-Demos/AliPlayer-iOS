//
//  MultiResolutionModule.h
//  Pods
//
//  Created by aqi on 2025/6/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MultiResolutionModule : NSObject

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
