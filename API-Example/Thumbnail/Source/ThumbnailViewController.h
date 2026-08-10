//
//  ThumbnailViewController.h
//  Thumbnail
//
//  Created by 叶俊辉 on 2025/6/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class ThumbnailViewController
 * @brief 功能演示缩略图 - 阿里云播放器 SDK 最佳实践
 *
 * 本示例展示了如何使用阿里云播放器 SDK 实现缩略图功能演示。
 *
 * ==================== 播放器 API 调用步骤 ====================
 * Step 1: 创建播放器实例
 * - 使用 [[AliPlayer alloc] init] 创建播放器
 * - 设置播放器代理 delegate
 * - 设置播放场景为 SceneLong
 *
 * Step 2: 初始化 UI 视图
 * - 创建播放器视图容器 playerView
 * - 创建进度条 progressSlider
 * - 创建缩略图显示视图 thumbnailView
 *
 * Step 3: 设置播放源
 * - 创建 AVPVidAuthSource 播放源对象
 * - 设置 vid 与 playAuth
 * - 调用 setAuthSource: 设置播放源
 *
 * Step 4: 开始播放
 * - 调用 prepare 方法准备播放
 * - 调用 start 方法开始播放（prepare 后可同步调用，onPrepared 后自动起播）
 *
 * Step 5: 播放器准备完成监听
 * - 在 onPlayerEvent:eventType: 中处理 AVPEventPrepareDone 事件
 * - 设置进度条最大值 progressSlider.maximumValue
 * - 从 MediaInfo 中获取缩略图 URL 并调用 setThumbnailUrl: 设置
 *
 * Step 6: 设置缩略图获取回调
 * - 在进度条拖拽时调用 getThumbnail: 请求指定位置缩略图
 * - 在 onGetThumbnailSuc:fromPos:toPos:image: 中显示缩略图
 * - 在 onGetThumbnailFailed: 中隐藏缩略图
 *
 * Step 7: 缩略图显示控制
 * - 为 progressSlider 添加 TouchDown / ValueChanged / TouchUpInside / TouchUpOutside 监听
 * - 在 sliderValueChanged: 中请求对应位置缩略图
 * - 在 sliderTouchEnded: 中隐藏缩略图并执行 seekToTime:seekMode:
 *
 * Step 8: 清理资源
 * - 解绑播放器视图
 * - 调用 stop 停止播放
 * - 调用 destroy 销毁播放器实例
 */

@interface ThumbnailViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
