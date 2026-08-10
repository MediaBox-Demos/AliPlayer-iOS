//  ThumbnailViewController.m
//  Thumbnail
//
//  Created by 叶俊辉 on 2025/6/12.
//

#import "ThumbnailViewController.h"
#import "AliyunPlayer/AVPDelegate.h"
#import <Common/Common.h>

/**
 * ==================== 缩略图功能实现要点 ====================
 * iOS AliPlayer 的缩略图能力通过 AliPlayer 内置 API 提供：
 * 1. 播放器准备完成后，在 onPlayerEvent: 的 AVPEventPrepareDone 事件中从 MediaInfo 获取缩略图 URL，
 *    并调用 setThumbnailUrl: 设置缩略图 URL。
 * 2. 用户拖动进度条时，调用 getThumbnail: 请求指定位置（单位：毫秒）的缩略图。
 * 3. 结果通过 AVPDelegate 的 onGetThumbnailSuc:fromPos:toPos:image: 与 onGetThumbnailFailed: 回调返回。
 *
 * 参考文档：https://help.aliyun.com/zh/vod/developer-reference/basic-features-2
 */

@interface ThumbnailViewController () <AVPDelegate>

#pragma mark - 播放器相关属性
/// 播放器实例
@property (nonatomic, strong) AliPlayer *player;
/// 播放器视图容器
@property (nonatomic, strong) UIView *playerView;

#pragma mark - UI 控件属性
/// 进度条控件
@property (nonatomic, strong) UISlider *progressSlider;
/// 缩略图显示视图
@property (nonatomic, strong) UIImageView *thumbnailView;

#pragma mark - 状态控制属性
/// 当前 Track 是否有缩略图，没有则不展示缩略图
@property (nonatomic, assign) BOOL trackHasThumbnail;
/// 是否正在拖拽进度条
@property (nonatomic, assign) BOOL isDragging;

@end

// 缩略图视图宽度（可自定义）
static const CGFloat kThumbnailWidth = 108.0f;
// 缩略图视图高度（可自定义）
static const CGFloat kThumbnailHeight = 192.0f;

@implementation ThumbnailViewController

#pragma mark - 生命周期方法

- (void)viewDidLoad {
    [super viewDidLoad];
    [AliPrivateService initLicenseService];

    self.title = AppGetString(@"thumbnail.title");
    self.view.backgroundColor = [UIColor blackColor];

    // Step 1: 创建播放器实例
    [self setupPlayer];

    // Step 2: 初始化 UI 视图
    [self setupUserInterface];

    // Step 3 & Step 4: 设置播放源并开始播放
    [self startPlayback];

    // Step 7: 设置缩略图显示控制
    [self setupThumbnailControls];
}

- (void)dealloc {
    // Step 8: 清理资源
    [self cleanupPlayer];

    NSLog(@"[dealloc] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - Step 1: 播放器初始化

/**
 * Step 1: 创建播放器实例并设置代理
 */
- (void)setupPlayer {
    self.player = [[AliPlayer alloc] init];
    if (self.player) {
        self.player.delegate = self;
        NSLog(@"[Step 1] 播放器实例创建成功");
    }

    // 设置播放器场景
    [self.player setPlayerScene:SceneLong];
}

#pragma mark - Step 2: UI 界面初始化

/**
 * Step 2: 初始化 UI 视图
 */
- (void)setupUserInterface {
    // 2.1 创建播放器视图容器
    [self setupPlayerView];

    // 2.2 创建进度条控件
    [self setupProgressSlider];

    // 2.3 创建缩略图显示视图
    [self setupThumbnailView];

    NSLog(@"[Step 2] UI 界面初始化完成");
}

/**
 * 2.1 创建播放器视图容器，并设置播放器渲染视图
 */
- (void)setupPlayerView {
    self.playerView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.playerView];

    self.player.playerView = self.playerView;
}

/**
 * 2.2 创建并配置进度条控件
 */
- (void)setupProgressSlider {
    CGFloat sliderY = self.playerView.frame.size.height - 60.0f;
    CGFloat sliderWidth = self.view.frame.size.width - 40.0f;

    self.progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(20.0f, sliderY, sliderWidth, 30.0f)];
    self.progressSlider.minimumValue = 0.0f;
    // 滑动过程中持续发送值变化通知
    self.progressSlider.continuous = YES;

    [self.view addSubview:self.progressSlider];
}

/**
 * 2.3 创建缩略图显示视图
 */
- (void)setupThumbnailView {
    CGFloat parentViewWidth = self.playerView.frame.size.width;

    // 水平居中
    CGFloat thumbnailViewX = (parentViewWidth - kThumbnailWidth) / 2.0f;
    CGFloat thumbnailViewY = self.progressSlider.frame.origin.y - kThumbnailHeight;
    self.thumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(thumbnailViewX, thumbnailViewY, kThumbnailWidth, kThumbnailHeight)];
    self.thumbnailView.hidden = YES; // 初始隐藏

    [self.playerView addSubview:self.thumbnailView];
}

#pragma mark - Step 3 & Step 4: 播放源设置和播放准备

/**
 * Step 3: 设置播放源
 * Step 4: 准备并开始播放
 */
- (void)startPlayback {
    // Step 3: 创建 VidAuth 播放源
    AVPVidAuthSource *authSource = [[AVPVidAuthSource alloc] init];
    [authSource setVid:kSampleVideoThumbnailVid];
    [authSource setPlayAuth:kSampleVideoThumbnailAuth];
    [self.player setAuthSource:authSource];

    // Step 4: 准备播放
    [self.player prepare];
    // prepare 以后可以同步调用 start，onPrepared 回调完成后会自动起播
    [self.player start];

    NSLog(@"[Step 3&4] 开始播放视频: %@", kSampleVideoThumbnailVid);
}

#pragma mark - Step 5: 播放器准备完成事件

/**
 * Step 5: 播放器准备完成回调
 * 在此处设置进度条总时长，并从 MediaInfo 中读取缩略图 URL 触发 Step 6。
 */
- (void)onPlayerEvent:(AliPlayer *)player eventType:(AVPEventType)eventType {
    switch (eventType) {
        case AVPEventPrepareDone:
            [self handlePlayerPrepared:player];
            break;

        default:
            break;
    }
}

/**
 * 处理播放器准备完成事件
 */
- (void)handlePlayerPrepared:(AliPlayer *)player {
    // 5.1 设置进度条最大值
    self.progressSlider.maximumValue = (float)player.duration;
    NSLog(@"[Step 5] 设置进度条最大值: %.2f", self.progressSlider.maximumValue);

    // 5.2 从 MediaInfo 获取缩略图 URL 并设置
    AVPMediaInfo *mediaInfo = [self.player getMediaInfo];
    if (!mediaInfo) {
        return;
    }

    NSArray<AVPThumbnailInfo *> *thumbnailInfos = mediaInfo.thumbnails;
    if (thumbnailInfos.count == 0) {
        self.trackHasThumbnail = NO;
        NSLog(@"[Step 6] 当前视频没有缩略图");
        return;
    }

    AVPThumbnailInfo *thumbnailInfo = thumbnailInfos.firstObject;
    if (thumbnailInfo.URL.length > 0) {
        NSLog(@"[Step 6] Thumbnail URL: %@", thumbnailInfo.URL);
        [self setupThumbnailUrl:thumbnailInfo.URL];
    }
}

#pragma mark - Step 6: 缩略图回调处理

/**
 * Step 6.1: 设置缩略图 URL
 */
- (void)setupThumbnailUrl:(NSString *)thumbnailUrl {
    [self.player setThumbnailUrl:thumbnailUrl];
    self.trackHasThumbnail = YES;
    NSLog(@"[Step 6] 缩略图 URL 设置完成");
}

/**
 * Step 6.3: 获取缩略图成功回调
 */
- (void)onGetThumbnailSuc:(int64_t)positionMs
                  fromPos:(int64_t)fromPos
                    toPos:(int64_t)toPos
                    image:(id)image {
    NSLog(@"[Step 6] 获取缩略图成功 - 位置: %lld", positionMs);

    self.thumbnailView.hidden = NO;
    self.thumbnailView.image = (UIImage *)image;
}

/**
 * Step 6.4: 获取缩略图失败回调
 */
- (void)onGetThumbnailFailed:(int64_t)positionMs {
    NSLog(@"[Step 6] 获取缩略图失败 - 位置: %lld", positionMs);

    self.thumbnailView.hidden = YES;
}

#pragma mark - Step 7: 缩略图显示控制

/**
 * Step 7: 设置进度条与缩略图显示的联动监听
 */
- (void)setupThumbnailControls {
    [self.progressSlider addTarget:self action:@selector(sliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    [self.progressSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.progressSlider addTarget:self action:@selector(sliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
    [self.progressSlider addTarget:self action:@selector(sliderTouchEnded:) forControlEvents:UIControlEventTouchUpOutside];

    NSLog(@"[Step 7] 缩略图显示控制设置完成");
}

/**
 * 7.1 进度条开始拖拽
 */
- (void)sliderTouchBegan:(UISlider *)sender {
    self.isDragging = YES;
    NSLog(@"[Step 7] 开始拖拽进度条");
}

/**
 * 7.2 进度条值变化时请求缩略图
 */
- (void)sliderValueChanged:(UISlider *)sender {
    if (!self.isDragging || !self.trackHasThumbnail) {
        return;
    }

    int64_t positionMs = (int64_t)sender.value;
    [self.player getThumbnail:positionMs];

    NSLog(@"[Step 7] 请求缩略图 - 位置: %.2f, 时间: %lld ms", sender.value, positionMs);
}

/**
 * 7.3 进度条拖拽结束时隐藏缩略图并跳转播放
 */
- (void)sliderTouchEnded:(UISlider *)sender {
    self.isDragging = NO;
    self.thumbnailView.hidden = YES;

    // 跳转到指定位置（建议使用精准 seek）
    [self.player seekToTime:sender.value seekMode:AVP_SEEKMODE_ACCURATE];

    NSLog(@"[Step 7] 跳转到位置: %.2f", sender.value);
}

#pragma mark - 播放进度更新

/**
 * 视频当前播放位置回调，用于更新进度条
 */
- (void)onCurrentPositionUpdate:(AliPlayer *)player position:(int64_t)position {
    [self updateProgress:position];
}

/**
 * 更新进度条显示
 */
- (void)updateProgress:(int64_t)position {
    if (!self.isDragging && self.player) {
        self.progressSlider.value = (float)position;
    }
}

#pragma mark - Step 8: 资源清理

/**
 * Step 8: 清理播放器资源
 */
- (void)cleanupPlayer {
    if (self.player) {
        // 解绑播放器视图
        self.player.playerView = nil;
        // 停止播放
        [self.player stop];
        // 销毁播放器实例
        [self.player destroy];
        // 清空引用，避免内存泄漏
        self.player = nil;

        NSLog(@"[Step 8] 播放器资源清理完成");
    }
}

@end
