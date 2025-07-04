//
//  DownloaderViewController.m
//  Downloader
//
//  Created by 叶俊辉 on 2025/6/26.
//

#import "DownloaderViewController.h"
#import "DownloaderTrackCell.h"
#import <AliyunMediaDownloader/AliMediaDownloader.h>
#import <AliyunPlayer/AliyunPlayer.h>
#import <Common/Common.h>
#import <Common/HttpClientUtils.h>
#import <Common/ToastUtils.h>

@interface DownloaderViewController () <UITableViewDataSource, UITableViewDelegate, AVPDelegate, AMDDelegate>

#pragma mark - 播放器相关属性
// 播放器实例
@property (nonatomic, strong) AliPlayer *player;
// 播放器视图容器
@property (nonatomic, strong) UIView *playerView;

#pragma mark - 下载器相关属性
// 下载器实例
@property (nonatomic, strong) AliMediaDownloader *downloader;
// 可下载轨道信息列表
@property (nonatomic, strong) NSArray<AVPTrackInfo *> *trackInfos;
// 当前选中的轨道索引
@property (nonatomic, assign) NSInteger selectedTrackIndex;
// 当前播放授权源
@property (nonatomic, strong) AVPVidAuthSource *currentVidAuthSource;
// 下载保存路径
@property (nonatomic, strong) NSString *downloadPath;

#pragma mark - UI控件属性
// 轨道选择列表
@property (nonatomic, strong) UITableView *trackTableView;
// 下载控制按钮
@property (nonatomic, strong) UIButton *downloadButton;
// 下载进度条
@property (nonatomic, strong) UIProgressView *progressView;
// 状态显示标签
@property (nonatomic, strong) UILabel *statusLabel;
// 进度显示标签
@property (nonatomic, strong) UILabel *progressLabel;

@end

@implementation DownloaderViewController

#pragma mark - 生命周期方法

- (void)viewDidLoad {
    [super viewDidLoad];

    // 设置页面基本属性
    self.title = AppGetString(@"app.advanced.downloader.title");
    self.view.backgroundColor = [UIColor whiteColor];

    // Step 1: 初始化组件
    [self initializeComponents];

    // Step 2: 网络请求
    [self performNetworkRequest];

    // Step 3: 设置播放器
    [self setupPlayer];

    // Step 4: 设置下载器
    [self setupDownloader];
}

- (void)dealloc {
    // Step 9: 清理资源
    [self cleanupResources];

    NSLog(@"[dealloc] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
}

- (void)backButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Step 1: 组件初始化

/**
 * Step 1: 初始化组件
 */
- (void)initializeComponents {
    NSLog(@"[Step 1] 开始初始化组件");

    // 1.1 初始化私有服务 - 配置安全下载的加密校验文件
    [self initPrivateService];

    // 1.2 设置下载目录
    [self setupDownloadDirectory];

    // 1.3 初始化UI组件
    [self setupUserInterface];

    // 1.4 设置基础参数
    self.selectedTrackIndex = -1;

    NSLog(@"[Step 1] 组件初始化完成");
}

/**
 * 1.1 初始化私有服务
 */
- (void)initPrivateService {
    // 配置安全下载的加密校验文件
    NSString *encryptFilePath = [[NSBundle mainBundle] pathForResource:@"encryptedApp" ofType:@"dat"];
    if (encryptFilePath) {
        [AliPrivateService initKey:encryptFilePath];
        NSLog(@"[Step 1.1] 安全下载密钥文件配置成功: %@", encryptFilePath);
    } else {
        NSLog(@"[Step 1.1] 警告：未找到安全下载密钥文件 encryptedApp.dat");
    }
}

/**
 * 1.2 设置下载目录
 */
- (void)setupDownloadDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (paths.count > 0) {
        self.downloadPath = [paths[0] stringByAppendingPathComponent:@"Downloads"];

        // 创建下载目录
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:self.downloadPath]) {
            NSError *error;
            [fileManager createDirectoryAtPath:self.downloadPath
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:&error];
            if (error) {
                NSLog(@"[Step 1.2] 创建下载目录失败: %@", error.localizedDescription);
            }
        }

        NSLog(@"[Step 1.2] 下载目录设置成功: %@", self.downloadPath);
    } else {
        NSLog(@"[Step 1.2] 获取下载目录失败");
    }
}

/**
 * 1.3 初始化UI视图
 */
- (void)setupUserInterface {
    NSLog(@"[Step 1.3] 开始初始化UI界面");

    // 1.3.1 创建播放器视图容器
    [self setupPlayerView];

    // 1.3.2 创建状态显示标签
    [self setupStatusLabels];

    // 1.3.3 创建进度显示控件
    [self setupProgressControls];

    // 1.3.4 创建轨道选择列表
    [self setupTrackTableView];

    // 1.3.5 创建下载控制按钮
    [self setupDownloadButton];

    // 1.3.6 设置布局约束
    [self setupConstraints];

    NSLog(@"[Step 1.3] UI界面初始化完成");
}

/**
 * 1.3.1 创建用于承载播放画面的视图容器，并设置播放器渲染视图
 */
- (void)setupPlayerView {
    self.playerView = [[UIView alloc] init];
    self.playerView.backgroundColor = [UIColor blackColor];
    self.playerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.playerView];
}

/**
 * 1.3.2 创建状态显示标签
 */
- (void)setupStatusLabels {
    // 主状态标签
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = @"正在初始化...";
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.font = [UIFont systemFontOfSize:16];
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.statusLabel];

    // 进度显示标签
    self.progressLabel = [[UILabel alloc] init];
    self.progressLabel.text = @"";
    self.progressLabel.textAlignment = NSTextAlignmentCenter;
    self.progressLabel.font = [UIFont systemFontOfSize:14];
    self.progressLabel.textColor = [UIColor systemBlueColor];
    self.progressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.progressLabel];
}

/**
 * 1.3.3 创建进度显示控件
 */
- (void)setupProgressControls {
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.progress = 0.0;
    self.progressView.hidden = YES;
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.progressView];
}

/**
 * 1.3.4 创建轨道选择列表
 */
- (void)setupTrackTableView {
    self.trackTableView = [[UITableView alloc] init];
    self.trackTableView.dataSource = self;
    self.trackTableView.delegate = self;
    self.trackTableView.hidden = YES;
    self.trackTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.trackTableView registerClass:[DownloaderTrackCell class] forCellReuseIdentifier:@"DownloaderTrackCell"];
    [self.view addSubview:self.trackTableView];
}

/**
 * 1.3.5 创建下载控制按钮
 */
- (void)setupDownloadButton {
    self.downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.downloadButton setTitle:@"开始下载" forState:UIControlStateNormal];
    self.downloadButton.backgroundColor = [UIColor systemBlueColor];
    self.downloadButton.layer.cornerRadius = 8;
    [self.downloadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.downloadButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.downloadButton.hidden = YES;
    self.downloadButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.downloadButton addTarget:self action:@selector(downloadButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.downloadButton];
}

/**
 * 1.3.6 设置布局约束
 */
- (void)setupConstraints {
    [NSLayoutConstraint activateConstraints:@[
        // 播放器视图
        [self.playerView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.playerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.playerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.playerView.heightAnchor constraintEqualToConstant:200],

        // 状态标签
        [self.statusLabel.topAnchor constraintEqualToAnchor:self.playerView.bottomAnchor constant:20],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],

        // 进度标签
        [self.progressLabel.topAnchor constraintEqualToAnchor:self.statusLabel.bottomAnchor constant:10],
        [self.progressLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.progressLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],

        // 进度条
        [self.progressView.topAnchor constraintEqualToAnchor:self.progressLabel.bottomAnchor constant:10],
        [self.progressView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.progressView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],

        // 轨道列表
        [self.trackTableView.topAnchor constraintEqualToAnchor:self.progressView.bottomAnchor constant:20],
        [self.trackTableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.trackTableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.trackTableView.bottomAnchor constraintEqualToAnchor:self.downloadButton.topAnchor constant:-20],

        // 下载按钮
        [self.downloadButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.downloadButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.downloadButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
        [self.downloadButton.heightAnchor constraintEqualToConstant:50]
    ]];
}

#pragma mark - Step 2: 网络请求

/**
 * Step 2: 网络请求
 */
- (void)performNetworkRequest {
    NSLog(@"[Step 2] 开始网络请求");

    // 2.1 创建网络请求工具类实例
    HttpClientUtils *httpClientUtils = [[HttpClientUtils alloc] init];

    // 2.2 调用fetchPlayAuthWithVideoId方法请求playAuth
    /**
     简单的网络请求 实际项目中请替换为您项目中的网络请求工具
     kSampleRequestUrl 换自己的 API 域名业务进行业务请求
     */
    [httpClientUtils fetchPlayAuthWithVideoId:kSampleRequestUrl videoId:kSampleRequestVid completion:^(NSString * _Nonnull playAuth, NSError * _Nonnull error) {
        if (error) {
            NSLog(@"[Step 2] 请求失败 %@", error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateStatus:@"网络请求失败"];
            });
        } else {
            if (playAuth == nil) {
                NSLog(@"[Step 2] 网络请求数据为空");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateStatus:@"网络请求数据为空"];
                });
            } else {
                // 请求成功
                NSLog(@"[Step 2] playAuth请求成功%@", playAuth);
                [self prepareDownloaderSource:kSampleRequestVid playAuth:playAuth];
            }
        }
    }];
}

#pragma mark - Step 3: 播放器初始化

/**
 * Step 3: 设置播放器
 */
- (void)setupPlayer {
    NSLog(@"[Step 3] 开始设置播放器");

    // 3.1 创建播放器实例
    self.player = [[AliPlayer alloc] init];

    if (self.player) {
        // 3.2 设置播放器渲染视图
        self.player.playerView = self.playerView;

        // 3.3 设置播放器代理
        self.player.delegate = self;

        // 可选：推荐使用`播放器单点追查`功能，当使用阿里云播放器 SDK 播放视频发生异常时，可借助单点追查功能针对具体某个用户或某次播放会话的异常播放行为进行全链路追踪，以便您能快速诊断问题原因，可有效改善播放体验治理效率。
        // traceId 值由您自行定义，需为您的用户或用户设备的唯一标识符，例如传入您业务的 userid 或者 IMEI、IDFA 等您业务用户的设备 ID。
        // 传入 traceId 后，埋点日志上报功能开启，后续可以使用播放质量监控、单点追查和视频播放统计功能。
        // 文档：https://help.aliyun.com/zh/vod/developer-reference/single-point-tracing
        //[self.player setTraceID:traceId];

        NSLog(@"[Step 3] 播放器设置完成");
    } else {
        NSLog(@"[Step 3] 播放器创建失败");
        [self updateStatus:@"播放器创建失败"];
    }
}

#pragma mark - Step 4: 下载器初始化

/**
 * Step 4: 设置下载器
 */
- (void)setupDownloader {
    NSLog(@"[Step 4] 开始设置下载器");

    // 4.1 创建下载器实例
    self.downloader = [[AliMediaDownloader alloc] init];
    if (!self.downloader) {
        NSLog(@"[Step 4] 下载器创建失败");
        [self updateStatus:@"下载器创建失败"];
        return;
    }

    // 4.2 配置下载保存路径
    [self.downloader setSaveDirectory:self.downloadPath];

    // 4.3 设置下载器代理
    [self.downloader setDelegate:self];

    NSLog(@"[Step 4] 下载器设置完成");
}

#pragma mark - Step 5: 准备下载源

/**
 * Step 5: 准备下载源
 */
- (void)prepareDownloaderSource:(NSString *)videoId playAuth:(NSString *)playAuth {
    NSLog(@"[Step 5] 开始准备下载源 - VideoId: %@", videoId);

    if (!self.downloader) {
        [self updateStatus:@"下载器未初始化"];
        return;
    }

    // 5.1 创建VidAuth下载源
    AVPVidAuthSource *authSource = [[AVPVidAuthSource alloc] init];
    authSource.vid = videoId;
    authSource.playAuth = playAuth;

    // 5.2 保存当前下载源，用于后续更新
    self.currentVidAuthSource = authSource;

    // 5.3 准备下载源
    [self.downloader prepareWithPlayAuth:authSource];
}

#pragma mark - Step 6: 轨道选择和下载控制

/**
 * Step 6: 下载按钮点击事件处理
 */
- (void)downloadButtonTapped {
    if (self.selectedTrackIndex < 0 || self.selectedTrackIndex >= self.trackInfos.count) {
        [self showAlert:@"提示" message:@"请先选择要下载的轨道"];
        return;
    }

    [self startDownload];
}

/**
 * 6.1 开始下载
 */
- (void)startDownload {
    if (!self.downloader || !self.trackInfos || self.trackInfos.count == 0) {
        [self updateStatus:@"下载器或轨道信息未准备好"];
        return;
    }

    AVPTrackInfo *selectedTrack = self.trackInfos[self.selectedTrackIndex];

    // 6.1.1 选择下载轨道
    [self.downloader selectTrack:selectedTrack.trackIndex];

    // 6.1.2 更新下载源（防止PlayAuth过期）
    if (self.currentVidAuthSource) {
        [self.downloader updateWithPlayAuth:self.currentVidAuthSource];
    }

    // 6.1.3 开始下载
    [self.downloader start];

    // 6.1.4 更新UI状态
    [self updateStatus:@"开始下载..."];
    self.downloadButton.hidden = YES;
    self.trackTableView.userInteractionEnabled = NO;
    self.progressView.hidden = NO;

    NSLog(@"[Step 6.1] 开始下载轨道 - Index: %ld", (long)selectedTrack.trackIndex);
}

#pragma mark - Step 7: 下载进度监听

/**
 * Step 7: 下载器事件处理
 */
- (void)onPrepared:(AliMediaDownloader *)downloader mediaInfo:(AVPMediaInfo *)info {
    NSLog(@"[Step 7] 下载项准备成功，获取到 %lu 个轨道", (unsigned long)info.tracks.count);

    dispatch_async(dispatch_get_main_queue(), ^{
        [self handleDownloaderPrepared:info];
    });
}

/**
 * 7.1 处理下载器准备完成事件
 */
- (void)handleDownloaderPrepared:(AVPMediaInfo *)mediaInfo {
    if (!mediaInfo || !mediaInfo.tracks || mediaInfo.tracks.count == 0) {
        [self updateStatus:@"没有可下载的轨道"];
        return;
    }

    self.trackInfos = mediaInfo.tracks;

    // 7.1.1 展示下载选项供用户选择
    [self showDownloadOptions];
}

/**
 * 7.2 展示下载选项
 */
- (void)showDownloadOptions {
    [self updateStatus:@"请选择要下载的清晰度"];

    self.trackTableView.hidden = NO;
    self.downloadButton.hidden = NO;

    [self.trackTableView reloadData];

    // 7.2.1 默认选择第一个视频轨道
    NSInteger defaultIndex = [self findDefaultVideoTrackIndex];
    if (defaultIndex >= 0) {
        self.selectedTrackIndex = defaultIndex;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:defaultIndex inSection:0];
        [self.trackTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

/**
 * 7.3 查找默认的视频轨道索引
 */
- (NSInteger)findDefaultVideoTrackIndex {
    for (NSInteger i = 0; i < self.trackInfos.count; i++) {
        AVPTrackInfo *trackInfo = self.trackInfos[i];
        if (trackInfo.trackType == AVPTRACK_TYPE_VIDEO) {
            return i;
        }
    }
    return 0; // 如果没找到视频轨道，返回第一个
}

/**
 * @brief 下载进度回调
 * @param downloader 下载器实例
 * @param percent 下载进度百分比
 */
- (void)onDownloadingProgress:(AliMediaDownloader *)downloader percentage:(int)percent {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateProgress:percent];
    });
}

/**
 * 更新下载进度显示
 */
- (void)updateProgress:(int)percent {
    self.progressView.progress = percent / 100.0;
    self.progressLabel.text = [NSString stringWithFormat:@"下载进度: %d%%", percent];
}

#pragma mark - Step 8: 下载完成处理

/**
 * @brief 下载完成回调
 * @param downloader 下载器实例
 */
- (void)onCompletion:(AliMediaDownloader *)downloader {
    NSLog(@"[Step 8] 视频下载成功");

    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateStatus:@"下载完成！"];
        [self updateProgress:100];
        [self resetDownloadUI];
        [self showAlert:@"成功" message:@"视频下载完成！"];
    });
}

/**
 * 重置下载UI状态
 */
- (void)resetDownloadUI {
    self.downloadButton.hidden = NO;
    self.trackTableView.userInteractionEnabled = YES;
    // 保持进度条显示，方便用户查看最终结果
}

#pragma mark - UITableView数据源和代理方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.trackInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloaderTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloaderTrackCell" forIndexPath:indexPath];

    if (indexPath.row < self.trackInfos.count) {
        AVPTrackInfo *trackInfo = self.trackInfos[indexPath.row];
        [cell configureWithTrackInfo:trackInfo isSelected:(indexPath.row == self.selectedTrackIndex)];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedTrackIndex = indexPath.row;
    [tableView reloadData];

    AVPTrackInfo *selectedTrack = self.trackInfos[indexPath.row];
    NSLog(@"[轨道选择] 选中轨道: %ld", (long)selectedTrack.trackIndex);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - 播放器事件处理

/**
 * @brief 播放器事件回调
 * @param player 播放器实例
 * @param eventType 事件类型
 */
- (void)onPlayerEvent:(AliPlayer *)player eventType:(AVPEventType)eventType {
    NSLog(@"[播放器事件] 事件类型: %ld", (long)eventType);
}

#pragma mark - 错误处理

/**
 * @brief 统一的错误处理方法
 * @param sender 错误发送者（播放器或下载器）
 * @param errorModel 错误信息模型
 */
- (void)onError:(id)sender errorModel:(AVPErrorModel *)errorModel {
    NSString *senderType = @"未知";

    if ([sender isKindOfClass:[AliPlayer class]]) {
        senderType = @"播放器";
        NSLog(@"[播放器错误] %@", errorModel.message);
    } else if ([sender isKindOfClass:[AliMediaDownloader class]]) {
        senderType = @"下载器";
        NSLog(@"[下载器错误] %@", errorModel.message);

        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateStatus:[NSString stringWithFormat:@"下载失败: %@", errorModel.message]];
            [self resetDownloadUI];
            [self showAlert:@"下载失败" message:errorModel.message];
        });
    }

    NSLog(@"[错误处理] %@发生错误: %@ (错误码: %ld)", senderType, errorModel.message, (long)errorModel.code);
}
#pragma mark - Step 9: 视频播放
/**
 Step 9：视频播放
 本模块只提供了下载API 示例，您可以参考文档自行实现播放功能
 // 通过点播UrlSource方式设置本地视频地址进行播放
 AVPUrlSource *urlSource = [[AVPUrlSource alloc] urlWithString:url];
 [self.player setUrlSource:urlSource];
 // 开始播放
 [self.player start];
 参考文档：https://help.aliyun.com/zh/vod/developer-reference/basic-features-2
 */



#pragma mark - Step 10: 资源清理

/**
 * Step 10: 清理资源
 */
- (void)cleanupResources {
    NSLog(@"[Step 9] 开始资源清理");

    // 10.1 停止并释放播放器实例
    if (self.player) {
        [self.player stop];
        [self.player destroy];
        self.player = nil;
    }

    // 10.2 停止并释放下载器实例
    if (self.downloader) {
        [self.downloader destroy];
        self.downloader = nil;
    }

    // 10.3 清空相关引用，避免内存泄漏
    self.trackInfos = nil;
    self.currentVidAuthSource = nil;

    NSLog(@"[Step 9] 资源清理完成");
}

#pragma mark - 辅助方法

/**
 * 更新状态显示
 */
- (void)updateStatus:(NSString *)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.text = status;
        NSLog(@"[状态更新] %@", status);
    });
}

/**
 * 显示提示框
 */
- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];

    [self presentViewController:alert animated:YES completion:nil];
}

@end
