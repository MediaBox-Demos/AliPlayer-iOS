//
//  PictureInPictureViewController.m
//  PictureInPicture
//
//  Created by aqi on 2025/6/23.
//

#import "PictureInPictureViewController.h"
#import <AliyunPlayer/AliyunPlayer.h>
#import <Common/Common.h>

@interface PictureInPictureViewController () <AVPDelegate, AliPlayerPictureInPictureDelegate>
// 播放器实例
@property (nonatomic, strong) AliPlayer *player;
// 播放器视图容器
@property (nonatomic, strong) UIView *playerView;

@property (nonatomic, strong) UIButton *pipBtn;

// 主动画中画
@property (nonatomic, assign) BOOL isPipEnable;

// 监听画中画当前是否是暂停状态
@property (nonatomic, assign) BOOL isPipPaused;
// 监听播放器当前的播放状态，通过监听播放事件状态变更newStatus回调设置
@property (nonatomic, assign) AVPStatus currentPlayerStatus;
// 设置画中画控制器，在画中画即将启动的回调方法中设置，并需要在页面准备销毁时主动将其设置为nil，建议设置
@property (nonatomic, weak) AVPictureInPictureController *pipController;
// 监听播放器当前播放进度，currentPosition设置为监听视频当前播放位置回调中的position参数值
@property (nonatomic, assign) int64_t currentPosition;

@end

@implementation PictureInPictureViewController

#pragma mark - View Layout

// 视图加载完毕后的初始化设置
- (void)viewDidLoad {
    [super viewDidLoad];
    [AliPrivateService initLicenseService];
    //    self.title = AppGetString(@"basicplayback.title");
    self.view.backgroundColor = [UIColor blackColor];

    [self initView];

    // Step 1: 创建播放器实例
    [self setupPlayer];

    // Step 2 & Step 3: 设置播放源并开始播放
    [self startPlayback];
}

// 释放资源
- (void)dealloc {
    // 释放播放器资源
    [self cleanupPlayer];

    NSLog(@"[dealloc] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - Player Methods

// Step 1 初始化UI
- (void)initView {
    // 0.1 创建用于承载播放画面的视图容器
    self.playerView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.playerView];

    // 0.2 创建用于主动唤出画中画的按钮
    self.pipBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 2 - 40, self.view.bounds.size.height - 85, 80, 50)];
    self.pipBtn.layer.cornerRadius = 10;
    self.pipBtn.clipsToBounds = YES;
    if (@available(iOS 13.0, *)) {
        self.pipBtn.backgroundColor = [UIColor systemTealColor];
    } else {
        // 回退到自定义颜色
        self.pipBtn.backgroundColor = [UIColor colorWithRed:135.0 / 255.0 green:206.0 / 255.0 blue:235.0 / 255.0 alpha:1.0];
    }

    NSString *title = AppGetString(@"pip.btn.title");
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName : self.pipBtn.titleLabel.font}];
    self.pipBtn.frame = CGRectMake(self.view.bounds.size.width / 2 - (size.width / 2 + 10), self.view.bounds.size.height - 85, size.width + 20, 50);

    [self.pipBtn setTitle:title forState:UIControlStateNormal];
    [self.pipBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    // 点击事件
    [self.pipBtn addTarget:self action:@selector(showPip:) forControlEvents:UIControlEventTouchUpInside];

    self.isPipEnable = YES;

    [self.view addSubview:self.pipBtn];
}

// Step 2: 创建播放器实例
- (void)setupPlayer {
    // 2.1 创建播放器实例
    self.player = [[AliPlayer alloc] init];

    // 2.2 设置播放器渲染视图
    self.player.playerView = self.playerView;

    // 配置代理
    [self.player setDelegate:self];
    // 配置画中画代理
    [self.player setPictureinPictureDelegate:self];

    NSLog(@"[Step 1] 播放器创建完成: %@", self.player);
}

// Step 3: 设置播放源&&开始播放
- (void)startPlayback {
    //  创建播放源对象并设置播放地址
    AVPVidAuthSource *authSource = [[AVPVidAuthSource alloc]init];
    [authSource setVid:kSampleVideoId];
    [authSource setPlayAuth:kSampleVideoAuth];
    
    [self.player setAuthSource:authSource];

    // 准备播放
    [self.player prepare];
    // 开始播放
    [self.player start];

    NSLog(@"[Step 2&3] 开始播放视频: %@", kSampleVideoURL);
}

// Step 4: 资源清理
- (void)cleanupPlayer {
    if (self.player) {
        // 4.1 停止播放
        [self.player stop];

        // 4.2 销毁播放器实例
        [self.player destroy];

        // 4.3 清空引用，避免内存泄漏
        self.player = nil;

        NSLog(@"[Step 4] 播放器资源清理完成");
    }
}

- (void)showPip:(UIButton *)sender {
    NSLog(@"%@  showPip click", NSStringFromClass([self class]));
    if (self.pipController == nil) {
        return;
    }

    if (self.isPipEnable) {
        NSLog(@"%@  showPip true", NSStringFromClass([self class]));
        // close auto active PIP
        self.pipController.canStartPictureInPictureAutomaticallyFromInline = false;
        // start pip
        [self.pipController startPictureInPicture];
        self.isPipEnable = NO;
    } else {
        NSLog(@"%@  closePip true", NSStringFromClass([self class]));
        [self.pipController stopPictureInPicture];
        self.isPipEnable = YES;
    }
}

/**
 * 监听播放器状态回调
 */
- (void)onPlayerStatusChanged:(AliPlayer *)player oldStatus:(AVPStatus)oldStatus newStatus:(AVPStatus)newStatus {
    self.currentPlayerStatus = newStatus;

    if (self.pipController) {
        [self.pipController invalidatePlaybackState];
    }
}

/**
 * @brief 播放器事件状态回调
 */
- (void)onPlayerEvent:(AliPlayer *)player eventType:(AVPEventType)eventType {
    switch (eventType) {
        case AVPEventPrepareDone: {
            [self.player setPictureInPictureEnable:true];
        } break;
        case AVPEventCompletion: {
            self.isPipPaused = YES;
        } break;
        case AVPEventLoadingStart: {
            self.isPipPaused = YES;
        } break;
        case AVPEventLoadingEnd: {
            self.isPipPaused = NO;
        } break;
        default:
            break;
    }

    if (self.pipController) {
        [self.pipController invalidatePlaybackState];
    }
}

/**
 @brief 视频当前播放位置回调
 @param player 播放器player指针
 @param position 视频当前播放位置
 */
- (void)onCurrentPositionUpdate:(AliPlayer *)player position:(int64_t)position {
    // 更新进度条
    self.currentPosition = position;
}

#pragma mark--  AliPlayerPictureInPictureDelegate

/**
 * @brief 画中画即将开始显示
 */
- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    if (!self.pipController) {
        self.pipController = pictureInPictureController;
    }

    if (self.pipController) {
        [self.pipController invalidatePlaybackState];
    }
    self.isPipPaused = !(self.currentPlayerStatus == AVPStatusStarted);
    [pictureInPictureController invalidatePlaybackState];
}

/**
 @brief 画中画准备停止
 @param pictureInPictureController 画中画控制器
 */
- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    self.isPipPaused = NO;
    [pictureInPictureController invalidatePlaybackState];
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController setPlaying:(BOOL)playing {
    if (!playing) {
        [self.player pause];
        _isPipPaused = YES;
    } else {
        [self.player start];
        _isPipPaused = NO;
    }
    [pictureInPictureController invalidatePlaybackState];
}

/**
 * @brief 快进/快退
 */
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController skipByInterval:(CMTime)skipInterval completionHandler:(void (^)(void))completionHandler {
    NSLog(@"%@  skipByInterval  position %lld, value %lld", NSStringFromClass([self class]), self.currentPosition, skipInterval.value);
    int64_t skipTime = skipInterval.value / skipInterval.timescale;
    int64_t skipPosition = self.currentPosition + skipTime * 1000;
    if (skipPosition < 0) {
        skipPosition = 0;
    } else if (skipPosition > self.player.duration) {
        skipPosition = self.player.duration;
    }
    [self.player seekToTime:skipPosition seekMode:AVP_SEEKMODE_ACCURATE];
    [pictureInPictureController invalidatePlaybackState];
}

- (BOOL)pictureInPictureControllerIsPlaybackPaused:(nonnull AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"%@ pictureInPictureControllerIsPlaybackPaused pip paused %d", NSStringFromClass([self class]), self.isPipPaused);
    return self.isPipPaused;
}

- (CMTimeRange)pictureInPictureControllerTimeRangeForPlayback:(nonnull AVPictureInPictureController *)pictureInPictureController layerTime:(CMTime)layerTime {
    NSLog(@"%@ pictureInPictureControllerTimeRangeForPlayback current position is %lld, duration is %lld\n", NSStringFromClass([self class]), self.currentPosition, self.player.duration);
    Float64 current64 = CMTimeGetSeconds(layerTime);

    Float64 start;
    Float64 end;

    if (self.currentPosition <= self.player.duration) {
        double curPostion = self.currentPosition / 1000.0;
        double duration = self.player.duration / 1000.0;
        double interval = duration - curPostion;
        start = current64 - curPostion;
        end = current64 + interval;
        CMTime t1 = CMTimeMakeWithSeconds(start, layerTime.timescale);
        CMTime t2 = CMTimeMakeWithSeconds(end, layerTime.timescale);
        return CMTimeRangeFromTimeToTime(t1, t2);
    } else {
        return CMTimeRangeMake(kCMTimeNegativeInfinity, kCMTimePositiveInfinity);
    }
}

- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"%@ pictureInPictureControllerDidStartPictureInPicture", NSStringFromClass([self class]));
    [pictureInPictureController invalidatePlaybackState];
}

- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"%@ pictureInPictureControllerDidStopPictureInPicture", NSStringFromClass([self class]));
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler {
    NSLog(@"%@ restoreUserInterfaceForPictureInPictureStopWithCompletionHandler", NSStringFromClass([self class]));
    completionHandler(YES);
}

- (void)pictureInPictureController:(nonnull AVPictureInPictureController *)pictureInPictureController didTransitionToRenderSize:(CMVideoDimensions)newRenderSize {
    NSLog(@"%@ didTransitionToRenderSize width:%d, height:%d", NSStringFromClass([self class]), newRenderSize.width, newRenderSize.height);
}

- (void)pictureInPictureControllerIsPictureInPictureEnable:(AVPictureInPictureController *)pictureInPictureController isEnable:(BOOL)isEnable {
    NSLog(@"%@  pictureInPictureControllerIsPictureInPictureEnable : %@", NSStringFromClass([self class]), (isEnable == YES) ? @"YES" : @"No");
    if (isEnable && pictureInPictureController) {
        _pipController = pictureInPictureController;
        // close pip auto start
        if (@available(iOS 15.0, *)) {
            _pipController.canStartPictureInPictureAutomaticallyFromInline = false;
        }
    }
}

@end
