//
//  ThumbnailViewController.m
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
 * 本示例展示了如何使用阿里云播放器 SDK 实现缩略图功能演示
 *
 * ==================== 播放器 API 调用步骤 ====================
 * Step 1: 创建播放器实例
 * - 使用 [[AliPlayer alloc] init] 创建播放器
 * - 设置播放器渲染视图 playerView
 * - 配置播放器代理和基本参数
 *
 * Step 2: 初始化UI视图
 * - 创建播放器视图容器 playerView
 * - 创建进度条 progressSlider
 * - 创建缩略图显示视图 thumbnailView
 * - 设置视图布局和样式
 *
 * Step 3: 设置播放源
 * - 创建 AVPUrlSource 播放源对象
 * - 调用 setUrlSource: 设置播放地址
 *
 * Step 4: 开始播放
 * - 调用 prepare 方法准备播放
 * - 调用 start 方法开始播放
 *
 * Step 5: 设置播放器准备完成监听
 * - 在 onPlayerEvent: 中处理 AVPEventPrepareDone 事件
 * - 设置进度条最大值 progressSlider.maximumValue
 *
 * Step 6: 设置缩略图及相关监听
 * - 调用 setThumbnailUrl: 设置缩略图URL（若使用Vid则需要在onTrackReady中根据MediaInfo获取）
 * - 通过vid方式获取缩略图：    参考文档：https://help.aliyun.com/zh/vod/developer-reference/basic-features-2
 * - 在进度条拖拽时调用 getThumbnail: 请求指定位置缩略图
 * - 在 onGetThumbnailSuc: 方法中获取并显示缩略图
 *
 * Step 7: 缩略图显示控制
 * - 设置 progressSlider 监听事件
 * - 在 sliderValueChanged: 中显示缩略图并请求对应位置图片
 * - 在 sliderTouchEnded: 中隐藏缩略图并执行跳转
 *
 * Step 8: 清理资源
 * - 调用 stop 停止播放
 * - 调用 destroy 销毁播放器实例
 */

@interface ThumbnailViewController : UIViewController
// 视频总长度
@property float *videoDuration;
// 当前视频位置
@property float *currentDuration;
// 缩略图宽
extern CGFloat const THUMBWIDTH;
// 缩略图高
extern CGFloat const THUMBHEIGHT;
@end
NS_ASSUME_NONNULL_END
