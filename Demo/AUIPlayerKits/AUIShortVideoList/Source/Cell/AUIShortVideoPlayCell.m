//
//  AUIShortVideoPlayCell.m
//  AUIPlayer
//
//  Created by keria on 2024/11/14.
//

#import "AUIShortVideoPlayCell.h"
#import "AliVideoView.h"
#import "AUIShortVideoListConstants.h"
#import "AUIShortVideoListMacro.h"
#import "AUIShortVideoInteractiveView.h"
#import "AUIShortVideoListUtils.h"

@interface AUIShortVideoPlayCell () <AliVideoViewPlayerEventObserver>

@property (nonatomic, strong) AliVideoView *videoView;
@property (nonatomic, strong) AUIShortVideoInfo* videoInfo;

@property (nonatomic, strong) UIImageView *coverLayer;
@property (nonatomic, strong) UILabel *rateLabel;
@property (nonatomic, strong) AVBlockButton *pauseBtn;
@property (nonatomic, strong) AVVideoPlayProgressView *progressView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UILabel *durationLabel;

@property (nonatomic, strong) AUIShortVideoInteractiveView *interactiveView;
@property (nonatomic, strong) AVBaseButton *dramaBtn;
@property (nonatomic, strong) UIButton *settingBtn;
@property (nonatomic, strong) AVBlockButton *backButton;

@property (nonatomic, strong) NSArray<AVPTrackInfo*>* trackInfoList;

@end

@implementation AUIShortVideoPlayCell

#pragma mark - LifeCycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = [UIColor greenColor];
        
        // 添加长按事件
        [self setupLongPressGesture];
        
        [self setupPlayerView];
        
        [self setupUIComponents];
        
        NSLog(@"[init] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
    }
    return self;
}

// 释放资源
- (void)dealloc {
    NSLog(@"[dealloc] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
    // 移除手势
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [self removeGestureRecognizer:gesture];
        }
    }
}

// 清理资源，比如停止定时器、取消网络请求等
- (void)prepareForReuse {
    [super prepareForReuse];
    
    SLOGI(@"[REUSE], <%@: %p>", NSStringFromClass([self class]), self);
    
    [self unbind];
    [self clear];
}

// 资源清理方法
- (void)clear {
    // UI 操作需要在主线程执行
    dispatch_async(dispatch_get_main_queue(), ^{
        // 重置快进状态
        self.rateLabel.hidden = YES;
        
        // 重置播放状态
        [self showPauseBtn:NO];
        
        // 重置进度条 UI
        [self.progressView setProgress:0];
        
        // 重置标题
        [self.titleLabel setText:nil];
        
        // 重置详情
        [self.infoLabel setText:nil];
    });
}

// 返回对象的字符串描述
- (NSString *)description {
    return [NSString stringWithFormat:@"<AUIShortVideoPlayCell: %p; frame = %@>", self, NSStringFromCGRect(self.bounds)];
}

#pragma mark - View Layout

- (void)setupPlayerView {
    self.videoView = [[AliVideoView alloc] initWithEventObserver:self];
    self.videoView.frame = self.bounds;
//    self.videoView.backgroundColor = [UIColor greenColor];
    [self.contentView addSubview:self.videoView];
    
    // 如果未开启封面 URL 策略，封面图 layer 将不显示
    if (AUIShortVideoListConstants.enableCoverURLStrategy) {
        self.coverLayer = [[UIImageView alloc] init];
        self.coverLayer.frame = self.bounds;
//        self.coverLayer.backgroundColor = [UIColor yellowColor];
        self.coverLayer.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.coverLayer];
    }
    
    self.pauseBtn = [[AVBlockButton alloc] init];
    self.pauseBtn.frame = self.bounds;
    [self.pauseBtn setImage:SVCommonImage(@"ic_play") forState:UIControlStateSelected];
    
    // 创建弱引用，以避免循环引用
    __weak typeof(self) weakSelf = self;  // 弱引用 self
    __weak typeof(self.videoView) weakVideoView = self.videoView;  // 弱引用
    self.pauseBtn.clickBlock = ^(AVBlockButton * _Nonnull sender) {
        // 获取强引用以避免过早释放 self
        __strong typeof(weakSelf) strongSelf = weakSelf;
        __strong typeof(self.videoView) strongVideoView = weakVideoView; // 强引用
        if ([strongVideoView isPlaying]) {
            [strongVideoView pause];
            [strongSelf showPauseBtn:YES];
        } else {
            [strongVideoView start];
            [strongSelf showPauseBtn:NO];
        }
    };
    [self.contentView addSubview:self.pauseBtn];
}

- (void)setupUIComponents {
    // 创建弱引用，以避免循环引用
    __weak typeof(self) weakSelf = self;  // 弱引用 self
    __weak typeof(self.videoView) weakVideoView = self.videoView;  // 弱引用
    self.progressView = [[AVVideoPlayProgressView alloc] init];
    self.progressView.onProgressChangedByGesture = ^(float value) {
        __strong typeof(self.videoView) strongVideoView = weakVideoView; // 强引用
        [strongVideoView seek:(value >= 1.0 ? 0.99 : value)];
    };
    [self.contentView addSubview:self.progressView];
    
    
    self.progressLabel = [[UILabel alloc]init];
    self.progressLabel.textColor = UIColor.whiteColor;
    self.progressLabel.textAlignment = NSTextAlignmentCenter;
    self.progressLabel.text = @"00:00";
    [self.contentView addSubview:self.progressLabel];
    
    self.durationLabel = [[UILabel alloc]init];
    self.durationLabel.textColor = UIColor.whiteColor;
    self.durationLabel.textAlignment = NSTextAlignmentCenter;
    self.durationLabel.text = @"00:00";
    [self.contentView addSubview:self.durationLabel];
    
    self.infoLabel = [[UILabel alloc] init];
    self.infoLabel.textColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
    self.infoLabel.font = AVGetRegularFont(14);
    self.infoLabel.numberOfLines = 2;
    self.infoLabel.text = @"";
    [self.contentView addSubview:self.infoLabel];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor av_colorWithHexString:@"#FFFFFF"];
    self.titleLabel.font = AVGetMediumFont(16);
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.text = @"";
    [self.contentView addSubview:self.titleLabel];
    
    self.rateLabel = [[UILabel alloc] init];
    self.rateLabel.textColor = [UIColor whiteColor];
    self.rateLabel.font = AVGetMediumFont(16);
    self.rateLabel.numberOfLines = 1;
    self.rateLabel.text = SVString(@"increased speed");
    self.rateLabel.hidden = YES;
    self.rateLabel.clipsToBounds = YES;
    self.rateLabel.layer.cornerRadius = 5;
    self.rateLabel.backgroundColor = [UIColor av_colorWithHexString:@"#000000" alpha:0.4];
    self.rateLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.rateLabel];
    
    self.interactiveView = [[AUIShortVideoInteractiveView alloc] init];
    [self.interactiveView configureWithLikeAction:^{
        // TODO: 发送点赞请求给服务端，需要自己实现
        // 获取强引用以避免过早释放 self
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [AVToastView show:SVString(@"This feature is not supported yet and needs to be implemented.")
                     view:strongSelf.contentView
                 position:AVToastViewPositionMid];
    } commentAction:^{
        // TODO: 打开评论页面，需要自己实现
        // 获取强引用以避免过早释放 self
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [AVToastView show:SVString(@"This feature is not supported yet and needs to be implemented.")
                     view:strongSelf.contentView
                 position:AVToastViewPositionMid];
    } shareAction:^{
        // TODO: 打开分享页面，需要自己实现
        // 获取强引用以避免过早释放 self
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [AVToastView show:SVString(@"This feature is not supported yet and needs to be implemented.")
                     view:strongSelf.contentView
                 position:AVToastViewPositionMid];
    }];
    [self.contentView addSubview:self.interactiveView];
    
    self.dramaBtn = [[AVBaseButton alloc] initWithType:AVBaseButtonTypeImageText titlePos:AVBaseButtonTitlePosBottom];
    self.dramaBtn.image = SVCommonImage(@"ic_drama");
    self.dramaBtn.title = SVString(@"Series");
    self.dramaBtn.font = AVGetRegularFont(11);
    self.dramaBtn.action = ^(AVBaseButton * _Nonnull btn) {
        // 获取强引用以避免过早释放 self
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.onSelectionBlock) {
            strongSelf.onSelectionBlock(strongSelf);
        }
    };
    [self.contentView addSubview:self.dramaBtn];
    
    self.settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.interactiveView.frame.origin.x, self.interactiveView.frame.origin.y, 50,50)];
    self.settingBtn.frame = CGRectMake(0, 0, 50, 50);
    [self.settingBtn setImage:SVCommonImage(@"ic_setting") forState:UIControlStateNormal];
    
    // 获取屏幕宽度
    CGFloat screenWidth = self.contentView.bounds.size.width;
    
    // 计算按钮的位置使其位于右上角
    CGFloat xPosition = screenWidth - self.settingBtn.frame.size.width - 10;  // 减去一些边距
    self.settingBtn.frame = CGRectMake(xPosition, AVSafeTop + 20, self.settingBtn.frame.size.width, self.settingBtn.frame.size.height);
    [self.settingBtn addTarget:self action:@selector(onSettingBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.settingBtn];
    
    
    self.backButton = [AVBlockButton new];
    [self.backButton setImage:AUIFoundationImage(@"ic_back") forState:UIControlStateNormal];
    self.backButton.clickBlock = ^(AVBlockButton * _Nonnull sender) {
        if (weakSelf.onBackBtnClickBlock) {
            weakSelf.onBackBtnClickBlock(weakSelf);
        }
    };
    [self.contentView addSubview:_backButton];

}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.videoView.frame = self.bounds;
    
    // 如果未开启封面 URL 策略，封面图 layer 将不显示
    if (AUIShortVideoListConstants.enableCoverURLStrategy && self.coverLayer) {
        self.coverLayer.frame = self.bounds;
    }
    
    self.pauseBtn.frame = self.bounds;
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    CGFloat y = height - (UIView.av_isIphoneX ? AVSafeBottom : 12);
    self.progressView.frame = CGRectMake(80, y - 26, width - 160, 26);
    y = self.progressView.frame.origin.y;
    
    self.progressLabel.frame = CGRectMake(0, y , 80, 26);
    self.durationLabel.frame = CGRectMake(width - 80, y, 80, 26);
    
    
    
    CGSize infoLabelSize = [self.infoLabel sizeThatFits:CGSizeMake(width - 100, 0)];
    self.infoLabel.frame = CGRectMake(20, y - infoLabelSize.height, infoLabelSize.width, infoLabelSize.height);
    y = self.infoLabel.frame.origin.y - 8;
    
    self.titleLabel.frame = CGRectMake(20, y - 24, width - 100, 24);
    self.rateLabel.frame = CGRectMake(width / 2 - 75, y - 64, 150, 24);
    
    y = self.contentView.av_height - 186;
    
    self.interactiveView.frame = CGRectMake(self.contentView.av_width - 60, y - 60 * 2, 60, 60 * 3);
    
    self.dramaBtn.frame = CGRectMake(self.contentView.av_width - 48 - 4, self.interactiveView.av_bottom + 12, 48, 48);
    
    self.backButton.frame = CGRectMake(20, AVSafeTop + 20, 26, 26);
}

#pragma mark - Button Actions

// 处理按钮点击事件
- (void)onSettingBtnClicked:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    if (weakSelf.onSettingBlock){
        weakSelf.onSettingBlock(weakSelf, weakSelf.trackInfoList);
    }
}

#pragma mark - API Methods

// 绑定视频信息到单元格
- (void)bindData:(AUIShortVideoInfo *)videoInfo {
    if (!videoInfo || self.videoInfo == videoInfo) {
        return;
    }
    self.videoInfo = videoInfo;
    
    SLOGI(@"[BIND_DATA], %@, %@->%@", self, self.videoInfo, videoInfo);
    
    [self showPauseBtn:NO];
    
    // 在绑定视频信息时，显示封面图并尝试加载它
    [self showCoverImage:YES];
    [self loadCoverImage];
}

// 将当前视频绑定到单元格
- (void)bind {
    SLOGI(@"[BIND], %@, %@, %@", self, self.videoInfo, self.videoView);
    
    if (self.videoView && self.videoInfo) {
        [self.videoView bind:self.videoInfo];
    }
}

// 解除视频与单元格的绑定
- (void)unbind {
    SLOGI(@"[UNBIND], %@", self);
    
    // 显示封面图以避免黑屏
    [self showCoverImage:YES];
    
    if (self.videoView) {
        [self.videoView unbind];
    }
    
    self.videoInfo = nil;
}

// 开始播放视频
- (void)start {
    if (!self.videoView || !self.videoInfo) {
        return;
    }
    
    SLOGI(@"[START], %@", self);
    [self.videoView start];
    [self showPauseBtn:NO];
}

// 暂停视频播放
- (void)pause {
    if (!self.videoView || !self.videoInfo) {
        return;
    }
    
    SLOGI(@"[PAUSE], %@", self);
    [self.videoView pause];
}

//设置倍速
- (void)setSpeed:(CGFloat)value{
    if (!self.videoView)return;
    [self.videoView setSpeed:value];
}

// 跳转进度
- (void)seekToPosition:(int64_t)position {
    if (!self.videoView)return;
    [self.videoView seekToPosition:position];
}

//设置清晰度
- (void)selectTrack:(AVPTrackInfo *)trackInfo{
    if (!self.videoView)return;
    [self.videoView selectTrack:trackInfo];
}

// 设置带宽值
- (void)setBandwidth:(NSInteger)bandwidth {
    if (!self.videoView)return;
    [self.videoView setBandwidth:bandwidth];
}

#pragma mark - Play Btn

// 控制暂停按钮的显示和隐藏；仅在手动操作暂停/恢复播放时，切换按钮显示状态，其它情况下不作处理
- (void)showPauseBtn:(BOOL)enable {
    // 在主线程上更新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        self.pauseBtn.selected = enable;
    });
}

#pragma mark - Cover Image

// 控制封面图的显示和隐藏；如果为 YES，显示封面图；如果为 NO，隐藏封面图。
- (void)showCoverImage:(BOOL)enable {
    // 检查是否启用了封面 URL 策略
    if (!AUIShortVideoListConstants.enableCoverURLStrategy) {
        return;
    }
    
    // 验证 coverLayer 是否已经初始化
    if (!self.coverLayer) {
        return;
    }
    
    // 检查 coverLayer 是否需要更新显示状态
    if (self.coverLayer.hidden == !enable) {
        return;
    }
    
    // 在主线程上更新 UI
    dispatch_async(dispatch_get_main_queue(), ^{
        // 根据参数控制封面图的显示或隐藏
        if (!enable){
            [UIView animateWithDuration:0.2 animations:^{
                // 透明度从 1.0 变为 0.0
                self.coverLayer.alpha = 0.0;
            } completion:^(BOOL finished) {
                // 动画结束后，将视图设为隐藏（释放布局空间）
                self.coverLayer.hidden = YES;
                // 可选：设置 alpha 为 1，避免下次显示时出错
            }];
        } else {
            self.coverLayer.alpha = 1;
            self.coverLayer.hidden = NO;
        }

    });
    
    NSInteger videoId = self.videoInfo ? self.videoInfo.videoId : -1;
    // 记录封面图显示隐藏的日志
    SLOGI(@"[COVER][API][SHOW][%@][%ld]", enable ? @"YES" : @"NO", videoId);
}

// 加载并显示视频封面图，只有在启用了封面 URL 策略的情况下，并且 videoInfo 和封面 URL 是有效的时，才会尝试加载封面图。
- (void)loadCoverImage {
    // 检查是否启用了封面 URL 策略
    if (!AUIShortVideoListConstants.enableCoverURLStrategy) {
        return;
    }
    
    // 验证 videoInfo 和封面 URL 的有效性
    if (!self.videoInfo || ![AUIShortVideoListUtils isValidURLString:self.videoInfo.coverUrl]) {
        return;
    }
    
    // 验证 coverLayer 是否已经初始化
    if (!self.coverLayer) {
        return;
    }
    
    NSInteger videoId = self.videoInfo.videoId;
    // 生成封面图的 URL
    NSURL *imageURL = [NSURL URLWithString:self.videoInfo.coverUrl];
    
    // 使用 SDWebImage 库异步加载封面图
    [self.coverLayer sd_setImageWithURL:imageURL
                              completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (error) {
            // 加载失败时记录错误信息
            SLOGE(@"[COVER][CBK][LOAD][ERROR][%ld], %@", videoId, error.localizedDescription);
        } else {
            // 加载成功时记录成功信息
            SLOGI(@"[COVER][CBK][LOAD][SUCCESS][%ld]", videoId);
        }
    }];
    
    // 记录加载开始的日志
    SLOGI(@"[COVER][API][LOAD][%ld]", videoId);
}


#pragma mark - AliVideoViewPlayerEventObserver

// 播放准备完毕回调
- (void)onPrepared:(AliVideoView *)videoView {
    self.trackInfoList = [videoView getVideoTracks];
    
    
}

// 播放进度更新回调
- (void)onPlayPositionUpdate:(AliVideoView *)videoView position:(int64_t)position duration:(int64_t)duration {
    CGFloat progress = (duration > 0) ? (position / (CGFloat)duration) : 0;
    // 在主线程上更新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView setProgress:progress];
        self.progressLabel.text = [self formattedTimeFromProgress:position];
        self.durationLabel.text = [self formattedTimeFromProgress:duration];
    });
    
    if (self.onPositionChanged){
        self.onPositionChanged(self, position,duration);
    }
}

// 缓冲进度更新回调
- (void)onPlayBufferedPositionUpdate:(AliVideoView *)videoView position:(int64_t)position duration:(int64_t)duration {
}

// 播放状态变化回调
- (void)onPlayStatusChanged:(AliVideoView *)videoView oldStatus:(AVPStatus)oldStatus newStatus:(AVPStatus)newStatus {
    // Tips: 修复向上滑动切换cell时封面图不消失的问题
    if (newStatus == AVPStatusStarted){
        [self showCoverImage:NO];
    }
    
    
    if(self.onStatusChanged){
        self.onStatusChanged(self, newStatus);
    }
}

// 渲染开始回调
- (void)onRenderingStart:(AliVideoView *)videoView duration:(int64_t)duration {
    // Tips: 保持原有逻辑，出现首帧渲染时隐藏封面图
    // 如果准备完毕，封面图 layer 将不显示
    [self showCoverImage:NO];
}

// 播放完成回调
- (void)onCompletion:(AliVideoView *)videoView {
    if (_onCompletionBlock) {
        _onCompletionBlock(self);
    }
}

- (void)onTrackSuccess:(AliVideoView *)videoView trackInfo:(AVPTrackInfo *)trackInfo{
    if (!trackInfo)return;
    if (_onTrackChanged){
        _onTrackChanged(self,trackInfo);
    }
}

// 播放错误回调
- (void)onError:(AliVideoView *)videoView errorInfo:(AVPErrorModel *)errorModel {
    if (errorModel != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *msg =[NSString stringWithFormat:@"发生错误：[%ld], %@", errorModel.code, errorModel.message];
            [AVToastView show:msg view:self position:AVToastViewPositionBottom];
        });
    }
}


#pragma mark - Gestures

// 配置长按手势
- (void)setupLongPressGesture {
    // 创建一个长按手势识别器，设置回调方法为 handleLongPress:
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGesture.minimumPressDuration = 0.5; // 设置长按时间为0.5秒
    [self addGestureRecognizer:longPressGesture]; // 将手势识别器添加到视图中
}

// 处理长按手势
- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (!self.videoView || ![self.videoView isPlaying]) {
        // 如果 videoView 不存在或者不在播放，不做任何处理
        return;
    }
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            // 当手势开始时，显示速率标签并加速播放
            [self showRateLabelAndIncreaseSpeed];
            break;
        case UIGestureRecognizerStateChanged:
            // 手势处于变化状态时，可以在此处扩展持续触发的逻辑
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            // 当手势结束或取消时，隐藏速率标签并重置播放速度
            [self hideRateLabelAndResetSpeed];
            break;
        default:
            break;
    }
}

// 显示速率标签并加速播放
- (void)showRateLabelAndIncreaseSpeed {
    self.rateLabel.hidden = NO;
    if (self.videoView) {
        [self.videoView setSpeed:3];
    }
}

// 隐藏速率标签并重置播放速度
- (void)hideRateLabelAndResetSpeed {
    self.rateLabel.hidden = YES;
    
    if (self.videoView) {
        [self.videoView setSpeed:1]; // 重置倍速到正常速度
    }
}

/**
 * 获取时长*
 */
- (NSString *)formattedTimeFromProgress:(float)progress{
    float test= progress / 1000;
    // 计算当前进度所对应的总秒数
    // 计算小时、分钟和秒
    int hours = (int)(test / 3600);
    int minutes = (int)((test - (hours * 3600)) / 60);
    int seconds = (int)(test - (hours * 3600) - (minutes * 60));
    
//    NSString* hourStr = [NSString stringWithFormat:@"%02d",hours];
//    if (hours < 10){
//        hourStr =[NSString stringWithFormat:@"0%02d",hours];
//    }
    
    NSString* minutesStr = [NSString stringWithFormat:@"%02d",minutes];
    if (minutes < 10){
        minutesStr =[NSString stringWithFormat:@"0%02d",minutes];
    }
    
    NSString* secondsStr = [NSString stringWithFormat:@"%02d",seconds];
    if (seconds < 10){
        secondsStr =[NSString stringWithFormat:@"0%02d",seconds];
    }
        
    // 格式化字符串为 "HH:mm:ss"
//    NSString *timeString = [NSString stringWithFormat:@"%@:%@:%@", hourStr, minutesStr, secondsStr];
    
//    if (hours <= 0){
    NSString *timeString = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
//    }
    
    return timeString;
}

/**
 * 根据字体和字符串获取宽度
 */
- (void)adjustLabelWidth:(UILabel *)label withText:(NSString *)text andFont:(UIFont *)font {
    // 设置要显示的文本
    label.text = text;
    
    // 计算文本的宽度
    CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName: font}];
    
    // 更新UILabel的frame以适应文本宽度
    CGRect labelFrame = label.frame;
    labelFrame.size.width = textSize.width;
    label.frame = labelFrame;
}


- (BOOL)onPiPRenderPixelBuffer:(CVPixelBufferRef)pixelBuffer fromVideoView:(AliVideoView *)videoView {
    if (_onPiPEnqueuePixelBuffer) {
        return _onPiPEnqueuePixelBuffer(self, pixelBuffer);
    }
    return NO;
}

@end
