//
//  PipDisplayLayerViewController.h
//  PipDisplayLayer
//
//  Created by junhui ye on 2025/10/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class PipDisplayLayerViewController
 * @brief 画中画功能演示（DisplayLayer 方案）- 阿里云播放器 SDK 画中画最佳实践
 *
 * 本示例展示了如何使用阿里云播放器 SDK 结合 AVSampleBufferDisplayLayer 实现画中画功能。
 * 与 PictureInPictureViewController（SDK 内置方案）不同，本方案通过 CicadaRenderingDelegate
 * 手动接收视频帧并送入 AVSampleBufferDisplayLayer，适用于需要自定义渲染管线的场景。
 *
 * ==================== 前提条件 ====================
 * 1. 系统版本：iOS 15.0 及以上
 * 2. 设备支持：确保设备支持画中画功能（模拟器可能不支持）
 * 3. 权限配置：在 Capabilities 中勾选 "Audio, AirPlay, Picture in Picture"
 * 4. 音频会话：设置音频会话为 playback 模式
 * 5. 后台解码：开启播放器后台解码能力 ALLOW_DECODE_BACKGROUND
 *
 * ==================== 播放器 API 调用步骤 ====================
 * Step 1: 创建播放器实例和播放器视图
 *         - 创建 AliPlayer 实例
 *         - 设置渲染代理 CicadaRenderingDelegate 接收视频帧
 *         - 设置播放场景
 *         - 开启后台解码能力
 *
 * Step 2: 初始化画中画组件
 *         - 创建 AVSampleBufferDisplayLayer 及其控制时间基准
 *         - 创建 AVPictureInPictureController（基于 ContentSource）
 *
 * Step 3: 设置播放源并开始播放
 *         - 创建播放源对象并设置播放地址
 *         - 调用 prepare + start 开始播放
 *
 * Step 4: 处理画中画播放控制
 *         - 实现播放/暂停控制（同步 controlTimebase rate）
 *         - 处理快进/快退操作
 *         - 管理进度条时间范围
 *
 * Step 5: 资源清理
 *         - 停止画中画，释放控制器
 *         - 停止播放器，销毁实例
 *         - 释放 DisplayLayer 和视图
 *
 * ==================== scaleMode 与 videoGravity 的关系 ====================
 * 播放器 AVPScalingMode（AliPlayer.scalingMode）控制播放器内部渲染视图的缩放模式，
 * 而 AVLayerVideoGravity（AVSampleBufferDisplayLayer.videoGravity）控制画中画窗口中视频帧的填充方式。
 * 两者作用于不同的渲染通道，但语义上一一对应：
 *
 *  AVPScalingMode                    AVLayerVideoGravity                   效果
 *  ─────────────────────────────────────────────────────────────────────────────────
 *  AVP_SCALINGMODE_SCALETOFILL       AVLayerVideoGravityResize             拉伸填充，不保持纵横比，画面可能变形
 *  AVP_SCALINGMODE_SCALEASPECTFIT    AVLayerVideoGravityResizeAspect       等比缩放，保持纵横比，可能出现黑边（默认值）
 *  AVP_SCALINGMODE_SCALEASPECTFILL   AVLayerVideoGravityResizeAspectFill   等比填充，保持纵横比，超出部分被裁剪
 *
 * 在 DisplayLayer 方案中，如需画中画窗口的缩放行为与播放器主画面一致，
 * 应将 pipDisplayLayer.videoGravity 设为与 player.scalingMode 语义对应的值。
 *
 * ==================== 注意事项 ====================
 * - 画中画功能仅在 iOS 15.0+ 且真机上支持
 * - 必须开启播放器后台解码能力（ALLOW_DECODE_BACKGROUND）
 * - 需要正确管理 controlTimebase 的 time 和 rate，否则画中画画面可能不刷新
 * - 页面退出时必须强制清理画中画和播放器资源
 * - onRenderingFrame 返回 YES 时不渲染 playerView，返回 NO 时同时渲染两个通道
 *
 * ==================== 使用示例 ====================
 * @code
 * // Step 1: 创建播放器
 * self.player = [[AliPlayer alloc] init];
 * self.player.playerView = self.playerView;
 * self.player.delegate = self;
 * [self.player setRenderingDelegate:self];
 * [self.player setOption:ALLOW_DECODE_BACKGROUND valueInt:1];
 *
 * // Step 2: 创建 DisplayLayer 和画中画控制器
 * self.pipDisplayLayer = [AVSampleBufferDisplayLayer layer];
 * self.pipDisplayLayer.videoGravity = AVLayerVideoGravityResizeAspect;
 *
 * AVPictureInPictureControllerContentSource *source =
 *     [[AVPictureInPictureControllerContentSource alloc]
 *      initWithSampleBufferDisplayLayer:self.pipDisplayLayer
 *      playbackDelegate:self];
 * self.pipController = [[AVPictureInPictureController alloc] initWithContentSource:source];
 *
 * // Step 3: 渲染代理 - 将视频帧送入 DisplayLayer
 * - (BOOL)onRenderingFrame:(CicadaFrameInfo *)frameInfo {
 *     return [self enqueuePixelBufferForImmediateDisplay:frameInfo.video_pixelBuffer];
 * }
 *
 * // Step 4: 画中画播放控制
 * - (void)pictureInPictureController:(AVPictureInPictureController *)ctrl
 *                         setPlaying:(BOOL)playing {
 *     playing ? [self.player start] : [self.player pause];
 *     CMTimebaseSetRate(self.pipDisplayLayer.controlTimebase, playing ? 1.0 : 0.0);
 * }
 *
 * // Step 5: 资源清理
 * [self.player stop];
 * [self.player destroy];
 * self.player = nil;
 * @endcode
 */
@interface PipDisplayLayerViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
