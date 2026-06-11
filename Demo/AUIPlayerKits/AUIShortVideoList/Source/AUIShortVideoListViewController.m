//
//  AUIShortVideoListViewController.m
//  AUIShortVideoList
//
//  Created by Bingo on 2023/9/14.
//

#import "AUIShortVideoListViewController.h"
#import "AUIShortVideoPlayCell.h"
#import "AUIShortVideoAdvertisementCell.h"
#import "AUIShortVideoListListPanel.h"
#import "AUIShortVideoListController.h"
#import "AUIShortVideoListMacro.h"
#import "AUIShortVideoListConstants.h"
#import "AUIShortVideoListUtils.h"
#import "AUIVideoTrackInfoUtil.h"
#import "AUIShortVideoListSettingPanel.h"
#import "AUIShortVideoListCollectionPanel.h"

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

#import <MJRefresh/MJRefresh.h>

@interface AUIShortVideoListViewController () <AVPictureInPictureSampleBufferPlaybackDelegate, AVPictureInPictureControllerDelegate>

// 数据请求代理
@property (nonatomic, weak) id<AUIShortVideoDataProviderDelegate> dataProviderDelegate;
@property (nonatomic, strong) AUIShortVideoListController *videoListController;
@property (nonatomic, strong) NSMutableArray<AUIShortVideoInfo *> *videoInfoList;
@property (nonatomic, assign) NSInteger playIndex;
@property (nonatomic, assign) BOOL autoMoveNext;
@property (nonatomic, assign) int selectedTrackBitrate;
@property (nonatomic, assign) BOOL isBackground;

@property (nonatomic, strong)AVPictureInPictureController *pipController;
@property (nonatomic, strong)AVSampleBufferDisplayLayer *pipDisplayLayer;
@property (nonatomic, assign) BOOL isPipPaused;

@property (nonatomic,strong) UIView *pipView;


@property (nonatomic, assign) AVPStatus currentPlayerStatus;
// 监听播放器当前播放进度，currentPosition设置为监听视频当前播放位置回调中的position参数值
@property (nonatomic, assign) int64_t currentPosition;
@property (nonatomic, assign) int64_t playerDuration;

@end

@implementation AUIShortVideoListViewController


#pragma mark - LifeCycle

// 初始化方法
- (instancetype)init {
    return [self initWithData:nil];
}

// 初始化方法，通过传入初始视频数据来创建实例
- (instancetype)initWithData:(NSArray<AUIShortVideoInfo *> *)data {
    if (data == nil) {
        self = [super init];
        // 设置初始数据
        self.videoInfoList = [NSMutableArray array];
        if (data && data.count > 0) {
            [self.videoInfoList addObjectsFromArray:data];
            if (self.videoInfoList) {
                [self.videoInfoList addObjectsFromArray:self.videoInfoList];
            }
        }
        // 设置数据请求代理
        self.dataProviderDelegate = self;
        NSLog(@"[init] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
        return self;
    }
    else {
        return [self initWithData:data dataProvider:nil];
    }
}

// 初始化方法，通过传入数据请求代理来创建实例。
- (instancetype)initWithDataProvider:(id<AUIShortVideoDataProviderDelegate>)dataProviderDelegate {
    return [self initWithData:nil dataProvider:dataProviderDelegate];
}

// 初始化方法，通过传入初始数据和数据请求代理来创建实例。
- (instancetype)initWithData:(NSArray<AUIShortVideoInfo *> *)data dataProvider:(id<AUIShortVideoDataProviderDelegate>)dataProviderDelegate {
    self = [super init];
    
    if (self) {
        self.videoListController = [[AUIShortVideoListController alloc] init];
        [self.videoListController setup];
        
        // 设置初始数据
        self.videoInfoList = [NSMutableArray array];
       
        if (data && data.count > 0) {
            [self.videoInfoList addObjectsFromArray:data];
            
            // 将数据更新到预加载器中
            [self.videoListController addSources:data];
        }
        // 设置数据请求代理
        self.dataProviderDelegate = dataProviderDelegate;
        
        // 默认从第一集开始播放
        self.playIndex = 0;
        
        // 默认清晰度码率未设置
        self.selectedTrackBitrate = 0;
        
        // 默认完播后自动滑到下一集
        self.autoMoveNext = YES;
        
        [self enableRefresh:NO];
        
        NSLog(@"[init] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
    }
    
    return self;
}

// 释放资源
- (void)dealloc {
    NSLog(@"[dealloc] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
    
    [self clear];
}

// 资源清理方法
- (void)clear {
    // 取消注册监听器
    [self unregisterObservers];
    
    [self.videoListController destroy];
    
    [self.videoInfoList removeAllObjects];

    self.playIndex = 0;
    
    self.selectedTrackBitrate = 0;
    
    // 默认完播后自动滑到下一集
    self.autoMoveNext = YES;
    
    [self enableRefresh:NO];
    
    // 销毁 PiP SampleBufferDisplayLayer
    [self destroySampleBufferPiPController];
}

#pragma mark - Observers

// 注册监听器
- (void)registerObservers {
    // 观察应用程序的活跃状态变化
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

// 取消注册监听器
- (void)unregisterObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 前后台切换

// 应用程序从后台到前台时的操作
- (void)applicationDidBecomeActive:(NSNotification *)notification {
    // Application becomes active (applicable to all view controllers)
    SLOGI(@"applicationDidBecomeActive");
    self.isBackground = false;
    if (![self isPictureInPictureAvailable]){
        [self start:self.playIndex];
    } else {
        [self stopPiP];
    }
}

// 应用程序即将进入后台时的操作
- (void)applicationWillResignActive:(NSNotification *)notification {
    // Application will resign active (applicable to all view controllers)
    SLOGI(@"applicationWillResignActive");
    self.isBackground = YES;
    if (![self isPictureInPictureAvailable]){
        [self pause:self.playIndex];
    }
}

#pragma mark - View Layout

// 视图加载完毕后的初始化设置
- (void)viewDidLoad {
    [super viewDidLoad];
    SLOGI(@"viewDidLoad");
    
    // 注册监听器
    [self registerObservers];
    
    // 初始化 PiP SampleBufferDisplayLayer（自管播控，适合自研/第三方解码）
    [self setupSampleBufferPiPController];
    
    // 隐藏头部视图，并设置内容视图和集合视图的大小
    self.headerView.hidden = YES;
    self.contentView.frame = self.view.bounds;
    self.collectionView.frame = self.contentView.bounds;
    
    // 启用分页并隐藏垂直滚动指示器
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    // 注册播放单元格
    [self.collectionView registerClass:AUIShortVideoPlayCell.class forCellWithReuseIdentifier:AVCollectionViewCellIdentifier];
    [self.collectionView registerClass:AUIShortVideoAdvertisementCell.class forCellWithReuseIdentifier:AVCollectionViewCellAdvertisement];
    
    // 刷新集合视图
    [self.collectionView reloadData];
    //添加刷新视图
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshSource)];
    header.accessibilityIdentifier = [@"AUIShortVideoList_" stringByAppendingString:@"headerRefresh"];
    header.stateLabel.hidden = YES;
    self.collectionView.mj_header = header;
    
    // 如果当前无数据，请求更多数据
    if (self.videoInfoList.count == 0 && self.dataProviderDelegate && [self.dataProviderDelegate respondsToSelector:@selector(loadData:)]) {
        [self.dataProviderDelegate loadData:self];
    }
}

// 当视图控制器变为活跃时的操作
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    SLOGI(@"viewDidAppear");
    
    [self pageSelect:self.playIndex];
}

// 当视图控制器进入非活跃状态时的操作
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    SLOGI(@"viewDidDisappear");
    
    [self unbind:self.playIndex];
    [self clear];
}

// 当视图控制器即将移动到父视图控制器时调用
- (void)willMoveToParentViewController:(UIViewController *)parent {
    // 此方法可以用于执行即将移动的操作，例如更新 UI 或者准备需要的资源
    SLOGI(@"willMoveToParentViewController");
}

// 当视图控制器已经移动到父视图控制器后调用
- (void)didMoveToParentViewController:(UIViewController *)parent {
    SLOGI(@"didMoveToParentViewController");
    
    if (!parent) {
        [self unbind:self.playIndex];
        
        // 销毁 PiP SampleBufferDisplayLayer
        [self destroySampleBufferPiPController];
    }
}

#pragma mark - API Methods

// 追加新的视频数据到当前列表中。
- (void)appendVideoInfoList:(NSArray<AUIShortVideoInfo *> *)videoInfoList {
    // 确认新数据非空且有内容
    if (!videoInfoList || videoInfoList.count == 0) {
        return;
    }
    
    BOOL isFirstPlay = self.videoInfoList.count == 0;
    // 将新的视频数据追加到现有列表中
    [self.videoInfoList addObjectsFromArray:videoInfoList];
    
    // 将数据更新到预加载器中
    [self.videoListController addSources:videoInfoList];
    
    // 在主线程上更新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];  // 刷新集合视图
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (isFirstPlay) {
                [self pageSelect:0];
            }
        });
    });
}

- (void)resetVideoInfoList:(NSArray<AUIShortVideoInfo *> *)videoInfoList {
    // 确认新数据非空且有内容
    if (!videoInfoList || videoInfoList.count == 0) {
        return;
    }
    
    BOOL isFirstPlay = YES;
    [self.videoInfoList removeAllObjects];
    // 将新的视频数据追加到现有列表中
    [self.videoInfoList addObjectsFromArray:videoInfoList];
    
    // 将数据更新到预加载器中
    [self.videoListController loadSources:videoInfoList];
    
    // 在主线程上更新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        SLOGI(@"[mjRefresh] endRefreshing");
        [self.collectionView.mj_header endRefreshing];
        
        // 刷新集合视图
        [self.collectionView reloadData];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (isFirstPlay) {
                [self pageSelect:0];
            }
        });
    });
}

// 获取当前正在播放的视频信息
- (AUIShortVideoInfo *)getCurrentVideoInfo {
    if (![self isPlayIndexValid:self.playIndex]) {
        return nil;
    }
    
    return [self.videoInfoList objectAtIndex:self.playIndex];
}

#pragma mark - PiP

// 基于 SampleBufferDisplayLayer 初始化画中画控制器（iOS 15+）
//
// 1) 必要配置：后台播放能力（Capabilities 勾选 "Audio, AirPlay, Picture in Picture"；会话设为 playback）
// 2) 构建内容源：PlayerLayer 或 SampleBufferDisplayLayer
- (void)setupSampleBufferPiPController {
    // 确保 API 可用（iOS 15+）
    if (@available(iOS 15.0, *)) {
        // 确认当前设备/系统支持画中画功能
        if ([AVPictureInPictureController isPictureInPictureSupported]) {
            
            // FIXME: 为了遮挡pipView 在无封面图下，出现画面
            self.collectionView.backgroundColor = [UIColor blackColor];
            
            self.pipView = [[UIView alloc] initWithFrame:self.view.bounds];

            // 创建 DisplayLayer 显示层
            self.pipDisplayLayer = [AVSampleBufferDisplayLayer layer];

            // 设置小窗原始 Frame 大小
            CGFloat screenWidth =  [UIScreen mainScreen].bounds.size.width;
            CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
            self.pipDisplayLayer.frame = CGRectMake(0, 0, screenWidth, screenHeight);
            NSLog(@"[PiP] DisplayLayer frame size: width=%.0f, height=%.0f", screenWidth, screenHeight);
            
            // 用于控制视频内容在播放器层中的显示方式。它决定了视频内容如何适应或填充 AVPlayerLayer 的边界。这个属性类似于 UIView 的 contentMode 或 CALayer 的 contentsGravity。
            // 当 enqueuePixelBufferForImmediateDisplay 解码返回为 NO 时，画中画页面显示出现问题，设置 videoGravity 后无复现
            self.pipDisplayLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            
            // 创建控制时间基准 - 正确的方式
            CMTimebaseRef controlTimebase = NULL;
            OSStatus status = CMTimebaseCreateWithSourceClock(kCFAllocatorDefault,
                                                            CMClockGetHostTimeClock(),
                                                            &controlTimebase);
            if (status == noErr && controlTimebase) {
                // 设置控制时间基准
                self.pipDisplayLayer.controlTimebase = controlTimebase;
                
                // 设置初始时间和速率
                CMTimebaseSetTime(controlTimebase, kCMTimeZero);
                CMTimebaseSetRate(controlTimebase, 0.0); // 初始暂停
                
                CFRelease(controlTimebase);
                NSLog(@"[PiP] control timebase created successfully.");
            } else {
                NSLog(@"[PiP] control timebase created failed: %d", status);
            }
            
            [self.pipView.layer addSublayer:self.pipDisplayLayer];
            [self.contentView insertSubview:self.pipView belowSubview:self.collectionView];
            
            // 创建 ContentSource：使用 SampleBufferDisplayLayer + playback delegate（接管播控）
            AVPictureInPictureControllerContentSource *source = [[AVPictureInPictureControllerContentSource alloc] initWithSampleBufferDisplayLayer:self.pipDisplayLayer playbackDelegate:self];
            
            // 实例化 PiP 控制器
            self.pipController = [[AVPictureInPictureController alloc] initWithContentSource:source];
            self.pipController.delegate = self;
            self.pipController.canStartPictureInPictureAutomaticallyFromInline = YES;
            
            // 配置播放模式：NO 表示允许用户在 PiP UI 上快进/快退
            self.pipController.requiresLinearPlayback = NO;
            
            NSLog(@"[PiP] SampleBuffer PiP controller initialized successfully.");
        } else {
            // 当前设备不支持 PiP（可能是模拟器、旧机型、或未开启权限）
            NSLog(@"[PiP] Warning: Picture in Picture is not supported on this device.");
        }
    } else {
        // 系统版本过低
        NSLog(@"[PiP] Warning: Picture in Picture requires iOS 15.0 or later.");
    }
}

// 销毁基于 SampleBufferDisplayLayer 的画中画控制器
- (void)destroySampleBufferPiPController {
    [self stopPiP];
    
    if (self.pipController) {
        self.pipController.delegate = nil;
        self.pipController = nil;
    }
    
    if (self.pipDisplayLayer) {
        NSLog(@"[PiP] destroySampleBufferPiPController, flushing...");
        [self.pipDisplayLayer flush];
        
        // 停止控制时间基准
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
    
    NSLog(@"[PiP] SampleBuffer PiP controller destroyed.");
}

// 将一帧像素缓冲（CVPixelBuffer）封装为 CMSampleBuffer 并立刻送进 pipDisplayLayer（AVSampleBufferDisplayLayer）进行显示。
//
// 1) pixelBuffer 待显示的像素缓冲。仅在本次调用期间有效；如需异步持有，请自行使用 CVPixelBufferRetain/Release 管理其生命周期。
// 2) 返回 YES 表示样本已成功入队；NO 表示未入队（如参数无效、显示层未就绪、构建格式描述/样本失败等）。
- (BOOL)enqueuePixelBufferForImmediateDisplay:(CVPixelBufferRef)pixelBuffer {
    static CMTime lastPresentationTime = {0};
    static BOOL isFirstFrame = YES;
    
    if (!pixelBuffer || !self.pipDisplayLayer) {
        return NO;
    }
    
    // 检查显示层状态
    if (self.pipDisplayLayer.status == AVQueuedSampleBufferRenderingStatusFailed) {
        NSLog(@"[PiP] DisplayLayer failed, flushing...");
        [self.pipDisplayLayer flush];
        isFirstFrame = YES;
        
        // 重置控制时间基准
        if (self.pipDisplayLayer.controlTimebase) {
            CMTimebaseSetTime(self.pipDisplayLayer.controlTimebase, kCMTimeZero);
            CMTimebaseSetRate(self.pipDisplayLayer.controlTimebase, self.isPipPaused ? 0.0 : 1.0);
        }
        return NO;
    }
    
    if (!self.pipDisplayLayer.isReadyForMoreMediaData) {
        return NO;
    }
    
    // 构建格式描述
    CMVideoFormatDescriptionRef videoInfo = NULL;
    OSStatus err = CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
    if (err != noErr || !videoInfo) {
        NSLog(@"[PiP] Failed to create video format description: %d", err);
        return NO;
    }
    
    // 使用控制时间基准的当前时间作为呈现时间
    CMTime presentationTime;
    if (self.pipDisplayLayer.controlTimebase) {
        presentationTime = CMTimebaseGetTime(self.pipDisplayLayer.controlTimebase);
    } else {
        // 备用方案：使用递增时间戳
        if (isFirstFrame) {
            presentationTime = kCMTimeZero;
            isFirstFrame = NO;
        } else {
            CMTime increment = CMTimeMake(1, 30); // 30fps
            presentationTime = CMTimeAdd(lastPresentationTime, increment);
        }
    }
    lastPresentationTime = presentationTime;
    
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
    
    if (err != noErr || !sampleBuffer) {
        NSLog(@"[PiP] Failed to create sample buffer: %d", err);
        return NO;
    }
    
    [self.pipDisplayLayer enqueueSampleBuffer:sampleBuffer];
    CFRelease(sampleBuffer);
    
    // Tips: 设置为 YES 时不会渲染playerView, 设置为 NO 时可以同时渲染pipDisplayLayer 和 playerView;
    return NO;
}

// 检查画中画功能是否可用
- (BOOL)isPictureInPictureAvailable {
    // Tips: @available 作为表达式，无法直接使用 @available(iOS 15.0, *) = true 判断其API是否可用
    // 1、系统版本是否大于等于15.0
    if (@available(iOS 15.0, *)){
      
    } else {
        NSLog(@"[PiP] iOS version below 15.0 does not support PiP");
        return NO;
    }
    
    // 2、支持画中画
    if (![AVPictureInPictureController isPictureInPictureSupported]){
        NSLog(@"[PiP] AVPictureInPictureController does not support PiP");
        return NO;
    }
    
    // 3. 控制器存在
    if (!self.pipController) {
        return NO;
    }   
        
    return YES;
}

// 开启画中画模式
- (void)startPip {
    // 检查画中画功能是否可用
    if (![self isPictureInPictureAvailable]) {
        NSLog(@"[PiP] Picture-in-Picture is not available, cannot start PiP.");
        return;
    }
    
    NSLog(@"[PiP] startPip: possible=%d, active=%d, layerStatus=%ld, ready=%d",
              (int)self.pipController.isPictureInPicturePossible,
              (int)self.pipController.isPictureInPictureActive,
              (long)self.pipDisplayLayer.status,
              (int)self.pipDisplayLayer.isReadyForMoreMediaData);
    
    [self.pipController startPictureInPicture];
}
 

// 关闭画中画模式
- (void)stopPiP {
    // 检查画中画功能是否可用
    if (![self isPictureInPictureAvailable]) {
        NSLog(@"[PiP] Picture-in-Picture is not available, cannot stop PiP.");
        return;
    }
    
    NSLog(@"[PiP] stopPiP: possible=%d, active=%d, layerStatus=%ld, ready=%d",
              (int)self.pipController.isPictureInPicturePossible,
              (int)self.pipController.isPictureInPictureActive,
              (long)self.pipDisplayLayer.status,
              (int)self.pipDisplayLayer.isReadyForMoreMediaData);
    
    [self.pipController stopPictureInPicture];
}

/// 设置画中画暂停状态
- (void)togglePiPState:(BOOL)isPaused {
    // 检查画中画功能是否可用
    if (![self isPictureInPictureAvailable]) {
        NSLog(@"[PiP] Picture-in-Picture is not available, cannot set paused state.");
        return;
    }
    
    if (self.isPipPaused == isPaused) {
        return;
    }

    // 更新暂停状态
    self.isPipPaused = isPaused;
    
    NSLog(@"[PiP] Picture-in-Picture %@.", self.isPipPaused ? @"paused" : @"resumed");
}

#pragma mark - Page Move

// 播放指定索引的视频
- (void)pageSelect:(NSInteger)index {
    SLOGI(@"[---------PAGE_SELECT---------][%ld->%ld], isPipPaused: %@", self.playIndex, index, self.isPipPaused ? @"YES" : @"NO");
    
    // 更新浮标
    self.playIndex = index;
    
    // 绑定当前Cell
    [self bind:self.playIndex];
    
    // 播放当前Cell
    [self start:self.playIndex];
    
    // 从0起播
    [self seekToPositionAtIndex:self.playIndex position:0];
    
    // 预加载下一个Cell
    if ([self canMoveNext]) {
        [self bind:(self.playIndex + 1)];
    }
    
    // 移动浮标到指定位置
    [self.videoListController moveTo:self.playIndex];
}

- (BOOL)canMoveNext {
    return self.autoMoveNext && [self isPlayIndexValid:self.playIndex];
}

- (void)moveToIndex:(NSInteger)index animate:(BOOL)animate {
    // 确保索引在有效范围内
    if (![self isPlayIndexValid:index]) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];

        // Tips: 当应用处于后台/画中画时，滑动触发选择NO, 前台时选择YES; 选择动画效果为NO 时，后台可以触发willDisplayCell,前台可以改为YES
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:animate];
        // 根据页面需要刷新页面
        [self.collectionView layoutIfNeeded];
    });
    
    // 取消当前播放索引绑定
    [self unbind:self.playIndex];
    
    // 延迟回调，以确保 UI 完成滚动后执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self pageSelect:index];
    });
}

- (void)moveNext {
    // 如果当前索引是最后一个，重播当前视频
    if (self.playIndex == self.videoInfoList.count - 1) {
        [self pageSelect:self.playIndex]; // 调用 pageSelect 以重播
        return;
    }
    
    // 判断当前是否能够自动移动到下一个
    if (![self canMoveNext]) {
        return;
    }
    
    // 移动到下一个视频
    [self moveToIndex:(self.playIndex + 1) animate:!self.isBackground];
}

#pragma mark - Data Source

// 刷新数据
- (void)refreshSource {
    if ([self.collectionView.mj_header isRefreshing]) {
        SLOGI(@"[mjRefresh] startRefresh");
        if (self.dataProviderDelegate && [self.dataProviderDelegate respondsToSelector:@selector(refreshData:)]) {
            AUIShortVideoPlayCell *cell = [self getPlayCell:self.playIndex];
            if (cell) {
                [cell unbind];
            }
            [self.dataProviderDelegate refreshData:self];
        } else {
            //无实现不解绑 view
            [self.collectionView.mj_header endRefreshing];
        }
        return;
    }
}

// 控制当前 ViewController 是否支持下拉刷新
- (void)enableRefresh:(BOOL)isRefresh{
    if (self.collectionView.mj_header){
        self.collectionView.mj_header.hidden = !isRefresh;
    }
}

#pragma mark - Search Index

// 根据索引位置索引对应的视频信息
- (AUIShortVideoInfo *)getVideoInfoAtIndex:(NSInteger)index {
    if (index < 0 || index >= [self.videoInfoList count]) {
        return nil;
    }
    // 获取指定索引位置的视频信息
    return [self.videoInfoList objectAtIndex:index];
}

// 根据索引位置索引对应的播放单元格
- (AUIShortVideoPlayCell *)getPlayCell:(NSInteger)index {
    // 获取指定索引的 UICollectionViewCell
    // 可能返回 nil，因为当前播放的 cell 可能不可见，需要滚动后才会可见
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    // 将 UICollectionViewCell 转换成 AUIShortVideoPlayCell
    return [self validatedShortVideoPlayCell:cell];
}

// 将 UICollectionViewCell 转换成 AUIShortVideoPlayCell
- (AUIShortVideoPlayCell *)validatedShortVideoPlayCell:(UICollectionViewCell *)cell {
    // 检查 cell 是否是 AUIShortVideoPlayCell 类的实例
    // 如果是，返回 cell 的类型转换结果，否则返回 nil
    if ([cell isKindOfClass:[AUIShortVideoPlayCell class]]) {
        return (AUIShortVideoPlayCell *)cell;
    }
    
    return nil;
}

// 验证 playIndex 的有效性
- (BOOL)isPlayIndexValid:(NSInteger)playIndex {
    return playIndex >= 0 && playIndex < self.videoInfoList.count;
}

#pragma mark - Build Cell

// 创建播放单元格Cell
- (AUIShortVideoPlayCell *)buildPlayCell:(NSIndexPath *)indexPath pageIndex:(NSInteger)index videoInfo:(AUIShortVideoInfo *)videoInfo {
    AUIShortVideoPlayCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:AVCollectionViewCellIdentifier forIndexPath:indexPath];
    
    // 在 cell 即将显示时调用
    AUIShortVideoPlayCell *playCell = [self validatedShortVideoPlayCell:cell];
    if (playCell) {
        // 为有效的 playCell 绑定视频信息
        AUIShortVideoInfo *videoInfo = self.videoInfoList[indexPath.row];
        // 绑定视频信息到 playCell
        [playCell bindData:videoInfo];
    }
    
    __weak typeof(self) weakSelf = self;  // 弱引用 self
    cell.onCompletionBlock = ^(AUIShortVideoPlayCell * _Nonnull cell) {
        __strong typeof(weakSelf) strongSelf = weakSelf; // 强引用 self
        [strongSelf moveNext];
    };
    
    
    cell.onSelectionBlock = ^(AUIShortVideoPlayCell * _Nonnull cell) {
        [AUIShortVideoListCollectionPanel setPanelHeight:weakSelf.videoInfoList max:weakSelf.contentView.av_height * 3 / 5.0];
        
        AUIShortVideoListCollectionPanel *panel = [[AUIShortVideoListCollectionPanel alloc] initWithFrame:CGRectMake(0,0,weakSelf.contentView.av_width,0) withVideoInfoList:weakSelf.videoInfoList withPlaying:[weakSelf getCurrentVideoInfo]];
        panel.onVideoSelectedBlock = ^(AUIShortVideoListCollectionPanel * _Nonnull sender,
                                       AUIShortVideoInfo * _Nonnull videoInfo) {
            NSInteger index = [weakSelf.videoInfoList indexOfObject:videoInfo];
            [weakSelf moveToIndex:index animate:NO];
            [sender hide];
        };
        
        panel.onShowChanged = ^(AVBaseControllPanel * _Nonnull sender) {
            weakSelf.autoMoveNext = !sender.isShowing;
        };
        
        [AUIShortVideoListCollectionPanel present:panel onView:weakSelf.contentView backgroundType:AVControllPanelBackgroundTypeClickToClose];
    };
    
    cell.onSettingBlock = ^(AUIShortVideoPlayCell * _Nonnull cell,
                            NSArray<AVPTrackInfo *> * _Nonnull trackInfo) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf)return;
        AUIShortVideoListSettingPanel* panel = [[AUIShortVideoListSettingPanel alloc]initWithFrame:CGRectMake(0,
                                                                                                              0,
                                                                                                              strongSelf.contentView.av_width,
                                                                                                              250)  dataArray:trackInfo];
        panel.onRateChange = ^(CGFloat value) {
            [cell setSpeed:value];
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            [formatter setMinimumFractionDigits:0]; // 最少为0位小数
            [formatter setMaximumFractionDigits:20];
            NSString *formattedString = [formatter stringFromNumber:@(value)];
            [AVToastView show:[NSString stringWithFormat:@"%@%@x",
                               SVString(@"Set Video Speed"),
                               formattedString] view:strongSelf.view position:AVToastViewPositionBottom];
        };
        panel.onTrackSelect = ^(AVPTrackInfo * _Nonnull info) {
            [cell selectTrack:info];
            NSString *msg = [NSString stringWithFormat:@"%@%@",
                             SVString(@"Switching resolution"),
                             [AUIVideoTrackInfoUtil getQuality:info]];
            [AVToastView show:msg view:strongSelf.view position:AVToastViewPositionBottom];
        };
        [AUIShortVideoListSettingPanel present:panel onView:strongSelf.contentView backgroundType:AVControllPanelBackgroundTypeClickToClose];
    };
    
    cell.onStatusChanged = ^(AUIShortVideoPlayCell * _Nonnull cell,
                             AVPStatus status) {
        self.currentPlayerStatus = status;
        
        switch (status) {
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
            if (self.pipController){
                [self.pipController invalidatePlaybackState];
            }
        }
    };
    
    cell.onPositionChanged = ^(AUIShortVideoPlayCell * _Nonnull cell,
                               int64_t position,
                               int64_t duration) {
        self.currentPosition = position;
        self.playerDuration = duration;
        
        // 获取当前进度/时长后，更新UI,防止画中画点播场景UI变为直播场景UI
        if (@available(iOS 15.0, *)) {
            if (self.pipController){
                [self.pipController invalidatePlaybackState];
            }
        }
    };
    
    cell.onTrackChanged = ^(AUIShortVideoPlayCell * _Nonnull cell,
                            AVPTrackInfo * _Nonnull info) {
        NSString *msg = [NSString stringWithFormat:@"%@%@",
                         SVString(@"Clarity switch successful"),
                         [AUIVideoTrackInfoUtil getQuality:info]];
        [AVToastView show:msg view:weakSelf.view position:AVToastViewPositionBottom];

        __strong typeof(weakSelf) strongSelf = weakSelf; // 强引用 self
        
        // 如果清晰度码率与当前指定的相同，默认跳过处理
        if (info.trackBitrate == strongSelf.selectedTrackBitrate) {
            return;
        }
        strongSelf.selectedTrackBitrate = info.trackBitrate;
        
        // 当视频清晰度切换成功，将码率回调到上层，供预加载器调整至指定码率
        [strongSelf.videoListController setBandwidth:info.trackBitrate];
        
        // 遍历当前所有单元格
        NSInteger numberOfItems = [strongSelf.collectionView numberOfItemsInSection:0];
        for (NSInteger i = 0; i < numberOfItems; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            
            // 在 cell 即将显示时调用
            AUIShortVideoPlayCell *playCell = [self validatedShortVideoPlayCell:cell];
            if (playCell) {
                [playCell setBandwidth:info.trackBitrate];
            }
        }
    };
    
    cell.onBackBtnClickBlock = ^(AUIShortVideoPlayCell * _Nonnull cell) {
        [cell unbind];
        [weakSelf goBack];
    };
    
    return cell;
}

// 创建广告单元格Cell
- (AUIShortVideoAdvertisementCell *)buildAdvertisementCell:(NSIndexPath *)indexPath{
    AUIShortVideoAdvertisementCell *cell =  [self.collectionView dequeueReusableCellWithReuseIdentifier:AVCollectionViewCellAdvertisement forIndexPath:indexPath];
    
    __weak typeof(self) weakSelf = self;  // 弱引用 self
    cell.onBackBtnClickBlock = ^(AUIShortVideoAdvertisementCell * _Nonnull cell) {
        __strong typeof(weakSelf) strongSelf = weakSelf; // 强引用 self
        [strongSelf goBack];
    };
    
    return cell;
}

#pragma mark - Control Cell

// 绑定指定位置的内容
- (void)bind:(NSInteger)index {
    // 获取预加载索引位置的视频信息和单元格
    AUIShortVideoPlayCell *playCell = [self getPlayCell:index];
    AUIShortVideoInfo *videoInfo = [self getVideoInfoAtIndex:index];
    
    // 验证视频单元格和视频信息是否存在
    if (!playCell || !videoInfo) {
        return;
    }
    
    SLOGI(@"[BIND][%ld], %@, %@", index, playCell, videoInfo);
    // 多码率 HLS 档位自动衔接
    [playCell setBandwidth:self.selectedTrackBitrate];
    // 绑定视频信息到 playCell
    [playCell bindData:videoInfo];
    // 将当前视频绑定到单元格
    [playCell bind];
}

// 开始播放指定位置的内容
- (void)start:(NSInteger)index {
    // 获取预加载索引位置的视频信息和单元格
    AUIShortVideoPlayCell *playCell = [self getPlayCell:index];
    
    // 验证视频单元格是否存在
    if (!playCell) {
        return;
    }
    
    SLOGI(@"[START][%ld], %@", index, playCell);
    [playCell start];
}

// 暂停指定位置的内容
- (void)pause:(NSInteger)index {
    // 获取预加载索引位置的视频信息和单元格
    AUIShortVideoPlayCell *playCell = [self getPlayCell:index];
    
    // 验证视频单元格是否存在
    if (!playCell) {
        return;
    }
    
    SLOGI(@"[PAUSE][%ld], %@", index, playCell);
    [playCell pause];
}

// 隐藏/显示指定位置的按钮
- (void)showPauseBtn:(NSInteger)index enable:(BOOL)enable{
    AUIShortVideoPlayCell *playCell = [self getPlayCell:index];
    
    // 验证视频单元格是否存在
    if (!playCell) {
        return;
    }
    
    SLOGI(@"[PAUSE][%ld], %@", index, playCell);
    [playCell showPauseBtn:enable];
}

// 将指定索引的视频单元格，跳转到指定播放位置
- (void)seekToPositionAtIndex:(NSInteger)index position:(int64_t)position {
    // 获取预加载索引位置的视频信息和单元格
    AUIShortVideoPlayCell *playCell = [self getPlayCell:index];
    
    // 验证视频单元格是否存在
    if (!playCell) {
        return;
    }
    
    SLOGI(@"[SEEK][%ld], %@", index, playCell);
    [playCell seekToPosition:position];
}

// 解除绑定指定位置的内容
- (void)unbind:(NSInteger)index {
    // 获取预加载索引位置的视频信息和单元格
    AUIShortVideoPlayCell *playCell = [self getPlayCell:index];
    
    // 验证视频单元格是否存在
    if (!playCell) {
        return;
    }
    
    SLOGI(@"[UNBIND][%ld], %@", index, playCell);
    //    [playCell setPipDelegaee:nil];
    [playCell unbind];
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // 返回视频信息列表中的项目数，即 collection view 中的 cell 数量
    return self.videoInfoList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SLOGI(@"[collectionView][CBK][cellForItemAtIndexPath][%ld->%ld]",
          self.playIndex,
          indexPath.row);
    
    // 获取对应索引处的视频信息
    AUIShortVideoInfo *videoInfo = [self.videoInfoList objectAtIndex:indexPath.row];
    
    // 检查 videoInfo 是否有效
    if (!videoInfo || !videoInfo.url) {
        return nil; // 若视频信息无效，返回 nil
    }
    if (!videoInfo.type) {
        return [self buildPlayCell:indexPath pageIndex:indexPath.row videoInfo:videoInfo];; // 若视频信息没有type，默认为video
    }
    
    // 根据视频信息的类型判断创建哪种 cell
    if ([videoInfo.type isEqualToString:AVCollectionViewCellAdvertisement]) {
        return [self buildAdvertisementCell:indexPath];
    } else {
        return [self buildPlayCell:indexPath pageIndex:indexPath.row videoInfo:videoInfo];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 设置每个 cell 的大小等于 collectionView 的 bounds，适合全屏显示
    // 直接使用传入的参数，避免潜在问题
    return collectionView.bounds.size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    // 行间距设置为 0，确保紧贴
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    // 项目间距设置为 0
    return 0.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // 无内边距，内容填充整个显示区域
    return UIEdgeInsetsZero;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    SLOGI(@"[collectionView][CBK][willDisplayCell][%ld->%ld]",
          self.playIndex,
          indexPath.row);
    if (indexPath.row == self.playIndex + 1) {
        // 在 cell 即将显示时调用
        AUIShortVideoPlayCell *playCell = [self validatedShortVideoPlayCell:cell];
        if (playCell) {
            // 为有效的 playCell 绑定视频信息
            AUIShortVideoInfo *videoInfo = self.videoInfoList[indexPath.row];
            SLOGI(@"[BIND*][%ld], %@, %@", indexPath.row, playCell, videoInfo);
            // 绑定视频信息到 playCell
            [playCell bindData:videoInfo];
            // 将当前视频绑定到单元格
            [playCell bind];
        }
    }
    
    // Tips: 处理即将显示时的cell, 不跟 bindData/bind 数据同一时间设置
    AUIShortVideoPlayCell *playCell = [self validatedShortVideoPlayCell:cell];
    if (playCell) {
        playCell.onPiPEnqueuePixelBuffer = ^BOOL(AUIShortVideoPlayCell * _Nonnull cell, CVPixelBufferRef  _Nonnull pixBuffer) {
    //                NSLog(@"[pipController][onPiPEnqueuePixelBuffer bbbb][%ld]", self.playIndex);
            return [self enqueuePixelBufferForImmediateDisplay:pixBuffer];
        };
        
    }

}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    SLOGI(@"[collectionView][CBK][didEndDisplayingCell][%ld->%ld]",
          self.playIndex,
          indexPath.row);
    // 在 cell 不再显示时调用
    AUIShortVideoPlayCell *playCell = [self validatedShortVideoPlayCell:cell];
    if (playCell) {
        SLOGI(@"[PAUSE*][%ld], %@", indexPath.row, playCell);
        // 解除绑定以释放资源或重置状态
        [playCell pause];
        // playerPoolCapacity == 2 时，第一次下滑，未触发unbind ，但是 播放器实例已被复用，重新bind 新的view, 需要单独调用显示封面图
        if ([AUIShortVideoListConstants playerPoolCapacity] == 2 && [AUIShortVideoListConstants enableCoverURLStrategy]){
            [playCell showCoverImage:YES];
        }
    }
}

#pragma mark - UIScrollViewDelegate

// 滚动视图停止减速时调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //    SLOGI(@"[collectionView][CBK][scrollViewDidEndDecelerating][%ld]", self.playIndex);
    [self updateSelectedIndex];
}

// 滚动动画停止时调用
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    //    SLOGI(@"[collectionView][CBK][scrollViewDidEndDecelerating][%ld]", self.playIndex);
    [self updateSelectedIndex];
}

// 拖动即将停止时调用
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    //    SLOGI(@"[collectionView][CBK][scrollViewWillEndDragging][%ld]", self.playIndex);
    [self updateSelectedIndex];
}

// 滚动视图滚动到顶部时调用
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [self updateSelectedIndex];
}

#pragma mark - Helper to determine current index

// 获取位于中心位置的 cell 的索引路径 ~ deprecated
- (NSIndexPath *)getCenteredIndexPath {
    // Get indexPath of the cell in the center of the collection view visible area.
    CGPoint visibleCenterPositionOfScrollView = CGPointMake(self.collectionView.contentOffset.x + self.collectionView.bounds.size.width / 2,
                                                            self.collectionView.contentOffset.y + self.collectionView.bounds.size.height / 2);
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:visibleCenterPositionOfScrollView];
    return indexPath;
}

// 更新当前选中的 cell 的索引
- (void)updateSelectedIndex {
    CGFloat pageHeight = self.collectionView.av_height;
    NSInteger index = (NSInteger)floor((self.collectionView.contentOffset.y + 0.5 * pageHeight) / pageHeight);
    if (self.playIndex == index) {
        return;
    }
    
    SLOGI(@"[collectionView][CBK][---updateSelectedIndex---][%ld->%ld]",
          self.playIndex,
          index);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self pause:self.playIndex];
        // 在定义之前，做的都是上一个播放器 view 层的操作，定义之后，属于当前 cell 的使用层
        [self pageSelect:index];
    });
}

// 请求额外数据的方法
- (void)loadData:(id)controller {
    AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:self.view animated:YES];
    loading.labelText = AVGetString(@"Loading...", @"AUIShortVideoList");
    
    // 创建弱引用，以避免循环引用f
    __weak typeof(self) weakSelf = self;
    [AUIShortVideoListDataManager requestVideoInfoList:AUIShortVideoListConstants.defaultVideoInfoListURL completed:^(NSArray<AUIShortVideoInfo *> * _Nullable data,
                                                                                                                      NSError * _Nullable error) {
        // 获取强引用以避免过早释放 self
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [loading hideAnimated:YES];
        
        if (error) {
            // 在主线程显示错误提示
            dispatch_async(dispatch_get_main_queue(), ^{
                [AVToastView show:AVGetString(@"Failed to load data, data is empty!", @"AUIShortVideoList")
                             view:strongSelf.view
                         position:AVToastViewPositionBottom];
            });
            return;
        }
        
        // 确认新数据非空且有内容
        if (!data || data.count == 0) {
            dispatch_async(dispatch_get_main_queue(),
 ^{
                // 在主线程显示错误提示
                [AVToastView show:AVGetString(@"Failed to load data, data is empty!",
                                              @"AUIShortVideoList")
                             view:strongSelf.view
                         position:AVToastViewPositionBottom];
            });
            return;
        }

        // 确保 data 非空，然后添加到 dramaInfoList
        [strongSelf.videoInfoList addObjectsFromArray:data];
        
        // 调用相应子视图控制器的 appendVideoInfoList: 方法
        if (controller && [controller respondsToSelector:@selector(appendVideoInfoList:)]) {
            [controller appendVideoInfoList:[data copy]];
        }
    }];
}


// 基于 CMSampleBuffer 的 PiP 场景，需外部提供视频帧
#pragma mark - AVPictureInPictureSampleBufferPlaybackDelegate

// 播放/暂停 按钮点击事件
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController setPlaying:(BOOL)playing {
    NSLog(@"[PiP][CBK] setPlaying called, playing=%@", playing ? @"YES" : @"NO");
    
    if (playing) {
        [self start:self.playIndex];
        
        [self togglePiPState:NO];
        
        // 启动控制时间基准
        if (self.pipDisplayLayer.controlTimebase) {
            CMTimebaseSetRate(self.pipDisplayLayer.controlTimebase, 1.0);
        }
    } else {
        [self pause:self.playIndex];
        [self showPauseBtn:self.playIndex enable:YES];
        [self togglePiPState:YES];
        
        // 暂停控制时间基准
        if (self.pipDisplayLayer.controlTimebase) {
            CMTimebaseSetRate(self.pipDisplayLayer.controlTimebase, 0.0);
        }
    }
    
    // 状态改变后，告知系统，播放状态可能变了
    if (@available(iOS 15.0, *)) {
        [pictureInPictureController invalidatePlaybackState];
    }
}

// 画中画进度条范围显示
- (CMTimeRange)pictureInPictureControllerTimeRangeForPlayback:(AVPictureInPictureController *)pictureInPictureController {
    if (!self.pipDisplayLayer.controlTimebase) {
//        NSLog(@"[PiP][CBK] TimeRangeForPlayback: no controlTimebase, return infinite");
        return CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity);
    }
    
    CMTime currentTime = CMTimebaseGetTime(self.pipDisplayLayer.controlTimebase);
    Float64 current64 = CMTimeGetSeconds(currentTime);
    Float64 start;
    Float64 end;
    
    if (self.playerDuration > 0 && self.currentPosition >= 0) {
        // 将当前播放位置（毫秒）转换为秒（单位：秒）
        double curPostion = self.currentPosition / 1000.0;
        // 将视频总时长（毫秒）转换为秒（单位：秒）
        double duration = self.playerDuration / 1000.0;
        // 计算从当前位置到结尾的剩余时间（单位：秒）
        double interval = duration - curPostion;
        // 减去已播放的时间（curPostion），得到“这段视频开始于什么绝对时间”
        start = current64 - curPostion;
        // 从同一个基准时间开始，加上剩余播放时间，得到“这段视频将在何时结束”
        end = current64 + interval;
        // 用 CMTimeMakeWithSeconds 创建起始时间点 CMTime 结构体
        // 时间精度（timescale）使用当前时间的 timescale（保持精度一致）
        CMTime t1 = CMTimeMakeWithSeconds(start, currentTime.timescale);
        // 创建结束时间点 CMTime 结构体
        CMTime t2 = CMTimeMakeWithSeconds(end, currentTime.timescale);
        // 返回一个 CMTimeRange，表示从 t1 到 t2 的时间范围
        return CMTimeRangeFromTimeToTime(t1, t2);
    }
    
    // 默认返回无限时间范围
//    NSLog(@"[PiP][CBK] TimeRangeForPlayback: return infinite (no duration info)");
    return CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity);
}

// 画中画暂停/播放 状态控制
- (BOOL)pictureInPictureControllerIsPlaybackPaused:(AVPictureInPictureController *)pictureInPictureController {
//    NSLog(@"[PiP][CBK] IsPlaybackPaused -> %@", self.isPipPaused ? @"YES" : @"NO");
    return self.isPipPaused;
}

// 当用户手动调整画中画窗口的尺寸（如拖动窗口边缘）或系统自动调整窗口尺寸（如屏幕旋转）时，此方法会被调用
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController didTransitionToRenderSize:(CMVideoDimensions)newRenderSize {
    NSLog(@"[PiP][CBK] didTransitionToRenderSize called -> width=%d, height=%d",
          newRenderSize.width,
          newRenderSize.height);
}

// 处理 PiP 控件触发的快进/快退操作
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController skipByInterval:(CMTime)skipInterval completionHandler:(void (^)(void))completionHandler {
    NSLog(@"[PiP][CBK] skipByInterval called, skipInterval=%f)", CMTimeGetSeconds(skipInterval));
    
    // 计算跳转时间（毫秒）
    int64_t skipTime = skipInterval.value / skipInterval.timescale;
    int64_t skipPosition = self.currentPosition + skipTime * 1000;
    if (skipPosition < 0) {
        skipPosition = 0;
    } else if (skipPosition > self.playerDuration) {
        skipPosition = self.playerDuration;
    }
    
    // 执行 PiP 小窗的 seek 操作
    [self seekToPositionAtIndex:self.playIndex position:skipPosition];
    
    // 通知系统更新播放状态
    if (@available(iOS 15.0, *)) {
        [pictureInPictureController invalidatePlaybackState];
    }
    
    // 调用完成回调
    if (completionHandler) {
        completionHandler();
    }
}

// 是否禁止 PiP 后台音频播放（iOS 14+）
- (BOOL)pictureInPictureControllerShouldProhibitBackgroundAudioPlayback:(AVPictureInPictureController *)pictureInPictureController {
    // 允许后台音频
    return YES;
}


// PiP 控制器的状态事件回调，提供画中画的生命周期状态
#pragma mark - AVPictureInPictureControllerDelegate

// 进入 PiP 前：更新按钮状态/隐藏全屏控件等
- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"[PiP][CBK] willStartPictureInPicture");
}

// 已进入 PiP：App 内部渲染通常停帧；AVPlayerLayer 会被系统“断流”（PiP 接管）
- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"[PiP][CBK] didStartPictureInPicture");
    
    // 确保播放器继续运行（音频继续，视频帧发送到PiP）
    [self start:self.playIndex];
    [self togglePiPState:NO];
    
    // 启动控制时间基准
    if (self.pipDisplayLayer.controlTimebase) {
        CMTimebaseSetTime(self.pipDisplayLayer.controlTimebase, kCMTimeZero);
        CMTimebaseSetRate(self.pipDisplayLayer.controlTimebase, 1.0);
    }
}

// 即将退出 PiP：预先把播放视图准备好（例如展示承载 view）
- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"[PiP][CBK] willStopPictureInPicture");
}

// 已退出 PiP：恢复到应用内播放
- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"[PiP][CBK] didStopPictureInPicture");
    
    // 确保播放继续
    if (!self.isPipPaused) {
        [self start:self.playIndex];
    }
}

// PiP 启动失败时调用，可以提示用户并恢复 UI
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

// 系统请求你把播放 UI 顶回前台（例如恢复播放器界面），完成后需调用 completionHandler
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
   restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler {
    NSLog(@"[PiP][CBK] restoreUserInterfaceForPictureInPictureStop called, presenting player UI if needed...");
    
    // TODO: 在这里执行 UI 恢复操作，比如 present 播放页
    
    // 告知系统是否恢复成功，这里示例统一返回 YES
    if (completionHandler) {
        completionHandler(YES);
    }
}

@end
