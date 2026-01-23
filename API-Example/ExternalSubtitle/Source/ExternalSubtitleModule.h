//
//  ExternalSubtitleModule.h
//  ExternalSubtitle
//
//  Created by 叶俊辉 on 2025/6/17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class ExternalSubtitleModule
 * @brief 外挂字幕模块路由管理器
 *
 * 负责处理外挂字幕相关功能的页面导航和路由分发
 * 支持两种字幕功能的URL跳转:
 * - 标准外挂字幕: kSchemaExternalSubtitleStream
 * - 自定义样式字幕: kSchemaCustomStyledSubtitleStream
 *
 * 使用示例:
 * @code
 * BOOL handled = [ExternalSubtitleModule handleURL:@"schema://external-subtitle"
 *                                           fromVC:self];
 * @endcode
 */
@interface ExternalSubtitleModule : NSObject

/**
 * @brief 处理URL导航请求
 * @note 根据URL schema自动路由到对应的字幕功能页面
 *
 * @param url 要处理的URL字符串,支持的schema:
 *            - kSchemaExternalSubtitleStream: 标准外挂字幕
 *            - kSchemaCustomStyledSubtitleStream: 自定义样式字幕
 * @param viewController 源视图控制器,用于页面跳转
 *                       - 优先使用navigationController进行push
 *                       - 无导航控制器时使用present方式
 *
 * @return YES 表示URL被成功处理, NO 表示URL不匹配或处理失败
 */
+ (BOOL)handleURL:(NSString *)url fromVC:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
