//
//  PipDisplayLayerViewController.m
//  Pods
//
//  Created by 叶俊辉 on 2025/10/21.
//

#import "PipDisplayLayerViewController.h"
#import <AliyunPlayer/AliyunPlayer.h>
#import <Common/Common.h>

#import "PipDisplayLayerViewController.h"
#import <AliyunPlayer/AliyunPlayer.h>
#import <Common/Common.h>

@interface PipDisplayLayerViewController () <AVPDelegate, AVPictureInPictureSampleBufferPlaybackDelegate, AVPictureInPictureControllerDelegate, CicadaRenderingDelegate>

// 播放器相关
@property (nonatomic, strong) AliPlayer *player;
@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, assign) int64_t currentPosition;

// 画中画相关
@property (nonatomic, strong) UIView *pipView;
@property (nonatomic, strong) AVSampleBufferDisplayLayer *pipDisplayLayer;
@property (nonatomic, strong) AVPictureInPictureController *pipController;
@property (nonatomic, assign) BOOL isPipPaused;

// UI 控件
@property (nonatomic, strong) UIButton *pipButton;

@end

@implementation PipDisplayLayerViewController

#pragma mark - View Lifecycle

// 视图加载完毕后的初始化设置
- (void)viewDidLoad {
    [super viewDidLoad];
    [AliPrivateService initLicenseService];
    self.title = AppGetString(@"pip.title");
    self.view.backgroundColor = [UIColor blackColor];
    
    // Step 1: 初始化视图和播放器
    [self setupViews];
    [self setupPlayer];
    
    // Step 2: 初始化画中画组件
    [self setupPictureInPicture];
    
    // Step 3: 开始播放
    [self startPlayback];
}

// 页面即将消失时的处理
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 检查是否是真正的页面退出
    if (self.isMovingFromParentViewController || self.isBeingDismissed) {
        NSLog(@"[Lifecycle] Page is being dismissed, force cleanup");
        [self forceCleanupResources];
    }
}

// 释放资源
- (void)dealloc {
    [self cleanupPlayer];
    [self cleanupPictureInPicture];
    NSLog(@"[dealloc] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - Setup Methods

// Step 1: 初始化视图
- (void)setupViews {
    // 1.1 创建播放器视图容器
    self.playerView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.playerView];
    
    // 1.2 创建画中画按钮
    [self setupPipButton];
    
    NSLog(@"[Step 1] 视图初始化完成");
}

// 创建画中画按钮
- (void)setupPipButton {
    NSString *title = AppGetString(@"pip.btn.title");
    CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17]}];
    
    CGFloat buttonWidth = titleSize.width + 20;
    CGFloat buttonHeight = 50;
    CGFloat buttonX = (self.view.bounds.size.width - buttonWidth) / 2;
    CGFloat buttonY = self.view.bounds.size.height - 85;
    
    self.pipButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight)];
    self.pipButton.layer.cornerRadius = 10;
    self.pipButton.clipsToBounds = YES;
    self.pipButton.backgroundColor = [UIColor colorWithRed:135.0/255.0 green:206.0/255.0 blue:235.0/255.0 alpha:1.0];
    [self.pipButton setTitle:title forState:UIControlStateNormal];
    [self.pipButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.pipButton addTarget:self action:@selector(pipButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.pipButton];
}

// Step 1: 创建播放器实例和播放器视图
- (void)setupPlayer {
    // 1.1 创建播放器实例
    self.player = [[AliPlayer alloc] init];
    
    // 1.2 设置播放器渲染视图和代理
    self.player.playerView = self.playerView;
    [self.player setRenderingDelegate:self];
    
    // 1.3 开启后台解码能力（画中画必需）
    [self.player setOption:ALLOW_DECODE_BACKGROUND valueInt:1];
    
    // 可选：推荐使用`播放器单点追查`功能
    // [self.player setTraceID:traceId];
    
    NSLog(@"[Step 1] 播放器创建完成: %@", self.player);
}

// Step 2: 初始化画中画组件
- (void)setupPictureInPicture {
    // 检查系统版本和设备支持
    if (![self isPictureInPictureSupported]) {
        NSLog(@"[Step 2] 画中画功能不支持，跳过初始化");
        return;
    }
    
    // 2.1 创建画中画视图容器
    [self setupPipView];
    
    // 2.2 创建 AVSampleBufferDisplayLayer
    [self setupDisplayLayer];
    
    // 2.3 创建画中画控制器
    [self setupPipController];
    
    NSLog(@"[Step 2] 画中画组件初始化完成");
}

// 创建画中画视图容器
- (void)setupPipView {
    self.pipView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.pipView];
    [self.view insertSubview:self.pipView belowSubview:self.playerView];
}

// 创建显示层
- (void)setupDisplayLayer {
    self.pipDisplayLayer = [AVSampleBufferDisplayLayer layer];
    
    // 设置显示层属性
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.pipDisplayLayer.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    self.pipDisplayLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    // 创建控制时间基准
    [self setupControlTimebase];
    
    [self.pipView.layer addSublayer:self.pipDisplayLayer];
    
    NSLog(@"[Step 2] DisplayLayer 创建完成，尺寸: %.0fx%.0f", screenWidth, screenHeight);
}

// 设置控制时间基准
- (void)setupControlTimebase {
    CMTimebaseRef controlTimebase = NULL;
    OSStatus status = CMTimebaseCreateWithSourceClock(kCFAllocatorDefault,
                                                     CMClockGetHostTimeClock(),
                                                     &controlTimebase);
    if (status == noErr && controlTimebase) {
        self.pipDisplayLayer.controlTimebase = controlTimebase;
        CMTimebaseSetTime(controlTimebase, kCMTimeZero);
        CMTimebaseSetRate(controlTimebase, 1.0);
        CFRelease(controlTimebase);
        NSLog(@"[Step 2] 控制时间基准创建成功");
    } else {
        NSLog(@"[Step 2] 控制时间基准创建失败: %d", status);
    }
}

// 创建画中画控制器
- (void)setupPipController {
    if (@available(iOS 15.0, *)) {
        AVPictureInPictureControllerContentSource *source =
            [[AVPictureInPictureControllerContentSource alloc]
             initWithSampleBufferDisplayLayer:self.pipDisplayLayer
             playbackDelegate:self];
        
        self.pipController = [[AVPictureInPictureController alloc] initWithContentSource:source];
        self.pipController.delegate = self;
        self.pipController.canStartPictureInPictureAutomaticallyFromInline = YES;
        self.pipController.requiresLinearPlayback = NO;
        
        NSLog(@"[Step 2] 画中画控制器创建成功");
    }
}

#pragma mark - Playback Methods

// Step 3: 设置播放源并开始播放
- (void)startPlayback {
    // 3.1 创建播放源对象并设置播放地址
    AVPVidAuthSource *authSource = [[AVPVidAuthSource alloc]init];
    [authSource setVid:kSampleVideoId];
    [authSource setPlayAuth:kSampleVideoAuth];
    
    [self.player setAuthSource:authSource];
    
    // 3.2 准备播放并开始
    [self.player prepare];
    [self.player start];
    
    NSLog(@"[Step 3] 开始播放视频: %@", kSampleVideoId);
}

#pragma mark - Picture in Picture Methods

// 检查画中画功能是否支持
- (BOOL)isPictureInPictureSupported {
    // 检查系统版本
    if (@available(iOS 15.0, *)) {
        // 检查设备支持
        return [AVPictureInPictureController isPictureInPictureSupported];
    }
    return NO;
}

// 检查画中画功能是否可用
- (BOOL)isPictureInPictureAvailable {
    return [self isPictureInPictureSupported] && self.pipController != nil;
}

// 开启画中画模式
- (void)startPictureInPicture {
    if (![self isPictureInPictureSupported]) {
        NSLog(@"[PiP] 画中画功能不支持");
        return;
    }
    if (!self.pipController) {
        NSLog(@"[PiP] 画中画控制器未实现");
        return;
    }
    if (![self isPictureInPictureAvailable]) {
        NSLog(@"[PiP] 画中画功能不可用，无法启动");
        return;
    }
    
    NSLog(@"[PiP] 启动画中画: possible=%d, active=%d",
          (int)self.pipController.isPictureInPicturePossible,
          (int)self.pipController.isPictureInPictureActive);
    
    [self.pipController startPictureInPicture];
}

// 关闭画中画模式
- (void)stopPictureInPicture {
    // 检查画中画功能是否可用
    if (![self isPictureInPictureAvailable]) {
        NSLog(@"[PiP] 画中画功能不可用，无法停止");
        return;
    }
    
    NSLog(@"[PiP] 停止画中画");
    [self.pipController stopPictureInPicture];
}

// 设置画中画播放状态
- (void)setPictureInPicturePaused:(BOOL)isPaused {
    // 检查画中画功能是否可用
    if (![self isPictureInPictureAvailable]) {
        NSLog(@"[PiP] 画中画不可用, 不能设置暂停状态.");
        return;
    }
    if (self.isPipPaused == isPaused) {
        return;
    }
    
    // 更新暂停状态
    self.isPipPaused = isPaused;
    
    // 同步控制时间基准状态
    if (self.pipDisplayLayer.controlTimebase) {
        CMTimebaseSetRate(self.pipDisplayLayer.controlTimebase, isPaused ? 0.0 : 1.0);
    }
    
    NSLog(@"[PiP] 画中画状态: %@", isPaused ? @"暂停" : @"播放");
}

#pragma mark - Video Frame Processing

// 将一帧像素缓冲（CVPixelBuffer）封装为 CMSampleBuffer 并立刻送进 pipDisplayLayer（AVSampleBufferDisplayLayer）进行显示。
//
// 1) pixelBuffer 待显示的像素缓冲。仅在本次调用期间有效；如需异步持有，请自行使用 CVPixelBufferRetain/Release 管理其生命周期。
// 2) 返回 YES 表示样本已成功入队；NO 表示未入队（如参数无效、显示层未就绪、构建格式描述/样本失败等）。
- (BOOL)enqueuePixelBufferForDisplay:(CVPixelBufferRef)pixelBuffer {
    static CMTime lastPresentationTime = {0};
    static BOOL isFirstFrame = YES;
    
    if (!pixelBuffer || !self.pipDisplayLayer) {
        return NO;
    }
    
    // 检查显示层状态
    if (![self checkDisplayLayerStatus]) {
        return NO;
    }
    
    // 创建样本缓冲
    CMSampleBufferRef sampleBuffer = [self createSampleBufferFromPixelBuffer:pixelBuffer
                                                         presentationTime:&lastPresentationTime
                                                              isFirstFrame:&isFirstFrame];
    if (!sampleBuffer) {
        return NO;
    }
    
    // 送入显示层
    [self.pipDisplayLayer enqueueSampleBuffer:sampleBuffer];
    CFRelease(sampleBuffer);
    
    return NO; // 返回 NO 以同时渲染 playerView
}

// 检查显示层状态
- (BOOL)checkDisplayLayerStatus {
    if (self.pipDisplayLayer.status == AVQueuedSampleBufferRenderingStatusFailed) {
        NSLog(@"[PiP] DisplayLayer 失败，重置中...");
        [self resetDisplayLayer];
        return NO;
    }
    
    return self.pipDisplayLayer.isReadyForMoreMediaData;
}

// 重置显示层
- (void)resetDisplayLayer {
    [self.pipDisplayLayer flush];
    
    // 重置控制时间基准
    if (self.pipDisplayLayer.controlTimebase) {
        CMTimebaseSetTime(self.pipDisplayLayer.controlTimebase, kCMTimeZero);
        CMTimebaseSetRate(self.pipDisplayLayer.controlTimebase, self.isPipPaused ? 0.0 : 1.0);
    }
}

// 创建样本缓冲
- (CMSampleBufferRef)createSampleBufferFromPixelBuffer:(CVPixelBufferRef)pixelBuffer
                                       presentationTime:(CMTime *)lastTime
                                            isFirstFrame:(BOOL *)isFirst {
    // 创建格式描述
    CMVideoFormatDescriptionRef videoInfo = NULL;
    OSStatus err = CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
    if (err != noErr || !videoInfo) {
        NSLog(@"[PiP] 创建视频格式描述失败: %d", err);
        return NULL;
    }
    
    // 计算呈现时间
    CMTime presentationTime = [self calculatePresentationTime:lastTime isFirstFrame:isFirst];
    
    // 设置时间信息
    CMSampleTimingInfo timing = {
        .duration = CMTimeMake(1, 30), // 30fps
        .presentationTimeStamp = presentationTime,
        .decodeTimeStamp = presentationTime,
    };
    
    // 创建样本缓冲
    CMSampleBufferRef sampleBuffer = NULL;
    err = CMSampleBufferCreateReadyWithImageBuffer(kCFAllocatorDefault,
                                                   pixelBuffer,
                                                   videoInfo,
                                                   &timing,
                                                   &sampleBuffer);
    CFRelease(videoInfo);
    
    if (err != noErr) {
        NSLog(@"[PiP] 创建样本缓冲失败: %d", err);
        return NULL;
    }
    
    return sampleBuffer;
}

// 计算呈现时间
- (CMTime)calculatePresentationTime:(CMTime *)lastTime isFirstFrame:(BOOL *)isFirst {
    CMTime presentationTime;
    
    // 使用控制时间基准的当前时间作为呈现时间
    if (self.pipDisplayLayer.controlTimebase) {
        presentationTime = CMTimebaseGetTime(self.pipDisplayLayer.controlTimebase);
    } else {
        // 备用方案：使用递增时间戳
        if (*isFirst) {
            presentationTime = kCMTimeZero;
            *isFirst = NO;
        } else {
            CMTime increment = CMTimeMake(1, 30); // 30fps
            presentationTime = CMTimeAdd(*lastTime, increment);
        }
    }
    
    *lastTime = presentationTime;
    return presentationTime;
}

#pragma mark - Event Handlers

// 画中画按钮点击事件
- (void)pipButtonTapped:(UIButton *)sender {
    if (self.pipController) {
        [self startPictureInPicture];
    }
}

#pragma mark - Cleanup Methods

// 强制清理所有资源
- (void)forceCleanupResources {
    NSLog(@"[Cleanup] 强制清理所有资源");
    
    // 1. 立即停止画中画
    if (self.pipController && self.pipController.isPictureInPictureActive) {
        NSLog(@"[Cleanup] 停止活跃的画中画");
        [self.pipController stopPictureInPicture];
    }
    
    // 2. 清理播放器
    [self cleanupPlayer];
    
    // 3. 清理画中画组件
    [self cleanupPictureInPicture];
}

/**
 * Step 5: 播放器资源清理
 *
 * 方案1：stop + destroy，适用于通用场景；释放操作有耗时，会阻塞当前线程，直到资源完全释放。
 * 方案2：destroyAsync，无需手动 stop，适用于短剧等场景；异步释放资源，不阻塞线程，内部已自动调用 stop。
 * 注意：执行 destroy 或 destroyAsync 后，请不要再对播放器实例进行任何操作。
 */
- (void)cleanupPlayer {
    if (self.player) {
        // 5.1 停止播放
        [self.player stop];
        
        // 5.2 清理渲染代理，避免回调
        [self.player setRenderingDelegate:nil];
        
        // 5.3 销毁播放器实例
        [self.player destroy];
        
        // 5.4 清空引用，避免内存泄漏
        self.player = nil;
        
        NSLog(@"[Step 5] 播放器资源清理完成");
    }
}

// Step 5: 画中画资源清理
- (void)cleanupPictureInPicture {
    // 清理画中画控制器
    if (self.pipController) {
        self.pipController.delegate = nil;
        self.pipController = nil;
    }
    
    // 清理显示层
    if (self.pipDisplayLayer) {
        [self.pipDisplayLayer flush];
        
        if (self.pipDisplayLayer.controlTimebase) {
            CMTimebaseSetRate(self.pipDisplayLayer.controlTimebase, 0.0);
        }
        
        [self.pipDisplayLayer removeFromSuperlayer];
        self.pipDisplayLayer = nil;
    }
    
    // 清理视图
    if (self.pipView) {
        [self.pipView removeFromSuperview];
        self.pipView = nil;
    }
    
    NSLog(@"[Step 5] 画中画资源清理完成");
}

#pragma mark - AVPictureInPictureSampleBufferPlaybackDelegate

// Step 4: 处理画中画播放控制
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
                        setPlaying:(BOOL)playing {
    if (playing) {
        [self.player start];
        [self setPictureInPicturePaused:NO];
    } else {
        [self.player pause];
        [self setPictureInPicturePaused:YES];
    }
    
    // 通知系统播放状态可能已变更
    if (@available(iOS 15.0, *)) {
        [pictureInPictureController invalidatePlaybackState];
    }
}

// 返回当前播放状态
- (BOOL)pictureInPictureControllerIsPlaybackPaused:(AVPictureInPictureController *)pictureInPictureController {
    return self.isPipPaused;
}

// 处理快进/快退操作
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
                    skipByInterval:(CMTime)skipInterval
                 completionHandler:(void (^)(void))completionHandler {
    [self handleSkipOperation:skipInterval completionHandler:completionHandler];
}

// 处理跳转操作
- (void)handleSkipOperation:(CMTime)skipInterval completionHandler:(void (^)(void))completionHandler {
    // 获取当前播放位置
    int64_t currentPos = self.player.currentPosition > 0 ? self.player.currentPosition : self.currentPosition;
    
    // 计算目标位置
    double skipSeconds = CMTimeGetSeconds(skipInterval);
    int64_t skipMilliseconds = (int64_t)(skipSeconds * 1000);
    int64_t targetPosition = currentPos + skipMilliseconds;
    
    // 边界检查
    targetPosition = MAX(0, MIN(targetPosition, self.player.duration));
    
    NSLog(@"[PiP] 跳转: %lld -> %lld (偏移: %lld ms)", currentPos, targetPosition, skipMilliseconds);
    
    // 执行跳转
    [self.player seekToTime:targetPosition seekMode:AVP_SEEKMODE_ACCURATE];
    self.currentPosition = targetPosition;
    
    // 更新播放状态
    if (@available(iOS 15.0, *)) {
        [self.pipController invalidatePlaybackState];
    }
    
    if (completionHandler) {
        completionHandler();
    }
}

// 返回播放时间范围
- (CMTimeRange)pictureInPictureControllerTimeRangeForPlayback:(AVPictureInPictureController *)pictureInPictureController {
    if (!self.pipDisplayLayer.controlTimebase) {
        return CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity);
    }
    
    return [self calculatePlaybackTimeRange];
}

// 计算播放时间范围
- (CMTimeRange)calculatePlaybackTimeRange {
    CMTime currentTime = CMTimebaseGetTime(self.pipDisplayLayer.controlTimebase);
    
    if (self.player.duration > 0 && self.currentPosition >= 0) {
        double currentSeconds = self.currentPosition / 1000.0;
        double durationSeconds = self.player.duration / 1000.0;
        double currentTimeSeconds = CMTimeGetSeconds(currentTime);
        
        double startTime = currentTimeSeconds - currentSeconds;
        double endTime = currentTimeSeconds + (durationSeconds - currentSeconds);
        
        CMTime t1 = CMTimeMakeWithSeconds(startTime, currentTime.timescale);
        CMTime t2 = CMTimeMakeWithSeconds(endTime, currentTime.timescale);
        
        return CMTimeRangeFromTimeToTime(t1, t2);
    }
    
    return CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity);
}

// 是否禁止后台音频播放
- (BOOL)pictureInPictureControllerShouldProhibitBackgroundAudioPlayback:(AVPictureInPictureController *)pictureInPictureController {
    return YES; // 允许后台音频
}

// 画中画窗口尺寸变化
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
           didTransitionToRenderSize:(CMVideoDimensions)newRenderSize {
    NSLog(@"[PiP] 窗口尺寸变化: %dx%d", newRenderSize.width, newRenderSize.height);
}

#pragma mark - AVPictureInPictureControllerDelegate

// 画中画即将开始
- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"[PiP] 即将开始画中画");
}

// 画中画已开始
- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"[PiP] 画中画已开始");
    
    // 确保播放器继续运行
    [self.player start];
    [self setPictureInPicturePaused:NO];
    
    // 启动控制时间基准
    if (self.pipDisplayLayer.controlTimebase) {
        CMTimebaseSetTime(self.pipDisplayLayer.controlTimebase, kCMTimeZero);
        CMTimebaseSetRate(self.pipDisplayLayer.controlTimebase, 1.0);
    }
}

// 画中画即将停止
- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"[PiP] 即将停止画中画");
}

// 画中画已停止
- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"[PiP] 画中画已停止");
    
    // 恢复应用内播放
    if (!self.isPipPaused) {
        [self.player start];
    }
}

// 画中画启动失败
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
   failedToStartPictureInPictureWithError:(NSError *)error {
    NSLog(@"[PiP] 画中画启动失败: %@", error.localizedDescription);
}

// 恢复用户界面
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
   restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler {
    NSLog(@"[PiP] 恢复用户界面");
    
    // TODO: 在这里执行 UI 恢复操作
    
    if (completionHandler) {
        completionHandler(YES);
    }
}

#pragma mark - AVPDelegate

// 监听播放器当前播放位置
- (void)onCurrentPositionUpdate:(AliPlayer *)player position:(int64_t)position {
    self.currentPosition = position;
}

#pragma mark - CicadaRenderingDelegate

// Step 3: 处理视频帧渲染
- (BOOL)onRenderingFrame:(CicadaFrameInfo *)frameInfo {
    if (!frameInfo || !frameInfo.video_pixelBuffer) {
        return NO;
    }
    return [self enqueuePixelBufferForDisplay:frameInfo.video_pixelBuffer];
}

@end
