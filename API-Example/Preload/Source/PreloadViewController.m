//
//  PreloadViewController.m
//  Preload
//
//  Created by 叶俊辉 on 2025/6/19.
//

#import "PreloadViewController.h"
#import "AliyunPlayer/AVPDelegate.h"
#import <AliyunPlayer/AliMediaLoaderV2.h>
#import "AliyunPlayer/AVPPreloadTask.h"
#import "AliyunPlayer/AVPPreloadConfig.h"
#import <Common/Common.h>
#import <Common/ToastUtils.h>

@interface PreloadViewController () <OnPreloadListener>

// 播放器实例
@property (nonatomic, strong) AliPlayer *player;
@property(nonatomic,strong) AliMediaLoaderV2* vodMedialoader; //预加载器
// 预加载任务
@property (nonatomic, strong) AVPPreloadTask *preloadTask;
// 任务ID
@property (nonatomic, strong) NSString *taskId;

// UI 控件
@property (nonatomic, strong) UIButton *startBtn;
@property (nonatomic, strong) UIButton *pauseBtn;
@property (nonatomic, strong) UIButton *resumeBtn;
@property (nonatomic, strong) UIButton *cancelBtn;

@end

@implementation PreloadViewController

// 预加载缓冲时长，单位：毫秒
static const int kPreloadBufferDuration = 1000;
/// 默认分辨率（宽度 × 高度）
static const int kSampleDefaultResolution = 640 * 480;
/// 默认码率（比特率）
static const int kSampleDefaultBandwidth = 4000000;
/// 默认清晰度模式
static NSString* const kSampleDefaultQuality = @"AUTO";
// 默认清晰度
static NSString* const kSampleDefaultDefinition = @"AUTO";

// 示例视频 VID 和 PlayAuth（使用 VOD 播放时需要配置）
static NSString * const kSampleVid = @"";
static NSString * const kSamplePlayAuth = @"";

#pragma mark - View Layout

// 视图加载完毕后的初始化设置
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = AppGetString(@"preload.title");
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Step 1: 创建播放器实例
    [self setupPlayer];
    
    // Step 2: 设置本地缓存
    [self setupLocalCache];
    
    // Step 3: 初始化视图组件
    [self setupViews];
    
    // Step 4 & Step 5: 设置预加载控制
    [self setupPreloadControls];
}

// 释放资源
- (void)dealloc {
    // Step 6: 资源清理
    [self cleanupResources];
    
    NSLog(@"[dealloc] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - Setup Methods

/**
 * Step 1: 创建实例
 */
- (void)setupPlayer {
    // 创建播放器实例
    self.player = [[AliPlayer alloc] init];
    self.vodMedialoader = [[AliMediaLoaderV2 alloc]init];
    // 可选：推荐使用`播放器单点追查`功能，当使用阿里云播放器 SDK 播放视频发生异常时，可借助单点追查功能针对具体某个用户或某次播放会话的异常播放行为进行全链路追踪，以便您能快速诊断问题原因，可有效改善播放体验治理效率。
    // traceId 值由您自行定义，需为您的用户或用户设备的唯一标识符，例如传入您业务的 userid 或者 IMEI、IDFA 等您业务用户的设备 ID。
    // 传入 traceId 后，埋点日志上报功能开启，后续可以使用播放质量监控、单点追查和视频播放统计功能。
    // 文档：https://help.aliyun.com/zh/vod/developer-reference/single-point-tracing
    // [self.player setTraceID:traceId];
    
    NSLog(@"[Step 1] 播放器创建完成: %@", self.player);
}

/**
 * Step 2: 设置本地缓存
 *
 * 开启本地缓存功能，提升预加载效果
 */
- (void)setupLocalCache {
    // 开启本地缓存
    [AliPlayerGlobalSettings enableLocalCache:YES];
    
    /**
     * 也可以使用下方代码进行缓存设置
     * 开启本地缓存，开启之后，就会缓存到本地文件中。
     * @param enable：本地缓存功能开关。YES：开启，NO：关闭，默认关闭。
     * @param maxBufferMemoryKB：5.4.7.1及以后版本已废弃，暂无作用。
     * @param localCacheDir：必须设置，本地缓存的文件目录，为绝对路径。
     * [AliPlayerGlobalSettings enableLocalCache:enable maxBufferMemoryKB:maxBufferMemoryKB localCacheDir:localCacheDir];
     */
    
    /**
     * 本地缓存文件清理相关配置。
     * @param expireMin - 5.4.7.1及以后版本已废弃，暂无作用。
     * @param maxCapacityMB - 最大缓存容量。单位：兆，默认值20GB，在清理时，如果缓存总容量超过此大小，则会以cacheItem为粒度，按缓存的最后时间排序，一个一个的删除最旧的缓存文件，直到小于等于最大缓存容量。
     * @param freeStorageMB - 磁盘最小空余容量。单位：兆，默认值0，在清理时，同最大缓存容量，如果当前磁盘容量小于该值，也会按规则一个一个的删除缓存文件，直到freeStorage大于等于该值或者所有缓存都被清理掉。
     * [AliPlayerGlobalSettings setCacheFileClearConfig:expireMin maxCapacityMB:maxCapacityMB freeStorageMB:freeStorageMB];
     */
    
    // 参考文档:
    // https://help.aliyun.com/zh/vod/developer-reference/advanced-features
    
    NSLog(@"[Step 2] 本地缓存已开启");
}

/**
 * Step 3: 初始化视图组件
 *
 * 创建预加载控制按钮并设置布局
 */
- (void)setupViews {
    CGFloat buttonWidth = 120;
    CGFloat buttonHeight = 44;
    CGFloat spacing = 20;
    CGFloat startY = 150;
    
    // 开始预加载按钮
    self.startBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.startBtn setTitle:AppGetString(@"app.common.start") forState:UIControlStateNormal];
    [self.startBtn setBackgroundColor:[UIColor systemBlueColor]];
    [self.startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.startBtn.layer.cornerRadius = 8;
    self.startBtn.frame = CGRectMake((self.view.bounds.size.width - buttonWidth) / 2, startY, buttonWidth, buttonHeight);
    [self.view addSubview:self.startBtn];
    
    // 暂停预加载按钮
    self.pauseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.pauseBtn setTitle:AppGetString(@"app.common.pause") forState:UIControlStateNormal];
    [self.pauseBtn setBackgroundColor:[UIColor systemOrangeColor]];
    [self.pauseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.pauseBtn.layer.cornerRadius = 8;
    self.pauseBtn.frame = CGRectMake((self.view.bounds.size.width - buttonWidth) / 2, startY + (buttonHeight + spacing), buttonWidth, buttonHeight);
    [self.view addSubview:self.pauseBtn];
    
    // 恢复预加载按钮
    self.resumeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.resumeBtn setTitle:AppGetString(@"app.common.resume") forState:UIControlStateNormal];
    [self.resumeBtn setBackgroundColor:[UIColor systemGreenColor]];
    [self.resumeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.resumeBtn.layer.cornerRadius = 8;
    self.resumeBtn.frame = CGRectMake((self.view.bounds.size.width - buttonWidth) / 2, startY + 2 * (buttonHeight + spacing), buttonWidth, buttonHeight);
    [self.view addSubview:self.resumeBtn];
    
    // 取消预加载按钮
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.cancelBtn setTitle:AppGetString(@"app.common.cancel") forState:UIControlStateNormal];
    [self.cancelBtn setBackgroundColor:[UIColor systemRedColor]];
    [self.cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.cancelBtn.layer.cornerRadius = 8;
    self.cancelBtn.frame = CGRectMake((self.view.bounds.size.width - buttonWidth) / 2, startY + 3 * (buttonHeight + spacing), buttonWidth, buttonHeight);
    [self.view addSubview:self.cancelBtn];
    
    NSLog(@"[Step 3] 视图组件初始化完成");
}

/**
 * Step 4 & Step 5: 设置预加载控制
 *
 * 为预加载控制按钮设置点击事件监听
 */
- (void)setupPreloadControls {
    // 开始预加载
    [self.startBtn addTarget:self action:@selector(startPreloadAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // 暂停预加载
    [self.pauseBtn addTarget:self action:@selector(pausePreloadAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // 恢复预加载
    [self.resumeBtn addTarget:self action:@selector(resumePreloadAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // 取消预加载
    [self.cancelBtn addTarget:self action:@selector(cancelPreloadAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSLog(@"[Step 4&5] 预加载控制设置完成");
}

#pragma mark - Button Actions

/**
 * 开始预加载按钮点击事件
 */
- (void)startPreloadAction:(UIButton *)sender {
    [self startPreloadWithUrl:kSampleVideoURL];
}

/**
 * 暂停预加载按钮点击事件
 */
- (void)pausePreloadAction:(UIButton *)sender {
    [self pausePreload];
}

/**
 * 恢复预加载按钮点击事件
 */
- (void)resumePreloadAction:(UIButton *)sender {
    [self resumePreload];
}

/**
 * 取消预加载按钮点击事件
 */
- (void)cancelPreloadAction:(UIButton *)sender {
    [self cancelPreload];
}

#pragma mark - Preload Methods

/**
 * 使用 VID 方式开始预加载
 *
 * 适用于阿里云 VOD 服务的视频播放
 */
// FIXME: 使用VOD播放的预加载功能时，传入您对应的 VID 和 PlayAuth
- (void)startPreloadWithVid {
    AVPVidAuthSource *vidAuthSource = [[AVPVidAuthSource alloc] init];
    vidAuthSource.vid = kSampleVid;
    vidAuthSource.playAuth = kSamplePlayAuth;
    vidAuthSource.quality = kSampleDefaultQuality;
    // 设置点播服务器返回的码率清晰度类型。例如："FD,LD,SD,HD,OD,2K,4K,SQ,HQ"。
    // 注意：如果类型为"AUTO"， 那么只会返回自适应码率流。
    [vidAuthSource setDefinitions:kSampleDefaultDefinition];
    // 构建预加载任务
    [self buildPreloadTaskWithVidAuthSource:vidAuthSource];
    
    // 设置播放数据源
    [self.player setAuthSource:vidAuthSource];
    
    NSLog(@"开始 VID 预加载");
}

/**
 * 使用 URL 方式开始预加载
 *
 * 适用于直接 URL 地址的视频播放
 *
 * @param url 视频播放地址
 */
- (void)startPreloadWithUrl:(NSString *)url {
    AVPUrlSource *urlSource = [[AVPUrlSource alloc] urlWithString:url];
    urlSource.quality = @"AUTO";
    
    // 构建预加载任务
    [self buildPreloadTaskWithUrlSource:urlSource];
    
    // 设置播放数据源
    [self.player setUrlSource:urlSource];
    
    NSLog(@"开始 URL 预加载: %@", url);
}

/**
 * 构建 VidAuth 预加载任务
 *
 * @param vidAuthSource VID 播放源对象
 */
- (void)buildPreloadTaskWithVidAuthSource:(AVPVidAuthSource *)vidAuthSource {
    AVPPreloadConfig *preloadConfig = [self createPreloadConfig];
    
    self.preloadTask = [[AVPPreloadTask alloc] initWithVidAuthSource:vidAuthSource preloadConfig:preloadConfig];

    self.taskId = [self.vodMedialoader addTask:self.preloadTask listener:self];

    NSLog(@"VidAuth 预加载任务已创建，TaskId: %@", self.taskId);
}

/**
 * 构建 UrlSource 预加载任务
 *
 * @param urlSource URL 播放源对象
 */
- (void)buildPreloadTaskWithUrlSource:(AVPUrlSource *)urlSource {
    AVPPreloadConfig *preloadConfig = [self createPreloadConfig];
    
    _preloadTask = [[AVPPreloadTask alloc] initWithUrlSource:urlSource preloadConfig:preloadConfig];
    

    self.taskId = [self.vodMedialoader addTask:self.preloadTask listener:self];
    
    NSLog(@"UrlSource 预加载任务已创建，TaskId: %@", self.taskId);
}

/**
 * 创建预加载配置
 *
 * 配置预加载的各项参数
 *
 * @return AVPPreloadConfig 预加载配置对象
 */
- (AVPPreloadConfig *)createPreloadConfig {
    AVPPreloadConfig *config = [[AVPPreloadConfig alloc] init];
    [config setDuration:kPreloadBufferDuration];
    [config setDefaultQuality:kSampleDefaultQuality];
    [config setDefaultResolution:kSampleDefaultResolution];
    [config setDefaultBandWidth:kSampleDefaultBandwidth];
    NSLog(@"预加载配置已创建");
    return config;
}

/**
 * 暂停预加载任务
 */
- (void)pausePreload {
    if (self.vodMedialoader) {
        [self.vodMedialoader pauseTask:self.taskId];
        NSLog(@"预加载任务已暂停，TaskId: %@", self.taskId);
    }
}

/**
 * 恢复预加载任务
 */
- (void)resumePreload {
    if (self.taskId.length > 0) {
        [self.vodMedialoader resumeTask:self.taskId];
        NSLog(@"预加载任务已恢复，TaskId: %@", self.taskId);
    }
}

/**
 * 取消预加载任务
 */
- (void)cancelPreload {
    if (self.taskId.length > 0) {
        [self.vodMedialoader cancelTask:self.taskId];
        NSLog(@"预加载任务已取消，TaskId: %@", self.taskId);
    }
}

#pragma mark - OnPreloadListener

/**
 * Step 5: 预加载监听器实现
 *
 * 监听预加载任务的各种状态变化
 */

- (void)onError:(NSString *)taskId urlOrVid:(NSString *)urlOrVid errorModel:(AVPErrorModel *)errorModel {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *message = [NSString stringWithFormat:AppGetString(@"preload.onError"), taskId, urlOrVid, errorModel.message];
        NSLog(@"%@", message);
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:AppGetString(@"preload.error.title")
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:AppGetString(@"app.common.ok") style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)onCompleted:(NSString *)taskId urlOrVid:(NSString *)urlOrVid {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *message = [NSString stringWithFormat:AppGetString(@"preload.onCompleted"), taskId, urlOrVid];
        NSLog(@"%@", message);
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:AppGetString(@"preload.completed.title")
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:AppGetString(@"app.common.ok") style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)onCanceled:(NSString *)taskId urlOrVid:(NSString *)urlOrVid {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *message = [NSString stringWithFormat:AppGetString(@"preload.onCanceled"), taskId, urlOrVid];
        NSLog(@"%@", message);
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:AppGetString(@"preload.canceled.title")
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:AppGetString(@"app.common.ok") style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

#pragma mark - Cleanup

/**
 * Step 6: 资源清理
 *
 * 方案1：stop + destroy，适用于通用场景；释放操作有耗时，会阻塞当前线程，直到资源完全释放。
 * 方案2：destroyAsync，无需手动 stop，适用于短剧等场景；异步释放资源，不阻塞线程，内部已自动调用 stop。
 * 注意：执行 destroy 或 destroyAsync 后，请不要再对播放器实例进行任何操作。
 */
- (void)cleanupResources {
    if (self.player) {
        // 5.1 停止播放
        [self.player stop];

        // 5.2 销毁播放器实例
        [self.player destroy];

        // 5.3 清空引用，避免内存泄漏
        self.player = nil;

        NSLog(@"[Step 6] 播放器资源清理完成");
    }
}

@end
