//
//  PipDisplayLayerViewController.m
//  PipDisplayLayer
//
//  Created by junhui ye on 2025/10/21.
//

#import "PipDisplayLayerViewController.h"
#import <AliyunPlayer/AliyunPlayer.h>
#import <Common/Common.h>

@interface PipDisplayLayerViewController () <AVPDelegate, AVPictureInPictureSampleBufferPlaybackDelegate, AVPictureInPictureControllerDelegate, CicadaRenderingDelegate>

@property (nonatomic, strong) AliPlayer *player;
@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, assign) int64_t currentPosition;
@property (nonatomic, assign) int64_t playerDuration;
@property (nonatomic, assign) AVPStatus currentPlayerStatus;

@property (nonatomic, strong) UIView *pipView;
@property (nonatomic, strong) AVSampleBufferDisplayLayer *pipDisplayLayer;
@property (nonatomic, strong) AVPictureInPictureController *pipController;
@property (nonatomic, assign) BOOL isPipPaused;

@property (nonatomic, strong) UIButton *pipButton;

@end

@implementation PipDisplayLayerViewController

#pragma mark - View Lifecycle

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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (self.isMovingFromParentViewController || self.isBeingDismissed) {
        NSLog(@"[Lifecycle] Page is being dismissed, force cleanup");
        [self forceCleanupResources];
    }
}

- (void)dealloc {
    [self cleanupPlayer];
    [self cleanupPictureInPicture];
    NSLog(@"[dealloc] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - Step 1: 初始化视图和播放器

- (void)setupViews {
    self.playerView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.playerView];
    [self setupPipButton];
    NSLog(@"[Step 1] 视图初始化完成");
}

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

- (void)setupPlayer {
    // 1.1 创建播放器实例
    self.player = [[AliPlayer alloc] init];

    // 1.2 设置播放器渲染视图和代理
    self.player.playerView = self.playerView;
    self.player.delegate = self;
    [self.player setRenderingDelegate:self];

    // 1.3 设置播放器场景
    [self.player setPlayerScene:SceneLong];

    // 1.4 开启后台解码能力（画中画必需）
    [self.player setOption:ALLOW_DECODE_BACKGROUND valueInt:1];

    // 可选：推荐使用`播放器单点追查`功能
    // [self.player setTraceID:traceId];

    NSLog(@"[Step 1] 播放器创建完成: %@", self.player);
}

#pragma mark - Step 2: 初始化画中画组件

- (void)setupPictureInPicture {
    if (![self isPictureInPictureSupported]) {
        NSLog(@"[Step 2] 画中画功能不支持，跳过初始化");
        return;
    }

    // 2.1 创建画中画视图容器（置于 playerView 之下）
    self.pipView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:self.pipView belowSubview:self.playerView];

    // 2.2 创建 AVSampleBufferDisplayLayer
    [self setupDisplayLayer];

    // 2.3 创建画中画控制器
    [self setupPipController];

    NSLog(@"[Step 2] 画中画组件初始化完成");
}

- (void)setupDisplayLayer {
    self.pipDisplayLayer = [AVSampleBufferDisplayLayer layer];

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.pipDisplayLayer.frame = CGRectMake(0, 0, screenWidth, screenHeight);

    // videoGravity 控制画中画窗口中视频帧的填充方式，
    // 与播放器 scalingMode 语义对应关系：
    //   AVP_SCALINGMODE_SCALETOFILL    -> AVLayerVideoGravityResize            (拉伸填充)
    //   AVP_SCALINGMODE_SCALEASPECTFIT -> AVLayerVideoGravityResizeAspect      (等比适应，默认)
    //   AVP_SCALINGMODE_SCALEASPECTFILL-> AVLayerVideoGravityResizeAspectFill  (等比裁剪)
    self.pipDisplayLayer.videoGravity = AVLayerVideoGravityResizeAspect;

    [self setupControlTimebase];
    [self.pipView.layer addSublayer:self.pipDisplayLayer];

    NSLog(@"[Step 2] DisplayLayer 创建完成，尺寸: %.0fx%.0f", screenWidth, screenHeight);
}

- (void)setupControlTimebase {
    CMTimebaseRef controlTimebase = NULL;
    OSStatus status = CMTimebaseCreateWithSourceClock(kCFAllocatorDefault,
                                                     CMClockGetHostTimeClock(),
                                                     &controlTimebase);
    if (status == noErr && controlTimebase) {
        self.pipDisplayLayer.controlTimebase = controlTimebase;
        CMTimebaseSetTime(controlTimebase, kCMTimeZero);
        CMTimebaseSetRate(controlTimebase, 0.0);
        CFRelease(controlTimebase);
        NSLog(@"[Step 2] 控制时间基准创建成功");
    } else {
        NSLog(@"[Step 2] 控制时间基准创建失败: %d", status);
    }
}

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

#pragma mark - Step 3: 开始播放

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

#pragma mark - Picture in Picture Control

- (BOOL)isPictureInPictureSupported {
    if (@available(iOS 15.0, *)) {
        return [AVPictureInPictureController isPictureInPictureSupported];
    }
    return NO;
}

- (BOOL)isPictureInPictureAvailable {
    return [self isPictureInPictureSupported] && self.pipController != nil;
}

- (void)startPictureInPicture {
    if (![self isPictureInPictureAvailable]) {
        NSLog(@"[PiP] 画中画功能不可用，无法启动");
        return;
    }

    NSLog(@"[PiP] 启动画中画: possible=%d, active=%d",
          (int)self.pipController.isPictureInPicturePossible,
          (int)self.pipController.isPictureInPictureActive);

    [self.pipController startPictureInPicture];
}

- (void)stopPictureInPicture {
    if (![self isPictureInPictureAvailable]) {
        NSLog(@"[PiP] 画中画功能不可用，无法停止");
        return;
    }

    NSLog(@"[PiP] 停止画中画");
    [self.pipController stopPictureInPicture];
}

- (void)togglePiPState:(BOOL)isPaused {
    if (![self isPictureInPictureAvailable]) {
        return;
    }
    if (self.isPipPaused == isPaused) {
        return;
    }

    self.isPipPaused = isPaused;
    NSLog(@"[PiP] 画中画状态: %@", isPaused ? @"暂停" : @"播放");
}

#pragma mark - Video Frame Processing

// 将 CVPixelBuffer 封装为 CMSampleBuffer 并送入 pipDisplayLayer 显示。
// 返回 YES 时不渲染 playerView，返回 NO 时同时渲染 pipDisplayLayer 和 playerView。
- (BOOL)enqueuePixelBufferForImmediateDisplay:(CVPixelBufferRef)pixelBuffer {
    static CMTime lastPresentationTime = {0};
    static BOOL isFirstFrame = YES;

    if (!pixelBuffer || !self.pipDisplayLayer) {
        return NO;
    }

    if (self.pipDisplayLayer.status == AVQueuedSampleBufferRenderingStatusFailed) {
        NSLog(@"[PiP] DisplayLayer failed, flushing...");
        [self.pipDisplayLayer flush];
        isFirstFrame = YES;

        if (self.pipDisplayLayer.controlTimebase) {
            CMTimebaseSetTime(self.pipDisplayLayer.controlTimebase, kCMTimeZero);
            CMTimebaseSetRate(self.pipDisplayLayer.controlTimebase, self.isPipPaused ? 0.0 : 1.0);
        }
        return NO;
    }

    if (!self.pipDisplayLayer.isReadyForMoreMediaData) {
        return NO;
    }

    CMVideoFormatDescriptionRef videoInfo = NULL;
    OSStatus err = CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
    if (err != noErr || !videoInfo) {
        NSLog(@"[PiP] Failed to create video format description: %d", err);
        return NO;
    }

    CMTime presentationTime;
    if (self.pipDisplayLayer.controlTimebase) {
        presentationTime = CMTimebaseGetTime(self.pipDisplayLayer.controlTimebase);
    } else {
        if (isFirstFrame) {
            presentationTime = kCMTimeZero;
            isFirstFrame = NO;
        } else {
            CMTime increment = CMTimeMake(1, 30);
            presentationTime = CMTimeAdd(lastPresentationTime, increment);
        }
    }
    lastPresentationTime = presentationTime;

    CMSampleTimingInfo timing = {
        .duration = CMTimeMake(1, 30),
        .presentationTimeStamp = presentationTime,
        .decodeTimeStamp = presentationTime,
    };

    CMSampleBufferRef sampleBuffer = NULL;
    err = CMSampleBufferCreateReadyWithImageBuffer(kCFAllocatorDefault,
                                                   pixelBuffer,
                                                   videoInfo,
                                                   &timing,
                                                   &sampleBuffer);
    CFRelease(videoInfo);

    if (err != noErr || !sampleBuffer) {
        NSLog(@"[PiP] Failed to create sample buffer: %d", err);
        return NO;
    }

    [self.pipDisplayLayer enqueueSampleBuffer:sampleBuffer];
    CFRelease(sampleBuffer);

    return NO;
}

#pragma mark - Event Handlers

- (void)pipButtonTapped:(UIButton *)sender {
    if (self.pipController) {
        [self startPictureInPicture];
    }
}

#pragma mark - Step 5: 资源清理

- (void)forceCleanupResources {
    NSLog(@"[Cleanup] 强制清理所有资源");

    if (self.pipController && self.pipController.isPictureInPictureActive) {
        NSLog(@"[Cleanup] 停止活跃的画中画");
        [self.pipController stopPictureInPicture];
    }

    [self cleanupPlayer];
    [self cleanupPictureInPicture];
}

/**
 * 播放器资源清理
 *
 * 方案1：stop + destroy，适用于通用场景；释放操作有耗时，会阻塞当前线程。
 * 方案2：destroyAsync，无需手动 stop，适用于短剧等场景；异步释放资源，不阻塞线程。
 * 注意：执行 destroy 或 destroyAsync 后，请不要再对播放器实例进行任何操作。
 */
- (void)cleanupPlayer {
    if (self.player) {
        // 解绑播放器视图
        self.player.playerView = nil;
        [self.player stop];
        [self.player setRenderingDelegate:nil];
        [self.player destroy];
        self.player = nil;
        NSLog(@"[Step 5] 播放器资源清理完成");
    }
}

- (void)cleanupPictureInPicture {
    if (self.pipController) {
        self.pipController.delegate = nil;
        self.pipController = nil;
    }

    if (self.pipDisplayLayer) {
        [self.pipDisplayLayer flush];
        if (self.pipDisplayLayer.controlTimebase) {
            CMTimebaseSetRate(self.pipDisplayLayer.controlTimebase, 0.0);
        }
        [self.pipDisplayLayer removeFromSuperlayer];
        self.pipDisplayLayer = nil;
    }

    if (self.pipView) {
        [self.pipView removeFromSuperview];
        self.pipView = nil;
    }

    NSLog(@"[Step 5] 画中画资源清理完成");
}

#pragma mark - Step 4: AVPictureInPictureSampleBufferPlaybackDelegate

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
                        setPlaying:(BOOL)playing {
    NSLog(@"[PiP][CBK] setPlaying called, playing=%@", playing ? @"YES" : @"NO");

    if (playing) {
        [self.player start];
        [self togglePiPState:NO];

        if (self.pipDisplayLayer.controlTimebase) {
            CMTimebaseSetRate(self.pipDisplayLayer.controlTimebase, 1.0);
        }
    } else {
        [self.player pause];
        [self togglePiPState:YES];

        if (self.pipDisplayLayer.controlTimebase) {
            CMTimebaseSetRate(self.pipDisplayLayer.controlTimebase, 0.0);
        }
    }

    if (@available(iOS 15.0, *)) {
        [pictureInPictureController invalidatePlaybackState];
    }
}

- (BOOL)pictureInPictureControllerIsPlaybackPaused:(AVPictureInPictureController *)pictureInPictureController {
    return self.isPipPaused;
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
                    skipByInterval:(CMTime)skipInterval
                 completionHandler:(void (^)(void))completionHandler {
    NSLog(@"[PiP][CBK] skipByInterval called, skipInterval=%f)", CMTimeGetSeconds(skipInterval));

    Float64 skipTime = CMTimeGetSeconds(skipInterval);
    int64_t skipPosition = self.currentPosition + skipTime * 1000;
    if (skipPosition < 0) {
        skipPosition = 0;
    } else if (skipPosition > self.playerDuration) {
        skipPosition = self.playerDuration;
    }

    NSLog(@"[PiP] 跳转: %lld -> %lld (偏移: %f ms)", self.currentPosition, skipPosition, skipTime * 1000);

    [self.player seekToTime:skipPosition seekMode:AVP_SEEKMODE_ACCURATE];
    self.currentPosition = skipPosition;

    if (@available(iOS 15.0, *)) {
        [self.pipController invalidatePlaybackState];
    }

    if (completionHandler) {
        completionHandler();
    }
}

- (CMTimeRange)pictureInPictureControllerTimeRangeForPlayback:(AVPictureInPictureController *)pictureInPictureController {
    if (!self.pipDisplayLayer.controlTimebase) {
        return CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity);
    }

    CMTime currentTime = CMTimebaseGetTime(self.pipDisplayLayer.controlTimebase);
    Float64 current64 = CMTimeGetSeconds(currentTime);

    if (self.playerDuration > 0 && self.currentPosition >= 0) {
        double curPosition = self.currentPosition / 1000.0;
        double duration = self.playerDuration / 1000.0;
        double interval = duration - curPosition;
        Float64 start = current64 - curPosition;
        Float64 end = current64 + interval;
        CMTime t1 = CMTimeMakeWithSeconds(start, currentTime.timescale);
        CMTime t2 = CMTimeMakeWithSeconds(end, currentTime.timescale);
        return CMTimeRangeFromTimeToTime(t1, t2);
    }

    return CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity);
}

- (BOOL)pictureInPictureControllerShouldProhibitBackgroundAudioPlayback:(AVPictureInPictureController *)pictureInPictureController {
    return YES;
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
           didTransitionToRenderSize:(CMVideoDimensions)newRenderSize {
    NSLog(@"[PiP] 窗口尺寸变化: %dx%d", newRenderSize.width, newRenderSize.height);
}

#pragma mark - AVPictureInPictureControllerDelegate

- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"[PiP] 即将开始画中画");
}

- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"[PiP] 画中画已开始");

    [self.player start];
    [self togglePiPState:NO];

    if (self.pipDisplayLayer.controlTimebase) {
        CMTimebaseSetTime(self.pipDisplayLayer.controlTimebase, kCMTimeZero);
        CMTimebaseSetRate(self.pipDisplayLayer.controlTimebase, 1.0);
    }
}

- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"[PiP] 即将停止画中画");
}

- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"[PiP] 画中画已停止");

    if (!self.isPipPaused) {
        [self.player start];
    }
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
   failedToStartPictureInPictureWithError:(NSError *)error {
    if (error) {
        NSLog(@"[PiP][CBK] failedToStartPictureInPicture: domain=%@, code=%ld, desc=%@",
              error.domain,
              (long)error.code,
              error.localizedDescription);
    } else {
        NSLog(@"[PiP][CBK] failedToStartPictureInPicture: error is nil (unexpected)");
    }
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
   restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler {
    NSLog(@"[PiP][CBK] restoreUserInterfaceForPictureInPictureStop called");

    // TODO: 在这里执行 UI 恢复操作，比如 present 播放页

    if (completionHandler) {
        completionHandler(YES);
    }
}

#pragma mark - AVPDelegate

- (void)onCurrentPositionUpdate:(AliPlayer *)player position:(int64_t)position {
    self.currentPosition = position;
    self.playerDuration = player.duration;

    // 获取当前进度/时长后，更新画中画 UI，防止点播场景进度条显示为直播
    if (@available(iOS 15.0, *)) {
        if (self.pipController) {
            [self.pipController invalidatePlaybackState];
        }
    }
}

- (void)onPlayerStatusChanged:(AliPlayer *)player oldStatus:(AVPStatus)oldStatus newStatus:(AVPStatus)newStatus {
    self.currentPlayerStatus = newStatus;

    switch (newStatus) {
        case AVPStatusStarted:
            [self togglePiPState:NO];
            break;
        case AVPStatusPaused:
            [self togglePiPState:YES];
            break;
        default:
            break;
    }

    if (@available(iOS 15.0, *)) {
        if (self.pipController) {
            [self.pipController invalidatePlaybackState];
        }
    }
}

#pragma mark - CicadaRenderingDelegate (Step 3)

- (BOOL)onRenderingFrame:(CicadaFrameInfo *)frameInfo {
    if (!frameInfo || !frameInfo.video_pixelBuffer) {
        return NO;
    }
    return [self enqueuePixelBufferForImmediateDisplay:frameInfo.video_pixelBuffer];
}

@end
