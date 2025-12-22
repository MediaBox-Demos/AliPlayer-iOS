//
//  ExternalSubtitleVttViewController.m
//  ExternalSubtitleVtt
//
//  Created by 叶俊辉 on 2025/10/20.
//

#import "ExternalSubtitleVttViewController.h"
#import "AliyunPlayer/AVPDelegate.h"
#import <Common/Common.h>

// 可选（非必需）：播放起始位置
static const NSInteger kVideoStartTimeMills = 8 * 1000;

@interface ExternalSubtitleVttViewController () <AVPDelegate>

#pragma mark - 播放器相关属性
// 播放器实例
@property (nonatomic, strong) AliPlayer *player;
// 播放器视图容器
@property (nonatomic, strong) UIView *playerView;

@end

@implementation ExternalSubtitleVttViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [AliPrivateService initLicenseService];
    // 设置页面基本属性
    self.title = AppGetString(@"externalSubtitle.title");
    self.view.backgroundColor = [UIColor blackColor];

    // Step 1: 创建播放器实例
    [self setupPlayer];

    // Step 2: 初始化UI视图
    [self setupUserInterface];

    // Step 3 & Step 4: 设置播放源并播放
    [self startPlayback];
}

#pragma mark - Step 1: 播放器初始化

/**
 * Step 1: 创建播放器实例
 */
- (void)setupPlayer {
    // 1.1 创建播放器实例
    self.player = [[AliPlayer alloc] init];

    if (_player) {
        // 1.2 设置播放器代理
        _player.delegate = self;

        NSLog(@"[Step 1] 播放器实例创建成功");
    }
    // 1.3 创建用于承载播放画面的视图容器，并设置播放器渲染视图
    self.playerView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.playerView];
    self.player.playerView = self.playerView;

    // 可选：推荐使用`播放器单点追查`功能，当使用阿里云播放器 SDK 播放视频发生异常时，可借助单点追查功能针对具体某个用户或某次播放会话的异常播放行为进行全链路追踪，以便您能快速诊断问题原因，可有效改善播放体验治理效率。
    // traceId 值由您自行定义，需为您的用户或用户设备的唯一标识符，例如传入您业务的 userid 或者 IMEI、IDFA 等您业务用户的设备 ID。
    // 传入 traceId 后，埋点日志上报功能开启，后续可以使用播放质量监控、单点追查和视频播放统计功能。
    // 文档：https://help.aliyun.com/zh/vod/developer-reference/single-point-tracing
    //[self.player setTraceID:traceId];

    NSLog(@"[Step 1] 播放器创建完成: %@", self.player);
}

#pragma mark - Step 2: UI界面初始化

/**
 * Step 2: 初始化UI视图
 */
- (void)setupUserInterface {
    // 2.1 创建播放器视图容器
    [self setupPlayerView];

    NSLog(@"[Step 2] UI界面初始化完成");
}

/**
 * 2.1 创建用于承载播放画面的视图容器，并设置播放器渲染视图
 */
- (void)setupPlayerView {
    self.playerView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.playerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.playerView];

    // 设置播放器渲染视图
    self.player.playerView = self.playerView;
}

#pragma mark - Step 3 & Step 4: 播放源设置和播放准备

/**
 * Step 3: 设置播放源 & Step 4: 开始播放
 */
- (void)startPlayback {
    // Step 3: 创建播放源对象并设置播放地址
    AVPUrlSource *urlSource = [[AVPUrlSource alloc] urlWithString:kSampleVttSubtitleVideoURL];
    [self.player setUrlSource:urlSource];

    // 可选（非必需）：设置视频播放起始位置
    // AVP_SEEKMODE_ACCURATE 表示精准 seek 到指定时间戳的位置播放，AVP_SEEKMODE_INACCURATE 表示 seek 到离指定时间戳最近的关键帧位置播放
    [self.player setStartTime:kVideoStartTimeMills seekMode:AVP_SEEKMODE_INACCURATE];
    
    // Step 4: 准备播放
    [self.player prepare];
    // prepare 以后可以同步调用 start 操作，onPrepared 回调完成后会自动起播
    [self.player start];

    NSLog(@"[Step 3&4] 开始播放视频: %@", kSampleExternalSubtitleVttURL);
}

#pragma mark - Step 5 & Step 6: 播放器事件处理和字幕设置

/**
 * Step 5: 播放器事件处理
 */
- (void)onPlayerEvent:(AliPlayer *)player eventType:(AVPEventType)eventType {
    switch (eventType) {
        case AVPEventPrepareDone:
            // Step 5: 设置播放器准备完成后的处理
            [self handlePlayerPrepared:player];
            break;

        case AVPEventCompletion:
            NSLog(@"播放完成");
            break;

        case AVPEventLoadingStart:
            NSLog(@"开始加载");
            break;

        case AVPEventLoadingEnd:
            NSLog(@"加载结束");
            break;

        default:
            break;
    }
}

/**
 * 处理播放器准备完成事件
 */
- (void)handlePlayerPrepared:(AliPlayer *)player {
    // Step 5: 字幕设置（需要在准备完成后进行设置）
    if(kSampleExternalSubtitleVttURL !=Nil && kSampleExternalSubtitleVttURL.length>0){
        [self.player addExtSubtitle:kSampleExternalSubtitleVttURL];
        NSLog(@"[Step 5] 添加外挂字幕: %@", kSampleExternalSubtitleVttURL);
    }
}

/**
 * 播放器错误回调
 */
- (void)onError:(AliPlayer *)player errorModel:(AVPErrorModel *)errorModel {
    NSLog(@"播放器错误: %@", errorModel.message);
}

#pragma mark - Step 6: 字幕监听回调方法

/**
 * Step 6: 设置字幕监听
 */

/**
 * 外挂字幕被添加
 * @param player 播放器player指针
 * @param trackIndex 字幕显示的索引号
 * @param URL 字幕url
 */
- (void)onSubtitleExtAdded:(AliPlayer*)player trackIndex:(int)trackIndex URL:(NSString *)URL {
    NSLog(@"onSubtitleExtAdded: %@, trackIndex: %d", URL, trackIndex);
    [self.player selectExtSubtitle:trackIndex enable:YES];
}

#pragma mark - Step 7: 资源清理

/**
 * Step 7: 清理播放器资源
 */
- (void)cleanupPlayer {
    if (self.player) {
        // 7.1 停止播放
        [self.player stop];

        // 7.2 销毁播放器实例
        [self.player destroy];

        // 7.3 清空引用，避免内存泄漏
        self.player = nil;

        NSLog(@"[Step 7] 播放器资源清理完成");
    }
}

@end
