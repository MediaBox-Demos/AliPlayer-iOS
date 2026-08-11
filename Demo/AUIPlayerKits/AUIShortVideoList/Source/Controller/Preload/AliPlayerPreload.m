//
//  AliPlayerPreload.m
//  AUIShortVideoList
//
//  Created by keria on 2024/10/16.
//

#import "AliPlayerPreload.h"
#import "AUIShortVideoListConstants.h"
#import "AUIShortVideoListUtils.h"
#import "AliSlidingWindow.h"
#import <SDWebImage/SDWebImage.h>

// TODO:  PreloadV2 头文件后续会增加至AliyunPlayer.h，应该不需要引入，后续正式版本删除

#if __has_include(<AliVCSDK_Standard/AliVCSDK_Standard.h>)
#import <AliVCSDK_Standard/AVPPreloadConfig.h>
#import <AliVCSDK_Standard/AVPPreloadTask.h>
#import <AliVCSDK_Standard/AliMediaLoaderV2.h>
#import <AliVCSDK_Standard/AliVCSDK_Standard.h>

#elif __has_include(<AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>)
#import <AliVCSDK_InteractiveLive/AVPPreloadConfig.h>
#import <AliVCSDK_InteractiveLive/AVPPreloadTask.h>
#import <AliVCSDK_InteractiveLive/AliMediaLoaderV2.h>
#import <AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>

#elif __has_include(<AliVCSDK_BasicLive/AliVCSDK_BasicLive.h>)
#import <AliVCSDK_BasicLive/AVPPreloadConfig.h>
#import <AliVCSDK_BasicLive/AVPPreloadTask.h>
#import <AliVCSDK_BasicLive/AliMediaLoaderV2.h>
#import <AliVCSDK_BasicLive/AliVCSDK_BasicLive.h>

#elif __has_include(<AliVCSDK_UGC/AliVCSDK_UGC.h>)
#import <AliVCSDK_UGC/AVPPreloadConfig.h>
#import <AliVCSDK_UGC/AVPPreloadTask.h>
#import <AliVCSDK_UGC/AliMediaLoaderV2.h>
#import <AliVCSDK_UGC/AliVCSDK_UGC.h>

#endif

#if __has_include(<AliyunPlayer/AliyunPlayer.h>)
#import <AliyunPlayer/AVPPreloadConfig.h>
#import <AliyunPlayer/AVPPreloadTask.h>
#import <AliyunPlayer/AliMediaLoaderV2.h>
#import <AliyunPlayer/AliyunPlayer.h>
#endif

// if current item index is n, preload n-3 to n+10 cover
// 左侧预加载窗口大小，表示如果当前项索引为 n，则预加载 n-3 到 n 的封面资源
static const NSInteger kCoverPreloadLeftWindowSize = 3;
// 右侧预加载窗口大小，表示如果当前项索引为 n，则预加载 n 到 n+10 的封面资源
static const NSInteger kCoverPreloadRightWindowSize = 10;

// 预加载缓冲时长（毫秒）
static const NSInteger kPreloadBufferDuration = 3 * 1000;

// 预加载窗口的值数组
static const int kMediaPreloadWindows[] = {-1, 1, 2};

// 预加载异步队列名称
static NSString *const kPreloadAsyncQueueName = @"com.alivc.playerpreload.queue";
// 预加载方法锁名称
static NSString *const kPreloadMethodLockName = @"com.alivc.playerpreload.lock";

@interface AliPlayerPreload () <AliSlidingWindowDelegate, OnPreloadListener>

// 视频预加载器
@property(nonatomic, strong) AliSlidingWindow *videoPreloader;
// 封面图预加载器
@property(nonatomic, strong) AliSlidingWindow *coverPreloader;

// 播放器预加载实例
@property(nonatomic, strong) AliMediaLoader *mediaLoader;

@property(nonatomic, strong) AliMediaLoaderV2 *mediaLoaderV2;
// 方法调用锁，用于保证线程安全
@property(nonatomic, strong) NSLock *callMethodLock;

// 串行执行队列，TODO：将来可以替换成 NSOperationQueue
@property(nonatomic, strong) dispatch_queue_t preloadAsyncQueue;

// 当前设置的带宽值
@property(nonatomic, assign) NSInteger currentBandwidth;

@property(nonatomic, strong) NSString *taskid;

@end

@implementation AliPlayerPreload

#pragma mark - LifeCycle

// 初始化方法
- (instancetype)init {
    self = [super init];
    if (self) {
        // 计算媒体预加载窗口的长度
        NSUInteger mediaPreloadLength =
            sizeof(kMediaPreloadWindows) / sizeof(kMediaPreloadWindows[0]);
        // 将媒体预加载窗口数组转换为 NSArray
        NSArray<NSNumber *> *mediaPreloadArray =
            [AUIShortVideoListUtils convertToNSArray:kMediaPreloadWindows
                                          withLength:mediaPreloadLength];
        // 初始化视频预加载器
        _videoPreloader =
            [[AliSlidingWindow alloc] initWithItems:mediaPreloadArray
                                      eventObserver:self
                                          extraType:ExtraTypeMedia];

        // 如果未开启封面 URL 策略，封面图预加载器将不生效
        if (AUIShortVideoListConstants.enableCoverURLStrategy) {
            // 初始化封面图预加载器
            _coverPreloader = [[AliSlidingWindow alloc]
                initWithLeftWindowSize:kCoverPreloadLeftWindowSize
                       rightWindowSize:kCoverPreloadRightWindowSize
                         eventObserver:self
                             extraType:ExtraTypeCover];
        }

        // 初始化方法锁
        _callMethodLock = [[NSLock alloc] init];
        // 设置锁名称
        _callMethodLock.name = kPreloadMethodLockName;

        // 创建串行执行队列
        _preloadAsyncQueue = dispatch_queue_create(
            [kPreloadAsyncQueueName UTF8String], DISPATCH_QUEUE_SERIAL);

        NSLog(@"[init] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
    }
    return self;
}

// 释放资源的方法
- (void)dealloc {
    [self destroy];

    NSLog(@"[dealloc] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
}

// 设置方法，初始化播放器预加载实例
- (void)setup {
    SLOGI(@"[API][---SETUP---]");
    // 调用初始化播放器预加载实例
    [self initMediaLoaderV2];
}

// 销毁方法，释放播放器预加载实例
- (void)destroy {
    SLOGI(@"[API][---DESTROY---]");
    // 销毁预加载器
    [self destroyPreloaders];

    // 调用销毁播放器预加载实例
    [self destroyMediaLoader];
}

// 销毁视频预加载器
- (void)destroyPreloaders {
    if (_videoPreloader) {
        [_videoPreloader destroy];
        _videoPreloader = nil;
    }
    if (_coverPreloader) {
        [_coverPreloader destroy];
        _coverPreloader = nil;
    }
}

// 初始化播放器预加载实例
- (void)initMediaLoaderV2 {
    self.mediaLoaderV2 = [AliMediaLoaderV2 shareInstance];
}

// 释放播放器预加载实例
- (void)destroyMediaLoader {
    [self.callMethodLock lock];
    @try {
        if (self.mediaLoaderV2) {
            SLOGI(@"[mediaLoader][API][destroy], %@ -> nil",
                  self.mediaLoaderV2);
            self.mediaLoaderV2 = nil;
        }
    } @finally {
        [self.callMethodLock unlock];
    }
}

#pragma mark - DataSource

// 设置视频数据源（替换）
- (void)setItems:(NSArray<AUIShortVideoInfo *> *)items {
    SLOGI(@"[API][SET]: [%ld]", items.count);
    [self updateItems:items overwrite:YES];
}

// 设置视频数据源（附加）
- (void)addItems:(NSArray<AUIShortVideoInfo *> *)items {
    SLOGI(@"[API][ADD]: [%ld]", items.count);
    [self updateItems:items overwrite:NO];
}

// 更新视频数据源
- (void)updateItems:(NSArray<AUIShortVideoInfo *> *)items
          overwrite:(BOOL)overwrite {
    if (!_videoPreloader) {
        SLOGE(@"update items failed! video preloader nil");
        return;
    }

    // 存放有效的视频 URL
    NSMutableArray<AVPVidAuthSource *> *authSources = [NSMutableArray array];
    NSMutableArray<NSString *> *coverUrls = [NSMutableArray array];
    for (AUIShortVideoInfo *item in items) {
        if (item && item.videoId && item.playAuth) {
            AVPVidAuthSource *vidAuth = [[AVPVidAuthSource alloc] init];
            [vidAuth setVid:item.videoId];
            [vidAuth setPlayAuth:item.playAuth];

            [authSources addObject:vidAuth];
            if (item.coverUrl) {
                [coverUrls addObject:item.coverUrl];
            }
        }
    }

    NSArray<AVPVidAuthSource *> *videoUrlsArray =
        [NSArray arrayWithArray:authSources];
    NSArray<NSString *> *coverUrlsArray = [NSArray arrayWithArray:coverUrls];
    if (overwrite) {
        // 替换旧的视频项
        [self.videoPreloader setItems:videoUrlsArray];
        [self.coverPreloader setItems:coverUrlsArray];
    } else {
        // 追加新的视频项
        [self.videoPreloader addItems:videoUrlsArray];
        [self.coverPreloader addItems:coverUrlsArray];
    }
}

#pragma mark - Control

// 移动浮标到指定位置
- (void)moveTo:(NSInteger)position {
    SLOGI(@"[API][MOVETO][%ld]", position);
    if (_videoPreloader) {
        [_videoPreloader moveTo:position];
    }
    if (_coverPreloader) {
        [_coverPreloader moveTo:position];
    }
}

// 设置带宽值
- (void)setBandwidth:(NSInteger)bandwidth {
    [self.callMethodLock lock];
    @try {
        // 检查是否重复设置
        if (self.currentBandwidth == bandwidth) {
            SLOGI(@"[API][SET_BANDWIDTH][DUPLICATE]: Bandwidth value "
                  @"unchanged, no action needed.");
            return;
        }

        if (bandwidth <= 0) {
            // 如果带宽为 0 或负数，重置为默认状态
            self.currentBandwidth = 0;
            SLOGI(@"[API][SET_BANDWIDTH][RESET]: Reset to default state");
        } else {
            // 设置新的带宽值
            self.currentBandwidth = bandwidth;
            SLOGI(@"[API][SET_BANDWIDTH][SET]: %@", @(self.currentBandwidth));
        }

        // 刷新预加载器逻辑
        [self refreshPreloaders];
    } @finally {
        [self.callMethodLock unlock];
    }
}

// 获取当前设置的带宽值
- (NSInteger)getBandwidth {
    return self.currentBandwidth;
}

// 刷新预加载器逻辑
- (void)refreshPreloaders {
    if (self.videoPreloader) {
        [self.videoPreloader refresh];
    }
}

#pragma mark - AliSlidingWindowDelegate

// 执行加载指定项
- (void)execute:(id)item from:(id)slidingWindow {
    SLOGI(@"[EXECUTE][%@]", item);
    if (slidingWindow == self.videoPreloader) {
        if ([item isKindOfClass:[AVPVidAuthSource class]]) {
            AVPVidAuthSource *source = (AVPVidAuthSource *)item;
            // 预加载指定视频源
            [self preloadMedia:source];
        }
    } else if (slidingWindow == self.coverPreloader) {
        if ([item isKindOfClass:[NSString class]]) {
            NSString *cover = (NSString *)item;
            // 预加载指定封面图
            [self preloadImage:cover];
        }
    }
}

// 取消加载指定项
- (void)cancel:(id)item from:(id)slidingWindow {
    SLOGI(@"[CANCEL][%@]", item);
    if (slidingWindow == self.videoPreloader) {
        if ([item isKindOfClass:[AVPVidAuthSource class]]) {
            AVPVidAuthSource *souce = (AVPVidAuthSource *)item;
            // 取消加载指定视频源
            [self cancelPreloadMedia:souce];
        }
    }
}

// 检查项是否有效
- (BOOL)isValid:(AUIShortVideoInfo *)item from:(id)slidingWindow {
    // 检查 URL 是否有效
    return item;
}

#pragma mark - mediaPreload

// 预加载视频
- (void)preloadMedia:(AVPVidAuthSource *)vidAuthSource {
    // 确保异步队列存在
    NSAssert(_preloadAsyncQueue, @"Executor queue is nil");

    dispatch_async(_preloadAsyncQueue, ^{
        SLOGI(@"[mediaLoaderV2][API][load]: %@, bandwidth=%ld", vidAuthSource.vid, self.currentBandwidth);

      @try {
          [self.callMethodLock lock];
          if (self.currentBandwidth > 0) {

              // 如果设置了带宽值，同步传入带宽参数
              AVPPreloadConfig *preloadConfig =
                  [[AVPPreloadConfig alloc] initWithDuration:kPreloadBufferDuration];
              [preloadConfig setDefaultBandWidth:(int)self.currentBandwidth];
              AVPPreloadTask *task =
                  [[AVPPreloadTask alloc] initWithVidAuthSource:vidAuthSource
                                                  preloadConfig:preloadConfig];
              self.taskid = [self.mediaLoaderV2 addTask:task listener:self];

          } else {
              AVPPreloadConfig *preloadConfig =
                  [[AVPPreloadConfig alloc] initWithDuration:kPreloadBufferDuration];
              AVPPreloadTask *task =
                  [[AVPPreloadTask alloc] initWithVidAuthSource:vidAuthSource
                                                  preloadConfig:preloadConfig];
              self.taskid = [self.mediaLoaderV2 addTask:task listener:self];
          }
      } @finally {
          [self.callMethodLock unlock];
      }
    });
}

// 取消预加载视频
- (void)cancelPreloadMedia:(AVPVidAuthSource *)vidAuthSource {
    // 确保异步队列存在
    NSAssert(_preloadAsyncQueue, @"Executor queue is nil");

    dispatch_async(_preloadAsyncQueue, ^{
      SLOGI(@"[mediaLoaderV2][API][cancel]: %@", vidAuthSource);
      @try {
          [self.callMethodLock lock];
          [self.mediaLoaderV2 cancelTask:self.taskid];
      } @finally {
          [self.callMethodLock unlock];
      }
    });
}

#pragma mark - imagePreload

- (void)preloadImage:(NSString *)imageUrl {
    // 确保异步队列存在
    NSAssert(_preloadAsyncQueue, @"Executor queue is nil");

    dispatch_async(_preloadAsyncQueue, ^{
      if (![AUIShortVideoListUtils isValidURLString:imageUrl]) {
          SLOGE(@"preload image failed! imageUrl is nil");
          return;
      }

      SLOGI(@"[SDWebImage][API][load]: %@", imageUrl);

      NSURL *imageURL = [NSURL URLWithString:imageUrl];
      [[SDWebImageManager sharedManager]
          loadImageWithURL:imageURL
                   options:SDWebImageRefreshCached
                  progress:nil
                 completed:^(UIImage *_Nullable image, NSData *_Nullable data,
                             NSError *_Nullable error,
                             SDImageCacheType cacheType, BOOL finished,
                             NSURL *_Nullable imageURL) {
                   if (image) {
                       [[SDImageCache sharedImageCache]
                           storeImage:image
                               forKey:imageURL.absoluteString
                           completion:nil];
                       SLOGI(@"[SDWebImage][CBK][COMPLETED]: %@", imageUrl);
                   } else if (error) {
                       SLOGI(@"[SDWebImage][CBK][CANCELED]: %@, %@", error,
                             imageUrl);
                   }
                 }];
    });
}


#pragma mark - OnPreloadListener

- (void)onError:(NSString *)taskId
       urlOrVid:(NSString *)urlOrVid
     errorModel:(AVPErrorModel *)errorModel {
    if (errorModel != nil) {
        SLOGE(@"[mediaLoaderV2][CBK][ERROR]: [%ld][%@], %@",
              (long)errorModel.code, errorModel.message, urlOrVid);
    } else {
        SLOGE(@"[mediaLoaderV2][CBK][ERROR]: Error model is nil for URL: %@",
              urlOrVid);
    }
}

- (void)onCompleted:(NSString *)taskId urlOrVid:(NSString *)urlOrVid {
    SLOGW(@"[mediaLoaderV2][CBK][COMPLETED]: %@", urlOrVid);
}

- (void)onCanceled:(NSString *)taskId urlOrVid:(NSString *)urlOrVid {
    SLOGI(@"[mediaLoaderV2][CBK][CANCELED]: %@", urlOrVid);
}

@end
