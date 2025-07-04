//
//  ExternalSubtitleViewController.h
//  ExternalSubtitle
//
//  Created by 叶俊辉 on 2025/6/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * @class ExternalSubtitleViewController
 * @brief 播放器字幕功能演示 - 阿里云播放器 SDK 最佳实践
 *
 * 本示例展示了如何使用阿里云播放器 SDK 实现字幕功能演示
 *
 * ==================== 播放器 API 调用步骤 ====================
 * Step 1: 创建播放器实例
 * - 使用 [[AliPlayer alloc] init] 创建播放器
 * - 设置播放器渲染视图 playerView
 * - 配置播放器基本参数
 *
 * Step 2: 设置播放源
 * - 创建 AVPUrlSource 播放源对象
 * - 调用 setUrlSource: 设置播放地址
 * - 可选（非必须）setStartTime() 方法设置起播位置
 *
 * Step 3: 开始播放
 * - 调用 prepare 方法准备播放
 * - 调用 start() 方法开始播放
 *
 * Step 4: 播放器状态监听
 * - 设置 delegate 监听播放器状态
 * - 实现 onPlayerEvent:eventType: 方法
 *
 * Step 5: 字幕设置
 * - 调用 addExtSubtitle: 方法添加字幕
 *
 * Step 6: 设置字幕监听
 * - 实现 AVPDelegate 中的字幕相关回调方法
 *
 * Step 7: 清理资源
 * - 调用 destroy 销毁播放器实例
 */
@interface ExternalSubtitleViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
