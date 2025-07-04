//
//  BasicPlaybackViewController.h
//  BasicPlayback
//
//  Created by keria on 2025/6/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class BasicPlaybackViewController
 * @brief 基础播放功能演示 - 阿里云播放器 SDK 最佳实践
 *
 * 本示例展示了如何使用阿里云播放器 SDK 实现基础的视频播放功能
 *
 * ==================== 前提条件 ====================
 * 1. 配置 License：确保已在 AppDelegate 中配置有效的播放器 License
 * 2. 网络权限：确保应用具有网络访问权限
 * 3. SDK 集成：确保已正确集成阿里云播放器 SDK
 * 4. 播放源：确保视频 URL 可访问且格式支持
 *
 * ==================== 播放器 API 调用步骤 ====================
 * Step 1: 创建播放器实例和播放器视图
 *         - 使用 [[AliPlayer alloc] init] 创建播放器
 *         - 设置播放器渲染视图 playerView
 *         - 可选：设置 traceId 开启播放器单点追查
 *
 * Step 2: 设置播放源
 *         - 创建 AVPUrlSource 播放源对象
 *         - 调用 setUrlSource: 设置播放地址
 *
 * Step 3: 开始播放
 *         - 调用 prepare 方法准备播放
 *         - 调用 start() 方法开始播放
 *
 * Step 4: 资源清理
 *         - 调用 stop 停止播放
 *         - 调用 destroy 销毁播放器实例
 *         - 清空相关引用，避免内存泄漏
 *
 * ==================== 注意事项 ====================
 * - 播放器实例必须在主线程中创建和操作
 * - 务必在 dealloc 中正确清理播放器资源
 * - 播放器视图需要正确设置 frame 或约束
 * - 建议监听播放器状态变化和错误事件
 *
 * ==================== 使用示例 ====================
 * @code
 * // 1. 创建播放器实例和播放器视图
 * self.player = [[AliPlayer alloc] init];
 * self.player.playerView = self.playerView;
 *
 * // 2. 设置播放源
 * AVPUrlSource *urlSource = [[AVPUrlSource alloc] urlWithString:videoURL];
 * [self.player setUrlSource:urlSource];
 *
 * // 3. 开始播放
 * [self.player prepare];
 * [self.player start];
 *
 * // 4. 资源清理
 * [self.player stop];
 * [self.player destroy];
 * self.player = nil;
 * @endcode
 */
@interface BasicPlaybackViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
