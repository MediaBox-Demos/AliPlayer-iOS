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
 * @brief 功能演示预加载 - 阿里云播放器 SDK 最佳实践
 *
 * 本示例展示了如何使用阿里云播放器 SDK 实现预加载功能演示
 *
 * ==================== 播放器 API 调用步骤 ====================
 * Step 1: 设置本地缓存
 * - 使用 AliPlayerGlobalSettings 开启本地缓存
 * - 创建 AliMediaLoader 实例进行预加载
 * - 设置预加载状态监听回调
 * - 参考文档：https://help.aliyun.com/zh/vod/developer-reference/advanced-features-1
 *
 * Step 2: 设置预加载器
 * - 调用 load 方法设置预加载相关参数
 * - 开始预加载文件（异步加载，可同时加载多个视频文件）
 *
 * Step 3: 开始播放
 * - 设置预加载可提升视频起播速度
 *
 * Step 4: 取消预加载
 * - 创建 AVPUrlSource 播放源对象
 * - 调用 setUrlSource: 设置播放地址
 */
@interface PreloadViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
