//
//  ThumbnailModule.h
//  Thumbnail
//
//  Created by 叶俊辉 on 2025/6/13.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 缩略图模块入口
 * 负责处理 schema 跳转，打开缩略图功能演示页面。
 */
@interface ThumbnailModule : NSObject

/**
 * @brief 处理 URL 导航
 *
 * @param url 需要处理的 URL
 * @param viewController 源视图控制器
 *
 * @return 处理成功返回 YES，否则返回 NO
 */
+ (BOOL)handleURL:(NSString *)url fromVC:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
