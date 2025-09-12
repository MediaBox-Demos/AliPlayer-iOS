//
//  PreloadViewController.h
//  Preload
//
//  Created by 叶俊辉 on 2025/6/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class PreloadViewController
 * @brief 播放器预加载（URL）功能演示 - 阿里云播放器 SDK 最佳实践
 *
 * 本示例展示了如何使用阿里云播放器 SDK 实现预加载功能，提升视频起播速度
 *
 * ==================== 前提条件 ====================
 * 1. 配置 License：确保已在 AppDelegate 中配置有效的播放器 License
 * 2. 网络权限：确保应用具有网络访问权限
 * 3. SDK 集成：确保已正确集成阿里云播放器 SDK
 * 4. 本地缓存：确保已开启本地缓存功能
 *
 * ==================== 预加载 API 调用步骤 ====================
 * Step 1: 创建播放器实例
 *         - 使用 [[AliPlayer alloc] init] 创建播放器
 *         - 可选：设置 traceId 开启播放器单点追查
 *
 * Step 2: 设置本地缓存
 *         - 使用 [AliPlayerGlobalSettings enableLocalCache:YES] 开启本地缓存
 *         - 配置缓存清理策略（可选）
 *
 * Step 3: 初始化视图组件
 *         - 初始化预加载控制按钮
 *         - 设置按钮点击事件监听
 *
 * Step 4: 配置预加载任务
 *         - 创建 AVPPreloadConfig 配置对象
 *         - 构建 AVPPreloadTask 预加载任务
 *         - 添加任务到 AliMediaLoaderV2 实例
 *
 * Step 5: 预加载控制操作
 *         - 开始预加载：addTask:listener:
 *         - 暂停预加载：pauseTask:
 *         - 恢复预加载：resumeTask:
 *         - 取消预加载：cancelTask:
 *
 * Step 6: 资源清理
 *         - 取消所有预加载任务
 *         - 销毁播放器实例
 *         - 清空相关引用，避免内存泄漏
 *
 * ==================== 使用示例 ====================
 * @code
 * // 1. 创建播放器实例
 * self.player = [[AliPlayer alloc] init];
 *
 * // 2. 设置本地缓存
 * [AliPlayerGlobalSettings enableLocalCache:YES];
 *
 * // 3. 配置预加载任务
 * AVPPreloadConfig *config = [[AVPPreloadConfig alloc] init];
 * [config setDuration:kPreloadBufferDuration];
 * [config setDefaultQuality:kSampleDefaultQuality];
 * [config setDefaultResolution:kSampleDefaultResolution];
 * [config setDefaultBandWidth:kSampleDefaultBandwidth];
 * self.preloadTask = [[AVPPreloadTask alloc] initWithVidAuthSource:vidAuthSource preloadConfig:config];
 *
 * // 4. 开始预加载
 * NSString *taskId = [[AliMediaLoaderV2 getInstance] addTask:task listener:self];
 *
 * // 5. 资源清理
 * [self.player destroy];
 * self.player = nil;
 * @endcode
 */
@interface PreloadViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
