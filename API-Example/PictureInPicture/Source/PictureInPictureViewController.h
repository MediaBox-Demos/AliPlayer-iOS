//
//  PictureInPictureViewController.h
//  PictureInPicture
//
//  Created by aqi on 2025/6/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * @class PictureInPictureViewController
 * @brief 画中画功能演示 - 阿里云播放器 SDK 最佳实践
 *
 * 本示例展示了如何使用阿里云播放器 SDK 实现基础的视频播放功能
 *
 * ==================== 前提条件 ====================
 * 1. 配置 License：确保已在 AppDelegate 中配置有效的播放器 License
 * 2. 网络权限：确保应用具有网络访问权限
 * 3. SDK 集成：确保已正确集成阿里云播放器 SDK
 * 4. 播放源：确保视频 URL 可访问且格式支持
 *
 * ==================== 注意事项 ====================
 * - 播放器实例必须在主线程中创建和操作
 * - 务必在 dealloc 中正确清理播放器资源
 * - 播放器视图需要正确设置 frame 或约束
 * - 建议监听播放器状态变化和错误事件
 *
 * ==================== 使用示例 ====================
 * @code
 * // 声明画中画所需要的参数
 * // 监听画中画当前是否是暂停状态
 * @property (nonatomic, assign) BOOL isPipPaused;
 * // 监听播放器当前的播放状态，通过监听播放事件状态变更newStatus回调设置
 * @property (nonatomic, assign) AVPStatus currentPlayerStatus;
 * // 设置画中画控制器，在画中画即将启动的回调方法中设置，并需要在页面准备销毁时主动将其设置为nil，建议设置
 * @property (nonatomic, weak) AVPictureInPictureController *pipController;
 * // 监听播放器当前播放进度，currentPosition设置为监听视频当前播放位置回调中的position参数值
 * @property(nonatomic, assign) int64_t currentPosition;
 * // 播放器对象
 * @property (nonatomic, strong) AliPlayer *player;
 * // 播放器视图容器
 * @property (nonatomic, strong) UIView *playerView;
 *
 * // 配置播放器代理 AVPDelegate
 * - (void)onCurrentPositionUpdate:(AliPlayer*)player position:(int64_t)position {
 *      self.currentPosition = position;
 * }
 *
 * // 播放器事件回调
 * - (void)onPlayerEvent:(AliPlayer *)player eventType:(AVPEventType)eventType {
 *      if (eventType == AVPEventPrepareDone){
 *      //   启用画中画
            [self.player setPictureInPictureEnable:true];
 *      }
 * }
 *
 * // 播放器状态监听
 * - (void)onPlayerStatusChanged:(AliPlayer *)player oldStatus:(AVPStatus)oldStatus newStatus:(AVPStatus)newStatus {
 *       self.currentPlayerStatus = newStatus;
 * }
 *
 * // 配置画中画代理
 * [self.player setPictureinPictureDelegate:self];
 *
 * // 画中画代理实现 AliPlayerPictureInPictureDelegate
 * // 画中画即将开始
 * - (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
 *  if (!self.pipController) {
 *     self.pipController = pictureInPictureController;
 *  }
 *
 *  if (self.pipController){
 *     [self.pipController invalidatePlaybackState];
 *  }
 *  self.isPipPaused = !(self.currentPlayerStatus == AVPStatusStarted);
 *  [pictureInPictureController invalidatePlaybackState];
 * }
 *
 * // 画中画即将停止
 * -(void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
 *    self.isPipPaused = NO;
 *    [pictureInPictureController invalidatePlaybackState];
 * }
 *
 * // 点击画中画暂停按钮
 * - (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController setPlaying:(BOOL)playing {
 *  if (!playing){
 *      [self.player pause];
 *      _isPipPaused = YES;
 *  } else {
 *      [self.player start];
 *      _isPipPaused = NO;
 *  }
 *  [pictureInPictureController invalidatePlaybackState];
 * }
 *
 * // 快进和快退
 * - (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController skipByInterval:(CMTime)skipInterval completionHandler:(void (^)(void))completionHandler {
 *     NSLog(@"%@  skipByInterval  position %lld, value %lld", NSStringFromClass([self class]),self.currentPosition, skipInterval.value);
 *     int64_t skipTime = skipInterval.value / skipInterval.timescale;
 *     int64_t skipPosition = self.currentPosition + skipTime * 1000;
 *     if (skipPosition < 0) {
 *        skipPosition = 0;
 *     } else if (skipPosition > self.player.duration) {
 *       skipPosition = self.player.duration;
 *   }
 *    [self.player seekToTime:skipPosition seekMode:AVP_SEEKMODE_INACCURATE];
 *   [pictureInPictureController invalidatePlaybackState];
 * }
 *
 * // 画中画状态设置
 * - (BOOL)pictureInPictureControllerIsPlaybackPaused:(nonnull AVPictureInPictureController *)pictureInPictureController{
 *     NSLog(@"%@ pictureInPictureControllerIsPlaybackPaused pip paused %d",NSStringFromClass([self class]),self.isPipPaused);
 *     return self.isPipPaused;
 * }
 *
 * // 可播放的画中画进度条范围
 * - (CMTimeRange)pictureInPictureControllerTimeRangeForPlayback:(nonnull AVPictureInPictureController *)pictureInPictureController layerTime:(CMTime)layerTime{
 *     NSLog(@"%@ pictureInPictureControllerTimeRangeForPlayback current position is %lld, duration is %lld\n",NSStringFromClass([self class]), self.currentPosition, self.player.duration);
 *     Float64 current64 = CMTimeGetSeconds(layerTime);
 *
 *     Float64 start;
 *     Float64 end;
 *
 *     if (self.currentPosition <= self.player.duration) {
 *         double curPostion = self.currentPosition / 1000.0;
 *         double duration = self.player.duration / 1000.0;
 *         double interval = duration - curPostion;
 *        start = current64 - curPostion;
 *        end = current64 + interval;
 *        CMTime t1 = CMTimeMakeWithSeconds(start, layerTime.timescale);
 *        CMTime t2 = CMTimeMakeWithSeconds(end, layerTime.timescale);
 *        return CMTimeRangeFromTimeToTime(t1, t2);
 *     } else {
 *        return CMTimeRangeMake(kCMTimeNegativeInfinity, kCMTimePositiveInfinity);
 *    }
 * }
 *
 * // 画中画已经显示时
 * - (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
 *    NSLog(@"%@ pictureInPictureControllerDidStartPictureInPicture",NSStringFromClass([self class]));
 *    [pictureInPictureController invalidatePlaybackState];
 * }
 *
 * // 画中画已经停止时
 * - (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
 *    NSLog(@"%@ pictureInPictureControllerDidStopPictureInPicture",NSStringFromClass([self class]));
 * }
 *
 * - (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler {
 *     NSLog(@"%@ restoreUserInterfaceForPictureInPictureStopWithCompletionHandler",NSStringFromClass([self class]));
 *     completionHandler(YES);
 * }
 *
 * - (void)pictureInPictureController:(nonnull AVPictureInPictureController *)pictureInPictureController didTransitionToRenderSize:(CMVideoDimensions)newRenderSize {
 *     NSLog(@"%@ didTransitionToRenderSize width:%d, height:%d",NSStringFromClass([self class]), newRenderSize.width, newRenderSize.height);
 * }
 *
 * - (void)pictureInPictureControllerIsPictureInPictureEnable:(AVPictureInPictureController *)pictureInPictureController isEnable:(BOOL)isEnable {
 *     NSLog(@"%@  pictureInPictureControllerIsPictureInPictureEnable : %@",NSStringFromClass([self class]), (isEnable== YES)?@"YES":@"No");
 *     if (isEnable && pictureInPictureController) {
 *         _pipController = pictureInPictureController;
 *             // close pip auto start
 *         if (@available(iOS 15.0, *)) {
 *             _pipController.canStartPictureInPictureAutomaticallyFromInline = false;
 *         }
 *     }
 * }
 *
 * // Step 1 初始化UI
 * self.playerView = [[UIView alloc] initWithFrame:self.view.bounds];
 * [self.view addSubview:self.playerView];
 *
 * // Step 2: 初始化播放器 && 绑定播放器视图 && 设置播放器代理/画中画代理
 * self.player = [[AliPlayer alloc] init];
 * // 绑定播放器视图
 * self.player.playerView = self.playerView;
 * // 设置播放器代理
 * [self.player setDelegate:self];
 * // 设置画中画代理
 * [self.player setPictureinPictureDelegate:self];
 *
 * // Step 3: 播放视频
 * AVPUrlSource *urlSource = [[AVPUrlSource alloc] urlWithString:kSampleVideoURL];
 * [self.player setUrlSource:urlSource];
 *
 * // 准备播放
 * [self.player prepare];
 * // 调用 start 方法开始播放
 * [self.player start];
 *
 * // Step 4: 监听onPlayerEvent 的 AVPEventPrepareDone，开启画中画
 * - (void)onPlayerEvent:(AliPlayer *)player eventType:(AVPEventType)eventType {
 *          switch (eventType) {
 *             case AVPEventPrepareDone: {
 *             // 开启画中画
 *                  [self.player setPictureInPictureEnable:true];
 *              } break;
 *              case AVPEventCompletion: {
 *                  self.isPipPaused = YES;
 *              } break;
 *              case AVPEventLoadingStart: {
 *                  self.isPipPaused = YES;
 *              } break;
 *              case AVPEventLoadingEnd: {
 *                  self.isPipPaused = NO;
 *              } break;
 *              default:
 *                  break;
 *              }
 *
 *              if (self.pipController) {
 *                   [self.pipController invalidatePlaybackState];
 *               }
 * }
 * @endcode
 */
@interface PictureInPictureViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
