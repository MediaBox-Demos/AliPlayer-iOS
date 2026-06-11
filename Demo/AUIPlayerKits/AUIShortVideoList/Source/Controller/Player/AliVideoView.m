//
//  AliVideoView.m
//  AUIPlayer
//
//  Created by keria on 2024/11/13.
//

#import "AliVideoView.h"
#import "AUIShortVideoListMacro.h"
#import "AUIShortVideoListUtils.h"
#import "AUIVideoTrackInfoUtil.h"
#import "AUIShortVideoListConstants.h"
#import "AliPlayerPool.h"
#import <SDWebImage/SDWebImage.h>

@interface AliVideoView () <AVPDelegate, CicadaRenderingDelegate>

// 委托属性，用于通知 delegate
@property (nonatomic, weak) id<AliVideoViewPlayerEventObserver> delegate;

@property (nonatomic, strong) UIView *playerView;

@property (nonatomic, weak) AliPlayer *aliPlayer;

@property (nonatomic, weak) AUIShortVideoInfo *videoInfo;

@property (nonatomic, assign) BOOL hasPrepared;

@property (nonatomic, assign) long prepareStartTime;

@property (nonatomic, assign) int64_t playDuration;

@property (nonatomic, assign) AVPStatus playerStatus;

@property (nonatomic, assign) int selectedTrackBitrate;

@end

@implementation AliVideoView

#pragma mark - LifeCycle

// 初始化视频播放器视图
- (instancetype)initWithEventObserver:(id<AliVideoViewPlayerEventObserver>)delegate {
    self = [super init];
    
    if (self) {
//        self.backgroundColor = [UIColor redColor];
        
        self.playerView = [[UIView alloc] init];
//        self.playerView.backgroundColor = [UIColor purpleColor];
        
        self.aliPlayer = nil;
        self.videoInfo = nil;
        
        self.delegate = delegate;
        
        self.hasPrepared = NO;
        self.prepareStartTime = 0;
        self.playDuration = -1;
        self.playerStatus = AVPStatusIdle;
        self.selectedTrackBitrate = 0;
        
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
    [self unbind];
    
    // 清除代理
    self.delegate = nil;
}

// 返回对象的字符串描述
- (NSString *)description {
    return [NSString stringWithFormat:@"<AliVideoView: %p; videoInfo = %p; aliPlayer = %p>", self, self.videoInfo, self.aliPlayer];
}

#pragma mark - View Layout

// 布局子视图
- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 确保播放器视图占据整个视图
    self.playerView.frame = self.bounds;
    [self addSubview:self.playerView];
}

#pragma mark - API Methods

// 绑定新的视频信息到播放器
- (void)bind:(AUIShortVideoInfo *)videoInfo {
    if (!videoInfo || ![AUIShortVideoListUtils isValidURLString:videoInfo.url]) {
        return;
    }
    
    SLOGI(@"[API][BIND][%@], %@->%@", self, self.videoInfo, videoInfo);
    self.videoInfo = videoInfo;
    
    [self bindVideoPlayer];
}

// 绑定视频播放器
- (void)bindVideoPlayer {
    // 检查视频信息和URL是否有效，以确保可以通过有效的索引从播放器池获取播放器实例
    if (!self.videoInfo || ![AUIShortVideoListUtils isValidURLString:self.videoInfo.url]) {
        return;
    }
    
    // 从播放器池中获取播放器实例，并将播放器实例与视图绑定
    AliPlayer *aliPlayer = [[AliPlayerPool sharedInstance] acquire:[NSString stringWithFormat:@"%ld",self.videoInfo.hash]];
    // 确保获取的播放器实例不为nil，否则断言以捕获错误
    NSAssert(aliPlayer, @"aliPlayer is nil");
    
    // 如果已经有一个相同的播放器实例，并且已 prepare，则不重复绑定
    if (aliPlayer == self.aliPlayer && self.hasPrepared) {
        return;
    }
    
    // 更新当前播放器实例为获取到的新实例
    SLOGI(@"[API][BIND_PLAYER][%@], %@->%@", self, self.aliPlayer, aliPlayer);
    self.aliPlayer = aliPlayer;
    
    
    
    // 设置播放器视图
    self.aliPlayer.playerView = self.playerView;
    SLOGI(@"[player][API][setView], %@, %@", self.aliPlayer, self.playerView);
    
    // 设置播放器代理
    self.aliPlayer.delegate = self;
    
    // 设置渲染回调接口获取视频帧回调
    self.aliPlayer.renderingDelegate = self;
    // 打开播放器后台解码
    [self.aliPlayer setOption:ALLOW_DECODE_BACKGROUND valueInt:1];
    
    // 设置播放视频源
    AVPUrlSource *urlSource = [[AVPUrlSource alloc] urlWithString:self.videoInfo.url];
    [self.aliPlayer setUrlSource:urlSource];
    SLOGI(@"[player][API][setUrlSource], %@, %@, %@", self.aliPlayer, self.videoInfo.url, urlSource);
    
    // 标记当前播放器已准备，防止重复调用
    // NOTE: @keria, 防止重复 prepare，导致 prepare 耗时较大；影响滑动体验
    // prepare 内部实现为，如果当前为重复 prepare，会执行 stop + prepare，其中 stop 耗时大约为 7ms，因此增大了 prepare 接口耗时
    self.hasPrepared = YES;
    
    // 设置指定清晰度
    if (self.selectedTrackBitrate > 0) {
        [self.aliPlayer setDefaultBandWidth:self.selectedTrackBitrate];
    }
    
    
    // 准备播放器，强制预渲染首帧图
    [self.aliPlayer prepare];
    SLOGI(@"[player][API][prepare], %@, DefaultBandWidth=%d", self.aliPlayer, self.selectedTrackBitrate);
}

// 解除视频播放器的绑定
- (void)unbind {
    SLOGI(@"[API][UNBIND][%@]", self);
    
    // 将播放器实例与视图解绑，并通知播放器池可以回收该实例
    if (self.videoInfo && [AUIShortVideoListUtils isValidURLString:self.videoInfo.url]) {
        [[AliPlayerPool sharedInstance] recycle:[NSString stringWithFormat:@"%ld",self.videoInfo.hash]];
    }
    
    // 清空播放器和视频信息以释放资源
    self.aliPlayer = nil;
    self.videoInfo = nil;
    
    // 重置播放器状态
    self.hasPrepared = NO;
    self.prepareStartTime = 0;
    self.playDuration = -1;
    self.playerStatus = AVPStatusIdle;
}

// 开始播放视频
- (void)start {
    if (self.aliPlayer) {
        [self.aliPlayer start];
        SLOGI(@"[player][API][start], %@", self.aliPlayer);
    }
}

// 暂停播放
- (void)pause {
    if (self.aliPlayer) {
        [self.aliPlayer pause];
        SLOGI(@"[player][API][pause], %@", self.aliPlayer);
    }
}

// 检查是否正在播放
- (BOOL)isPlaying {
    return self.playerStatus == AVPStatusStarted;
}

// 跳转到指定播放进度
- (void)seek:(CGFloat)progress {
    int64_t position = progress * self.playDuration;
    [self seekToPosition:position];
}

// 跳转到指定播放位置
- (void)seekToPosition:(int64_t)position {
    if (self.aliPlayer) {
        [self.aliPlayer seekToTime:position seekMode:AVP_SEEKMODE_ACCURATE];
    }
}

// 设置视频的循环播放
- (void)setLoop:(BOOL)loop {
    if (self.aliPlayer) {
        [self.aliPlayer setLoop:loop];
        SLOGI(@"[player][API][setLoop][%@], %@", loop ? @"YES" : @"NO", self.aliPlayer);
    }
}

// 设置播放速度
- (void)setSpeed:(CGFloat)rate {
    if (self.aliPlayer && rate > 0) {
        [self.aliPlayer setRate:rate];
    }
}

// 选择视频轨
- (void)selectTrack:(AVPTrackInfo *)trackInfo {
    if (!trackInfo || !self.aliPlayer) {
        return;
    }
    
    if (_selectedTrackBitrate == trackInfo.trackBitrate) {
        return;
    }
    
    _selectedTrackBitrate = trackInfo.trackBitrate;
    
    [self.aliPlayer selectTrack:trackInfo.trackIndex];
    SLOGI(@"[player][API][selectTrack][%d], bandwidth=%d, %@", trackInfo.trackIndex, trackInfo.trackBitrate, self.aliPlayer);
}

// 设置带宽值
- (void)setBandwidth:(NSInteger)bandwidth {
    if (self.selectedTrackBitrate == bandwidth) {
        return;
    }
    
    SLOGI(@"[API][SET_BANDWIDTH][%@], %d->%ld", self, self.selectedTrackBitrate, (long)bandwidth);
    // 如果当前尚未prepare，直接设置trackBitrate，并在prepare前设置setDefaultBandWidth接口来实现指定清晰度
    if (!self.hasPrepared || !self.aliPlayer) {
        self.selectedTrackBitrate = (int)bandwidth;
        return;
    }
    
    // 如果当前已经prepare，直接通过selectTrack切换清晰度
    NSArray<AVPTrackInfo*>* trackInfoList = [self getVideoTracks];
    for (AVPTrackInfo* trackInfo in trackInfoList) {
        if (trackInfo != nil && trackInfo.trackBitrate == bandwidth) {
            [self selectTrack:trackInfo];
            break;
        }
    }
}

// 获取视频轨
- (NSArray<AVPTrackInfo *> *)getVideoTracks {
    if (!self.aliPlayer) {
        return nil;
    }
    
    AVPMediaInfo *mediaInfo = [self.aliPlayer getMediaInfo];
    if (!mediaInfo || !mediaInfo.tracks) {
        return nil;
    }
    
    NSArray<AVPTrackInfo *> *videoTracks = [AUIVideoTrackInfoUtil filterVideoTrackInfoList:mediaInfo.tracks];
    return [videoTracks copy];
}

#pragma mark - AVPDelegate

// 播放错误发生时的回调
- (void)onError:(AliPlayer *)player errorModel:(AVPErrorModel *)errorModel {
    SLOGE(@"[player][CBK][ERROR][%ld], %@, %@", errorModel.code, errorModel.message, player);
    if (self.delegate && [self.delegate respondsToSelector:@selector(onError:errorInfo:)]) {
        [self.delegate onError:self errorInfo:errorModel];
    }
}

// 播放器事件回调
- (void)onPlayerEvent:(AliPlayer *)player eventType:(AVPEventType)eventType {
    switch (eventType) {
        case AVPEventPrepareDone: {
            SLOGI(@"[player][CBK][PlayerEvent][PrepareDone], %@", player);
                        
            if (self.delegate && [self.delegate respondsToSelector:@selector(onPrepared:)]) {
                [self.delegate onPrepared:self];
            }
            
            [player setRate:1.0]; // 设置默认播放速度
            
            break;
        }
        case AVPEventFirstRenderedStart: {
            SLOGI(@"[player][CBK][PlayerEvent][FirstRenderedStart], %@", player);
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(onRenderingStart:duration:)]) {
                self.playDuration = player.duration; // 更新视频播放时长
                [self.delegate onRenderingStart:self duration:self.playDuration];
            }
            
            break;
        }
        case AVPEventCompletion: {
            SLOGI(@"[player][CBK][PlayerEvent][Completion], %@", player);
            self.hasPrepared = NO;
            self.prepareStartTime = 0;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(onCompletion:)]) {
                [self.delegate onCompletion:self];
            }
            
            break;
        }
            
        
            
        default: {
            SLOGI(@"[player][CBK][PlayerEvent][%lu], %@", (unsigned long)eventType, player);
            break;
        }
    }
}

// 播放状态改变时的回调
- (void)onPlayerStatusChanged:(AliPlayer *)player oldStatus:(AVPStatus)oldStatus newStatus:(AVPStatus)newStatus {
//    SLOGI(@"[player][CBK][StatusChanged][%lu->%lu], %@", (unsigned long)oldStatus, (unsigned long)newStatus, player);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPlayStatusChanged:oldStatus:newStatus:)]) {
        [self.delegate onPlayStatusChanged:self oldStatus:oldStatus newStatus:newStatus];
    }
    
    self.playerStatus = newStatus; // 更新播放器状态
}

// 播放位置更新时的回调
- (void)onCurrentPositionUpdate:(AliPlayer *)player position:(int64_t)position {
    // 可以在此处处理播放位置更新
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPlayPositionUpdate:position:duration:)]) {
        [self.delegate onPlayPositionUpdate:self position:position duration:self.playDuration];
    }
}

// 视频缓存位置回调
- (void)onBufferedPositionUpdate:(AliPlayer*)player position:(int64_t)position {
    // 可以在此处处理缓存位置更新
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPlayBufferedPositionUpdate:position:duration:)]) {
        [self.delegate onPlayBufferedPositionUpdate:self position:position duration:self.playDuration];
    }
}

// 音轨切换完成时的回调
- (void)onTrackChanged:(AliPlayer *)player info:(AVPTrackInfo *)info {
    // 可以在此处处理音轨切换完成
    if (info && info.trackType == AVPTRACK_TYPE_VIDEO) {
        SLOGI(@"[player][CBK][TrackChanged][%@]", [AUIVideoTrackInfoUtil getQuality:info]);
        if (self.delegate && [self.delegate respondsToSelector:@selector(onTrackSuccess:trackInfo:)]) {
            [self.delegate onTrackSuccess:self trackInfo:info];
        }
    }
}

#pragma mark - CicadaRenderingDelegate

/// 在渲染帧回调中把当前帧交给外部代理进行画中画(PiP)渲染。
///
/// @param frameInfo 帧信息对象，包含视频像素缓冲区等数据
/// @return 代理成功处理返回 YES，否则返回 NO。
- (BOOL)onRenderingFrame:(CicadaFrameInfo *)frameInfo {
    if (frameInfo == nil) {
        return NO;
    }
    
    CVPixelBufferRef pixelBuffer = frameInfo.video_pixelBuffer;
    if (pixelBuffer == nil) {
        return NO;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPiPRenderPixelBuffer:fromVideoView:)]) {
        BOOL handled = [self.delegate onPiPRenderPixelBuffer:frameInfo.video_pixelBuffer fromVideoView:self];
        return handled;
    }
    
    return NO;
}

@end
