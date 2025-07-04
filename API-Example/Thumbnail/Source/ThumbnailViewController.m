//  ThumbnailViewController.m
//  Thumbnail
//
//  Created by 叶俊辉 on 2025/6/12.
//

#import "ThumbnailViewController.h"
#import "AliyunPlayer/AVPDelegate.h"
#import <Common/Common.h>

@interface ThumbnailViewController () <AVPDelegate>

#pragma mark - 播放器相关属性
// 播放器实例
@property (nonatomic, strong) AliPlayer *player;
// 播放器视图容器
@property (nonatomic, strong) UIView *playerView;

#pragma mark - UI控件属性
// 进度条控件
@property (nonatomic, strong) UISlider *progressSlider;
// 缩略图显示视图
@property (nonatomic, strong) UIImageView *thumbnailView;

#pragma mark - 状态控制属性
// 当前Track是否有缩略图，如果没有，不展示缩略图
@property (nonatomic, assign) BOOL trackHasThumbnail;
// 进度更新定时器
@property (nonatomic, strong) NSTimer *progressTimer;
// 是否正在拖拽进度条
@property (nonatomic, assign) BOOL isDragging;

@end

// 缩略图视图宽度（可自定义）
const CGFloat THUMB_WIDTH = 108;
// 缩略图视图高度（可自定义）
const CGFloat THUMB_HEIGHT = 192;

@implementation ThumbnailViewController

#pragma mark - 生命周期方法

- (void)viewDidLoad {
    [super viewDidLoad];

    // 设置页面基本属性
    self.title = AppGetString(@"thumbnail.title");
    self.view.backgroundColor = [UIColor blackColor];

    // Step 1: 创建播放器实例
    [self setupPlayer];

    // Step 2: 初始化UI视图
    [self setupUserInterface];

    // Step 3 & Step 4: 设置播放源并准备播放
    [self startPlayback];

    // Step 6: 设置缩略图（若使用Vid则需要在onTrackReady中调用）
    [self getThumbnail:kSampleThumbnailURL];

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
}

#pragma mark - Step 2: UI界面初始化

/**
 * Step 2: 初始化UI视图
 */
- (void)setupUserInterface {
    // 2.1 创建播放器视图容器
    [self setupPlayerView];

    // 2.2 创建进度条控件
    [self setupProgressSlider];

    // 2.3 创建缩略图显示视图
    [self setupThumbnailView];

    NSLog(@"[Step 2] UI界面初始化完成");
}

/**
 * 2.1 创建用于承载播放画面的视图容器，并设置播放器渲染视图
 */
- (void)setupPlayerView {
    self.playerView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.playerView];

    // 设置播放器渲染视图
    self.player.playerView = self.playerView;
}

/**
 * 2.2 创建并配置进度条控件
 */
- (void)setupProgressSlider {
    CGFloat sliderY = _playerView.frame.size.height - 60;
    CGFloat sliderWidth = self.view.frame.size.width - 40;

    self.progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, sliderY, sliderWidth, 30)];
    self.progressSlider.minimumValue = 0.0f;
    self.progressSlider.continuous = YES; // 滑动过程中不断发送值变化通知

    [self.view addSubview:self.progressSlider];
}

/**
 * 2.3 创建缩略图显示视图
 */
- (void)setupThumbnailView {
    CGFloat parentViewWidth = self.playerView.frame.size.width;

    // 计算水平居中的起始 X 坐标
    CGFloat thumbnailViewX = (parentViewWidth - THUMB_WIDTH) / 2;
    CGFloat thumbnailViewY = self.progressSlider.frame.origin.y - THUMB_HEIGHT;
    self.thumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(thumbnailViewX, thumbnailViewY, THUMB_WIDTH, THUMB_HEIGHT)];
    self.thumbnailView.hidden = YES; // 初始隐藏

    [self.playerView addSubview:self.thumbnailView];
}

#pragma mark - Step 3 & Step 4: 播放源设置和播放准备

/**
 * Step 3: 设置播放源 & Step 4: 准备播放
 */
- (void)startPlayback {
    // Step 3: 创建播放源对象并设置播放地址
    AVPUrlSource *urlSource = [[AVPUrlSource alloc] urlWithString:kSampleVideoThumbnailURL];
    [self.player setUrlSource:urlSource];

    // Step 4: 准备播放
    [self.player prepare];
    // prepare 以后可以同步调用 start 操作，onPrepared 回调完成后会自动起播
    [self.player start];
    NSLog(@"[Step 3&4] 开始播放视频: %@", kSampleVideoThumbnailURL);
}

#pragma mark - Step 5 & Step 6: 播放器事件处理和缩略图设置

/**
 * Step 5: 播放器事件处理
 */
- (void)onPlayerEvent:(AliPlayer *)player eventType:(AVPEventType)eventType {
    switch (eventType) {
        case AVPEventPrepareDone:
            // Step 5: 设置播放器准备完成后的处理
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
    NSLog(@"[Step 5] 设置进度条最大值");
}

#pragma mark - Step 6: 缩略图获取及回调处理

- (void)getThumbnail:(NSString *)thumbnailUrl {
    // Step 6: 设置缩略图URL
    [self.player setThumbnailUrl:thumbnailUrl];
    self.trackHasThumbnail = YES;
    NSLog(@"[Step 6] 设置缩略图");

    /**
        方式2：Vid形式可通过MediaInfo中的信息设置缩略图
        参考文档：https://help.aliyun.com/zh/vod/developer-reference/basic-features-2
     */
}

/**
 * @brief 获取缩略图成功回调
 * @param positionMs 指定的缩略图位置
 * @param fromPos 此缩略图的开始位置
 * @param toPos 此缩略图的结束位置
 * @param image 缩略图像指针，iOS平台是UIImage指针
 */
- (void)onGetThumbnailSuc:(int64_t)positionMs fromPos:(int64_t)fromPos toPos:(int64_t)toPos image:(id)image {
    NSLog(@"[Step 6] 获取缩略图成功 - 位置: %lld", positionMs);

    // 6.1 显示缩略图视图
    self.thumbnailView.hidden = NO;

    // 6.2 设置缩略图图片
    [self.thumbnailView setImage:(UIImage *)image];
}

/**
 * @brief 获取缩略图失败回调
 * @param positionMs 指定的缩略图位置
 */
- (void)onGetThumbnailFailed:(int64_t)positionMs {
    NSLog(@"[Step 6] 获取缩略图失败 - 位置: %lld", positionMs);

    // 隐藏缩略图视图
    self.thumbnailView.hidden = YES;
}

#pragma mark - Step 7: 缩略图显示控制

/**
 * Step 7: 设置缩略图显示控制
 */
- (void)setupThumbnailControls {
    // 7.1 添加进度条拖拽事件监听
    [self.progressSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.progressSlider addTarget:self action:@selector(sliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    [self.progressSlider addTarget:self action:@selector(sliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
    [self.progressSlider addTarget:self action:@selector(sliderTouchEnded:) forControlEvents:UIControlEventTouchUpOutside];

    NSLog(@"[Step 7] 缩略图显示控制设置完成");
}

/**
 * 7.2 进度条开始拖拽
 */
- (void)sliderTouchBegan:(UISlider *)sender {
    // 7.2.1 标记正在拖拽状态
    self.isDragging = YES;

    NSLog(@"[Step 7] 开始拖拽进度条");
}

/**
 * 7.3 进度条值变化时显示缩略图
 */
- (void)sliderValueChanged:(UISlider *)sender {
    // 只有在用户拖拽时才显示缩略图
    if (self.isDragging && self.trackHasThumbnail) {
        // 7.3.1 请求获取指定位置的缩略图
        [self.player getThumbnail:sender.value];

        NSLog(@"[Step 7] 请求缩略图 - 位置: %.2f", sender.value);
    }
}

/**
 * 7.4 进度条拖拽结束时隐藏缩略图并跳转
 */
- (void)sliderTouchEnded:(UISlider *)sender {
    // 7.4.1 取消拖拽状态
    self.isDragging = NO;

    // 7.4.2 隐藏缩略图
    self.thumbnailView.hidden = YES;

    // 7.4.3 跳转到指定位置（建议使用精准seek）
    // 参考文档：https://help.aliyun.com/zh/vod/developer-reference/basic-features-2
    [self.player seekToTime:sender.value seekMode:AVP_SEEKMODE_ACCURATE];

    NSLog(@"[Step 7] 跳转到位置: %.2f", sender.value);
}

#pragma mark - 进度更新相关方法

/**
 * 启动进度更新定时器
 */
/**
 @brief 视频当前播放位置回调
 @param player 播放器player指针
 @param position 视频当前播放位置
 */
- (void)onCurrentPositionUpdate:(AliPlayer *)player position:(int64_t)position {
    // 更新进度条
    [self updateProgress:position];
}

/**
 * 更新进度条显示
 */
- (void)updateProgress:(int64_t)position {
    // 只有在非拖拽状态下才更新进度条
    if (!self.isDragging && self.player) {
        float currentTime = (float)position;

        // 更新进度条值
        self.progressSlider.value = currentTime;
    }
}

#pragma mark - Step 8: 资源清理

/**
 * Step 8: 清理播放器资源
 */
- (void)cleanupPlayer {
    if (self.player) {
        // 8.1 停止播放
        [self.player stop];

        // 8.2 销毁播放器实例
        [self.player destroy];

        // 8.3 清空引用，避免内存泄漏
        self.player = nil;

        NSLog(@"[Step 8] 播放器资源清理完成");
    }
}

@end
