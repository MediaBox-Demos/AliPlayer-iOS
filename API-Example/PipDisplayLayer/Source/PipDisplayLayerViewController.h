//
//  PipDisplayLayerViewController.h
//  Pods
//
//  Created by 叶俊辉 on 2025/10/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class PipDisplayLayerViewController
 * @brief 画中画功能演示 - 阿里云播放器 SDK 画中画最佳实践
 *
 * 本示例展示了如何使用阿里云播放器 SDK 结合 AVSampleBufferDisplayLayer 实现画中画功能
 *
 * ==================== 前提条件 ====================
 * 1. 系统版本：iOS 15.0 及以上
 * 2. 设备支持：确保设备支持画中画功能
 * 3. 权限配置：在 Capabilities 中勾选 "Audio, AirPlay, Picture in Picture"
 * 4. 音频会话：设置音频会话为 playback 模式
 * 5. 后台播放：开启播放器后台解码能力
 *
 * ==================== 画中画实现步骤 ====================
 * Step 1: 创建播放器实例和播放器视图
 *         - 创建 AliPlayer 实例
 *         - 设置渲染代理接收视频帧
 *         - 开启后台解码能力
 *
 * Step 2: 初始化画中画组件
 *         - 创建 AVSampleBufferDisplayLayer
 *         - 设置控制时间基准
 *         - 创建 AVPictureInPictureController
 *
 * Step 3: 处理视频帧渲染
 *         - 实现 CicadaRenderingDelegate 接收视频帧
 *         - 将 CVPixelBuffer 转换为 CMSampleBuffer
 *         - 送入 AVSampleBufferDisplayLayer 显示
 *
 * Step 4: 处理画中画控制
 *         - 实现播放/暂停控制
 *         - 处理快进/快退操作
 *         - 管理播放状态同步
 *
 * Step 5: 资源清理
 *         - 停止画中画
 *         - 清理播放器资源
 *         - 释放显示层和控制器
 *
 * ==================== 注意事项 ====================
 * - 画中画功能仅在 iOS 15.0+ 支持
 * - 必须开启播放器后台解码能力
 * - 需要正确管理控制时间基准
 * - 页面退出时必须强制清理资源
 * - 避免在模拟器上测试（可能不支持）
 */
@interface PipDisplayLayerViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
