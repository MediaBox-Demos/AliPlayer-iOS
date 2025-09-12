//
//  BasicLiveStreamViewController.h
//  BasicLiveStream
//
//  Created by 叶俊辉 on 2025/9/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class BasicLiveStreamViewController
 * @brief 基础直播功能演示 - 阿里云播放器 SDK 最佳实践
 *
 * 本示例展示了如何使用阿里云播放器 SDK 实现基础的直播流播放功能，包括清晰度切换
 *
 * ==================== 播放器 API 调用步骤 ====================
 * Step 0: 创建播放器实例
 * - 使用 [[AliPlayer alloc] init] 创建播放器
 * - 可选：设置 traceId 开启播放器单点追查
 *
 * Step 1: 初始化视图
 * - 创建播放器视图容器并设置播放器渲染视图
 * - 初始化控制按钮
 *
 * Step 2: 设置播放源
 * - 创建播放数据源对象
 * - 调用 setUrlSource: 设置播放数据源
 *
 * Step 3: 开始播放
 * - 调用 prepare 方法准备播放
 * - 调用 start 方法开始播放
 *
 * Step 4: 设置直播流切换功能
 * - 设置清晰度切换按钮监听
 * - 设置流切换回调监听
 *
 * Step 5: 资源清理
 * - 调用 stop 停止播放
 * - 调用 destroy 销毁播放器实例
 * - 清空相关引用，避免内存泄漏
 */
@interface BasicLiveStreamViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
