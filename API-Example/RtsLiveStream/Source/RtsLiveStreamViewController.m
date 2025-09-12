//
//  RtsLiveStreamViewController.m
//  RtsLiveStream
//
//  Created by aqi on 2025/6/11.
//

#import "RtsLiveStreamViewController.h"
#import "AliyunPlayer/AliyunPlayer.h"
#import <Common/Common.h>
#import <Common/ToastUtils.h>

@interface RtsLiveStreamViewController () <AVPDelegate>
// 播放器实例
@property (nonatomic, strong) AliPlayer *player;
// 播放器视图容器
@property (nonatomic, strong) UIView *playerView;

@end

@implementation RtsLiveStreamViewController


#pragma mark - View Lifecycle

/**
 * 页面加载完成时调用
 * 执行初始化操作：
 * 1. 设置页面标题和背景色
 * 2. 校验播放地址是否配置
 * 3. 初始化播放器并开始播放
 */
- (void)viewDidLoad {
    [super viewDidLoad];

    // 设置页面标题
    self.title = AppGetString(@"rtsLiveStream.title");
    // 设置背景为黑色（适配全屏播放）
    self.view.backgroundColor = [UIColor blackColor];

    // Step 1: 检查流地址是否已配置
    if (!kRTSLiveStreamURL || kRTSLiveStreamURL.length == 0) {
        // 提示用户先设置流地址
        [ToastUtils showToastWithMessage:AppGetString(@"set_stream_url_first.tip") inView:self.view];
        return;
    }

    // Step 2: 创建播放器资源
    [self setupPlayer];

    // Step 3: 配置播放源并启动播放流程
    [self startPlayback];
}


/**
 * 控制器销毁时释放资源
 * 确保播放器被正确停止和销毁，避免内存泄漏或后台播放
 */
- (void)dealloc {
    // 清理播放器相关资源
    [self cleanupPlayer];

    NSLog(@"[dealloc] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
}



#pragma mark - Player Setup & Control

/**
 * Step 1: 初始化播放器实例并创建渲染视图
 *
 * 流程说明：
 * 1. 创建 AliPlayer 实例
 * 2. 设置代理以接收事件回调
 * 3. 配置全局选项（如开启 RTS 自动降级）
 * 4. 创建用于显示画面的 UIView 容器，并绑定到播放器
 */
- (void)setupPlayer {
    // 1.1 创建播放器对象
    self.player = [[AliPlayer alloc] init];
    // 设置事件代理，用于接收播放状态通知
    self.player.delegate = self;

    // 全局设置：启用 RTS 流自动降级功能（默认开启）
    // 当网络不佳时，SDK 可自动切换至普通直播流保障连续性
    [AliPlayerGlobalSettings setOption:ALLOW_RTS_DEGRADE valueInt:1];

    // 可选功能：自定义降级流地址（当前未启用）
    // AVPUrlSource *urlSource = [[AVPUrlSource alloc] urlWithString:downgradeUrl];
    // AVPConfig *config = [self.player getConfig];
    // [self.player enableDowngrade:urlSource config:config];

    // 可选功能：启用单点追查 TraceID（用于异常排查）
    // traceId 应为用户或设备唯一标识（如 userID / IMEI）
    // [self.player setTraceID:traceId];

    // 1.2 创建承载视频画面的容器视图
    self.playerView = [[UIView alloc] initWithFrame:self.view.bounds];
    // 将视图添加到主界面
    [self.view addSubview:self.playerView];
    // 绑定该视图为播放器渲染目标
    self.player.playerView = self.playerView;

    NSLog(@"[Step 1] 播放器创建完成: %@", self.player);
}


/**
 * Step 2 & 3: 配置播放参数、设置播放源并准备播放
 *
 * 执行流程：
 * 1. 获取当前配置对象
 * 2. 根据协议类型（artc://）调整缓冲策略以降低延迟
 * 3. 应用配置到播放器
 * 4. 设置播放地址
 * 5. 调用 prepare 进入准备阶段
 * 6. 调用 start 发起播放请求（prepare 完成后会自动起播）
 */
- (void)startPlayback {
    // 1. 获取播放器当前配置以便修改
    AVPConfig *config = self.player.getConfig;

    // 若使用阿里云低延时协议 ARTC，则优化缓存策略以实现超低延迟
    if ([kRTSLiveStreamURL hasPrefix:@"artc://"]) {
        // 最大允许延迟时间设为 1 秒（毫秒单位）
        [config setMaxDelayTime:1000];
        // 起播时最小缓冲时长（单位：毫秒）
        [config setStartBufferDuration:10];
        // 卡顿时最大缓冲上限（单位：毫秒）
        [config setHighBufferDuration:10];
    }

    // 2. 将修改后的配置应用回播放器
    [self.player setConfig:config];

    // Step 2: 创建播放源并指定流地址
    AVPUrlSource *urlSource = [[AVPUrlSource alloc] urlWithString:kRTSLiveStreamURL];
    [self.player setUrlSource:urlSource];

    // Step 3: 开始准备播放（异步过程）
    [self.player prepare];

    // 注意：prepare 后可立即调用 start
    // 实际起播将在 onPrepared 回调中由 SDK 自动触发
    [self.player start];

    NSLog(@"[Step 2&3] 开始播放视频: %@", kRTSLiveStreamURL);
}


/**
 * Step 4: 释放播放器资源
 *
 * 清理流程：
 * 1. 停止播放
 * 2. 销毁播放器实例（释放内部解码器、网络等资源）
 * 3. 置空引用，防止野指针
 */
- (void)cleanupPlayer {
    if (self.player) {
        // 4.1 停止当前播放任务
        [self.player stop];

        // 4.2 销毁播放器，彻底释放系统资源
        [self.player destroy];

        // 4.3 断开强引用，帮助 ARC 回收内存
        self.player = nil;

        NSLog(@"[Step 4] 播放器资源清理完成");
    }
}



#pragma mark - AVPDelegate Event Handlers

/**
 * 播放器事件回调（通用事件）
 *
 * 处理特定播放事件，例如：
 * - 准备完成：触发自动播放
 */
- (void)onPlayerEvent:(AliPlayer *)player eventType:(AVPEventType)eventType {
    switch (eventType) {
        case AVPEventPrepareDone:
            // 播放器已准备好，显式调用 start 确保开始播放
            // （尽管 prepare 后通常自动播放，但此处双重保险）
            [self.player start];
            break;

        default:
            // 其他事件暂不做处理
            break;
    }
}


/**
 * 播放器字符串型事件回调
 *
 * 主要用于接收调试信息或追踪 ID
 */
- (void)onPlayerEvent:(AliPlayer *)player eventWithString:(AVPEventWithString)eventWithString description:(NSString *)description {
    switch (eventWithString) {
        case EVENT_PLAYER_DEMUXER_TRACE_ID: {
            // 收到解复用器生成的 TRACEID，可用于阿里云后台单点追查
            NSString *traceId = description;
            NSLog(@"TRACEID: %@", traceId);
            break;
        }

        default:
            // 其他字符串事件未处理
            break;
    }
}


/**
 * 错误事件回调
 *
 * 接收播放过程中发生的错误模型
 * 当前未做具体处理，可根据业务需求扩展错误提示或重试机制
 */
- (void)onError:(AliPlayer *)player errorModel:(AVPErrorModel *)errorModel {
    // TODO: 可在此处添加错误上报、UI 提示或自动重连逻辑
    // 示例：
    // [[NSNotificationCenter defaultCenter] postNotificationName:@"PlaybackError" object:errorModel];
}


@end
