//
//  AliVideoView.h
//  AUIPlayer
//
//  Created by keria on 2024/11/13.
//

#import <UIKit/UIKit.h>
#import "AUIShortVideoInfo.h"
#import "AUIFoundation.h"


#if __has_include(<AliVCSDK_Standard/AliVCSDK_Standard.h>)
#import <AliVCSDK_Standard/AliVCSDK_Standard.h>

#elif __has_include(<AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>)
#import <AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>

#elif __has_include(<AliVCSDK_BasicLive/AliVCSDK_BasicLive.h>)
#import <AliVCSDK_BasicLive/AliVCSDK_BasicLive.h>

#elif __has_include(<AliVCSDK_UGC/AliVCSDK_UGC.h>)
#import <AliVCSDK_UGC/AliVCSDK_UGC.h>

#endif

#if __has_include(<AliyunPlayer/AliyunPlayer.h>)
#import <AliyunPlayer/AliyunPlayer.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class AliVideoView;

/**
 * @protocol AliVideoViewPlayerEventObserver
 *
 * @brief 视频播放事件观察者协议
 *
 * @discussion 实现此协议以接收视频播放过程中发生的事件回调。
 */
@protocol AliVideoViewPlayerEventObserver <NSObject>

/**
 * @brief 播放准备完毕回调
 *
 * @param videoView 触发事件的视频视图。
 *
 * @discussion 当视频资源准备就绪后触发此回调，例如缓冲结束并可以开始播放。
 */
- (void)onPrepared:(AliVideoView *)videoView;

/**
 * @brief 播放进度更新回调
 *
 * @discussion 当视频播放位置更新时，会触发该回调方法，该方法可以用于更新 UI 上的播放进度条，显示当前播放位置等。
 *
 * @param videoView 当前播放视频的 `AliVideoView` 实例。
 * @param position 当前播放的位置，以毫秒为单位。
 * @param duration 视频的总时长，以毫秒为单位。
 */
- (void)onPlayPositionUpdate:(AliVideoView *)videoView position:(int64_t)position duration:(int64_t)duration;

/**
 * @brief 缓冲进度更新回调
 *
 * @discussion 当视频缓冲位置更新时，会触发该回调方法，该方法可以用于更新 UI 上的缓冲进度条，显示当前缓冲位置等。
 *
 * @param videoView 当前播放视频的 `AliVideoView` 实例。
 * @param position 当前缓冲的位置，以毫秒为单位。
 * @param duration 视频的总时长，以毫秒为单位。
 */
- (void)onPlayBufferedPositionUpdate:(AliVideoView *)videoView position:(int64_t)position duration:(int64_t)duration;

/**
 * @brief 播放状态变化回调
 *
 * @param videoView 触发事件的视频视图。
 * @param oldStatus 前一状态。
 * @param newStatus 当前状态。
 *
 * @discussion 当视频播放状态发生变化时触发该回调，例如从播放到暂停的切换。
 */
- (void)onPlayStatusChanged:(AliVideoView *)videoView oldStatus:(AVPStatus)oldStatus newStatus:(AVPStatus)newStatus;

/**
 * @brief 视频开始渲染的回调
 *
 * @param videoView 触发事件的视频视图。
 * @param duration 视频总时长，单位为毫秒。
 *
 * @discussion 当视频开始渲染第一帧画面时触发此回调，表示视频开始可视。
 */
- (void)onRenderingStart:(AliVideoView *)videoView duration:(int64_t)duration;

/**
 * @brief 播放完成回调
 *
 * @param videoView 触发事件的视频视图。
 *
 * @discussion 当视频播放到末尾时触发此回调，表示播放正常结束。
 */
- (void)onCompletion:(AliVideoView *)videoView;

/**
 * @brief 播放过程中出现错误的回调
 *
 * @param videoView 触发事件的视频视图。
 * @param errorModel 包含错误详细信息的对象。
 *
 * @discussion 当播放发生错误时触发此回调，提供错误信息以便诊断和处理问题。
 */
- (void)onError:(AliVideoView *)videoView errorInfo:(AVPErrorModel *)errorModel;

/**
 * @brief 视频轨切换完成时的回调方法。
 *
 * @discussion 当视频轨成功切换时，会触发此回调方法。可以在该方法中进行相关的 UI 更新或其他逻辑处理，以反映视频轨切换后的状态。
 *
 * @param videoView 当前播放视频的 `AliVideoView` 实例。
 * @param trackInfo 切换后视频轨的信息
 */
- (void)onTrackSuccess:(AliVideoView *)videoView trackInfo:(AVPTrackInfo *)trackInfo;

/**
 * @brief 将一帧像素缓冲渲染/入队到指定的播放视图。
 *
 * @param pixelBuffer 待渲染的像素缓冲。仅在本次调用期间有效；若需异步持有，请使用 CVPixelBufferRetain/Release 管理生命周期。
 * @param videoView   承载渲染内容的播放视图（AliVideoView）。
 *
 * @return YES 表示已成功处理该帧（例如已入队到渲染管线或直接显示）；NO  表示未处理（参数无效、渲染层未就绪或内部错误等）。
 *
 * @discussion
 * - 建议在解码/渲染的串行队列中调用，避免并发导致的时序问题；
 * - 如涉及 AVSampleBufferDisplayLayer，可在未就绪时快速返回以减小背压；
 * - 若需要在 UI 上反馈，请切换回主线程进行 UI 更新。
 */
- (BOOL)onPiPRenderPixelBuffer:(CVPixelBufferRef)pixelBuffer
                 fromVideoView:(AliVideoView *)videoView;
@end

/**
 * @class AliVideoView
 * @brief 视频播放器视图类
 *
 * @discussion AliVideoView 是一个自定义 UIView 子类，用于显示和控制视频播放。
 * 该类提供了一系列用于播放控制的 API，支持播放、暂停、跳转、循环播放、速度调整以及音轨选择等功能。
 * 客户端可以通过实现代理方法来监听播放事件和状态变化。
 */
@interface AliVideoView : UIView

/**
 * @brief 初始化视频播放器视图
 *
 * @param delegate 实现 AliVideoViewPlayerEventObserver 协议的对象。
 *
 * @return AliVideoView 的实例。
 */
- (instancetype)initWithEventObserver:(id<AliVideoViewPlayerEventObserver>)delegate;

/**
 * @brief 绑定视频数据
 *
 * @param videoInfo 包含视频详细信息的对象。
 *
 * @discussion 该方法用于将视频信息和事件观察者与视图进行绑定，以方便后续播放控制和事件监听。
 */
- (void)bind:(AUIShortVideoInfo *)videoInfo;

/**
 * @brief 解除绑定的视频播放器
 *
 * @discussion 该方法用于解除当前播放器与视图的绑定关系，停止播放并释放相关资源。
 */
- (void)unbind;

/**
 * @brief 开始播放视频
 *
 * @discussion 启动视频播放，在完成视频信息绑定之后调用。
 */
- (void)start;

/**
 * @brief 暂停播放
 *
 * @discussion 暂停当前正在播放的视频，可以通过 start 方法恢复播放。
 */
- (void)pause;

/**
 * @brief 检查视频是否正在播放
 *
 * @return 播放状态
 */
- (BOOL)isPlaying;

/**
 * @brief 跳转到指定播放进度
 *
 * @param progress 播放进度值，范围从 0.0 到 1.0。
 *
 * @discussion 根据提供的进度值，精确地调整视频播放位置。
 */
- (void)seek:(CGFloat)progress;

/**
 * @brief 跳转到指定播放位置
 *
 * @param position 播放位置，单位为毫秒 (ms)。
 *
 * @discussion 根据提供的毫秒时间戳，精确调整视频播放位置。
 *             与 -seek: 不同的是，该方法直接使用绝对时间而非 0.0~1.0 的进度比例。
 */
- (void)seekToPosition:(int64_t)position;

/**
 * @brief 设置视频循环播放
 *
 * @param loop YES 表示循环播放
 *
 * @discussion 调用此方法以设置播放器的循环播放状态。
 */
- (void)setLoop:(BOOL)loop;

/**
 * @brief 设置播放速度
 *
 * @param rate 播放速度倍速，值必须大于 0。
 *
 * @discussion 调整视频的播放速度，允许用户以不同的速度观看视频内容。
 */
- (void)setSpeed:(CGFloat)rate;

/**
 * @brief 选择视频音轨
 *
 * @param trackInfo 包含音轨信息的对象。
 *
 * @discussion 通过此方法可以选择不同的音轨进行播放，支持多语言或音效切换。
 */
- (void)selectTrack:(AVPTrackInfo *)trackInfo;

/**
 * @brief 获取所有视频轨
 *
 * @return 所有视频轨
 */
// 获取视频轨
- (NSArray<AVPTrackInfo *> *)getVideoTracks;

/**
 * @brief 设置带宽值。
 *
 * @param bandwidth 带宽值。如果为 0 或负数，则重置为默认状态。
 */
- (void)setBandwidth:(NSInteger)bandwidth;
@end

NS_ASSUME_NONNULL_END
