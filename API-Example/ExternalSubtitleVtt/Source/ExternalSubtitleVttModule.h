//
//  ExternalSubtitleVttModule.h
//  ExternalSubtitleVttModule
//
//  Created by 叶俊辉 on 2025/10/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExternalSubtitleVttModule : NSObject

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
