//
//  BasicLiveStreamViewController.m
//  BasicLiveStream
//
//  Created by 叶俊辉 on 2025/9/11.
//

#import "BasicLiveStreamViewController.h"
#import <Common/Common.h>
#import <Common/ToastUtils.h>

@interface BasicLiveStreamViewController ()<AVPDelegate>

// 播放器实例
@property (nonatomic, strong) AliPlayer *player;
// 播放器视图容器
@property (nonatomic, strong) UIView *playerView;
// 清晰度切换按钮
@property (nonatomic, strong) UIButton *switchResolutionBtn;

@end

@implementation BasicLiveStreamViewController

#pragma mark - View Layout

// 视图加载完毕后的初始化设置
- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = AppGetString(@"basiclivestream.title");
    self.view.backgroundColor = [UIColor blackColor];
    
    // 检查流地址是否已配置
    if (!kSampleLiveStreamVideoURL || kSampleLiveStreamVideoURL.length == 0) {
        // 提示用户先设置流地址
        [ToastUtils showToastWithMessage:AppGetString(@"set_stream_url_first.tip") inView:self.view];
        return;
    }


    // Step 0: 创建播放器实例
    [self setupPlayer];

    // Step 1: 初始化视图
    [self setupPlayerView];

    // Step 2 & Step 3: 设置播放源并开始播放
    [self startPlayback];
}

// 释放资源
- (void)dealloc {
    // Step 5: 资源清理
    [self cleanupPlayer];

    NSLog(@"[dealloc] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - Player Methods

// Step 0: 创建播放器实例
- (void)setupPlayer {
    // 创建播放器实例
    self.player = [[AliPlayer alloc] init];
    
    // 设置播放器代理
    self.player.delegate = self;

    // 可选：推荐使用`播放器单点追查`功能，当使用阿里云播放器 SDK 播放视频发生异常时，可借助单点追查功能针对具体某个用户或某次播放会话的异常播放行为进行全链路追踪，以便您能快速诊断问题原因，可有效改善播放体验治理效率。
    // traceId 值由您自行定义，需为您的用户或用户设备的唯一标识符，例如传入您业务的 userid 或者 IMEI、IDFA 等您业务用户的设备 ID。
    // 传入 traceId 后，埋点日志上报功能开启，后续可以使用播放质量监控、单点追查和视频播放统计功能。
    // 文档：https://help.aliyun.com/zh/vod/developer-reference/single-point-tracing
    //[self.player setTraceID:traceId];

    NSLog(@"[Step 0] 播放器创建完成: %@", self.player);
}

/**
 * Step 1: 初始化视图组件
 *
 * 创建播放器视图容器并设置播放器渲染视图，初始化控制按钮
 */
- (void)setupPlayerView {
    // 1.1 创建用于承载播放画面的视图容器，并设置播放器渲染视图
    self.playerView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.playerView];
    self.player.playerView = self.playerView;

    // 1.2 初始化清晰度切换按钮
    self.switchResolutionBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.switchResolutionBtn setTitle:AppGetString(@"basiclivestream.switch.resolution") forState:UIControlStateNormal];
    [self.switchResolutionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.switchResolutionBtn.backgroundColor = [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:0.8];
    self.switchResolutionBtn.layer.cornerRadius = 8.0;
    self.switchResolutionBtn.frame = CGRectMake(20, 100, 120, 40);
    [self.view addSubview:self.switchResolutionBtn];

    // 1.3: 设置直播流切换功能
    [self setupStreamSwitching];
    NSLog(@"[Step 1] 播放器视图初始化完成");
}

// Step 2: 设置播放源 & Step 3: 开始播放
- (void)startPlayback {
    // Step 2: 创建播放源对象并设置播放地址
    AVPUrlSource *urlSource = [[AVPUrlSource alloc] urlWithString:kSampleLiveStreamVideoURL];
    [self.player setUrlSource:urlSource];

    // Step 3: 准备播放
    [self.player prepare];
    // prepare 以后可以同步调用 start 操作，onPrepared 回调完成后会自动起播
    [self.player start];

    NSLog(@"[Step 2&3] 开始播放直播流: %@", kSampleLiveStreamVideoURL);
}

/**
 * 设置直播流切换
 */
- (void)setupStreamSwitching {
    // 设置清晰度切换按钮点击监听
    [self.switchResolutionBtn addTarget:self
                                 action:@selector(onSwitchResolutionButtonTapped:)
                       forControlEvents:UIControlEventTouchUpInside];

    NSLog(@"直播流切换功能设置完成");
}

#pragma mark - Button Actions

// 清晰度切换按钮点击事件
- (void)onSwitchResolutionButtonTapped:(UIButton *)sender {
    [self.player switchStream:kSampleSwitchLiveStreamVideoURL];
}

#pragma mark - AVPDelegate

// 切换成功回调
- (void)onStreamSwitchedSuccess:(AliPlayer*)player URL:(NSString*)URL {
    NSLog(@"[StreamSwitch] 切换成功: url=%@", URL);
}

// 切换失败回调
- (void)onStreamSwitchedFail:(AliPlayer*)player URL:(NSString*)URL errorModel:(AVPErrorModel *)errorModel {
    NSLog(@"[StreamSwitch] 切换失败: %@, 错误码: %ld, 错误信息: %@", URL, (long)errorModel.code, errorModel.message);
}

#pragma mark - Cleanup Methods

/**
 * Step 4: 资源清理
 *
 * 方案1：stop + destroy，适用于通用场景；释放操作有耗时，会阻塞当前线程，直到资源完全释放。
 * 方案2：destroyAsync，无需手动 stop，适用于短剧等场景；异步释放资源，不阻塞线程，内部已自动调用 stop。
 * 注意：执行 destroy 或 destroyAsync 后，请不要再对播放器实例进行任何操作。
 */
- (void)cleanupPlayer {
    if (self.player) {
        // 4.1 停止播放
        [self.player stop];

        // 4.2 销毁播放器实例
        [self.player destroy];

        // 4.3 清空引用，避免内存泄漏
        self.player = nil;

        NSLog(@"[Step 5] 播放器资源清理完成");
    }
}

@end
