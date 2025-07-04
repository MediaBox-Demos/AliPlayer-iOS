//
//  PreloadViewController.m
//  Preload
//
//  Created by 叶俊辉 on 2025/6/19.
//

#import "PreloadViewController.h"
#import "AliyunPlayer/AVPDelegate.h"
#import <AliyunPlayer/AliMediaLoader.h>
#import <Common/Common.h>
#import <Common/ToastUtils.h>

// 预加载缓冲时长（毫秒）
static const NSInteger kPreloadBufferDuration = 3 * 1000;

@interface PreloadViewController () <AVPDelegate, AliMediaLoaderStatusDelegate>

#pragma mark - 播放器相关属性
// 播放器实例
@property (nonatomic, strong) AliPlayer *player;
// 播放器视图容器
@property (nonatomic, strong) UIView *playerView;

#pragma mark - 预加载相关属性
// 预加载实例
@property (nonatomic, strong) AliMediaLoader *mediaLoader;

@end

@implementation PreloadViewController

#pragma mark - 生命周期方法

- (void)viewDidLoad {
    [super viewDidLoad];

    // 设置页面基本属性
    self.title = AppGetString(@"preload.title");
    self.view.backgroundColor = [UIColor blackColor];

    // Step 1: 设置本地缓存
    [self setupLocalCache];

    // Step 2: 预加载设置
    [self setPreloadParameter:kSampleVideoPreloadURL preloadTime:kPreloadBufferDuration];
}

- (void)dealloc {
    // Step 4: 取消预加载
    [self cancelMediaLoader:kSampleVideoPreloadURL];

    NSLog(@"[dealloc] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - Step 1: 本地缓存设置

/**
 * Step 1: 设置本地缓存
 */
- (void)setupLocalCache {
    // 1.1 开启本地缓存(使用默认缓存路径)
    [AliPlayerGlobalSettings enableLocalCache:true];

    /**
     * 也可以使用下方代码进行缓存设置
     * 开启本地缓存，开启之后，就会缓存到本地文件中。
     * @param enable：本地缓存功能开关。true：开启，false：关闭，默认关闭。
     * @param maxBufferMemoryKB：5.4.7.1及以后版本已废弃，暂无作用。
     * @param localCacheDir：必须设置，本地缓存的文件目录，为绝对路径。
     * [AliPlayerGlobalSettings enableLocalCache:true maxBufferMemoryKB:1024 localCacheDir:@""];
     */
    // 参考文档: https://help.aliyun.com/zh/vod/developer-reference/advanced-features-1

    NSLog(@"[Step 1.1] 本地缓存已开启");

    // 1.2 创建 MediaLoader 实例
    self.mediaLoader = [AliMediaLoader shareInstance];

    // 1.3 设置预加载状态回调
    [self.mediaLoader setAliMediaLoaderStatusDelegate:self];

    NSLog(@"[Step 1] 本地缓存设置完成");
}

#pragma mark - Step 1.3: 预加载状态回调处理

/**
 * @brief 预加载完成回调
 * @param url 加载url
 */
- (void)onCompleted:(NSString *)url {
    [ToastUtils showToastWithMessage:AppGetString(@"preload_complete") inView:self.view];

    NSLog(@"[Step 1.3] 预加载完成: %@", url);
}

/**
 * @brief 预加载错误回调
 * @param url 加载url
 * @param code 错误码
 * @param msg 错误描述
 */
- (void)onErrorV2:(NSString *)url code:(int64_t)code msg:(NSString *)msg {
    [ToastUtils showToastWithMessage:AppGetString(@"preload_error") inView:self.view];

    NSLog(@"[Step 1.3] 预加载出错: %@ errorInfo: %@", url, msg);
}

/**
 * @brief 预加载取消回调
 * @param url 加载url
 */
- (void)onCanceled:(NSString *)url {
    [ToastUtils showToastWithMessage:AppGetString(@"preload_canceled") inView:self.view];

    NSLog(@"[Step 1.3] 预加载取消: %@", url);
}

#pragma mark - Step 2: 预加载设置
// Step 7: 开始预加载
- (void)setPreloadParameter:(NSString *)preloadUrl preloadTime:(int64_t)preloadTime {
    [self.mediaLoader load:preloadUrl duration:preloadTime];

    NSLog(@"[Step 2] 启动预加载");
}

#pragma mark - Step 3: 开始播放
/**
 * Step 3: 开始播放
 * 本模块未实现播放功能，只展示预加载能力，您可在此位置自行实现
 * 设置预加载可提升视频起播速度
 */

#pragma mark - Step 4: 取消预加载

/**
 * Step 4: 取消预加载
 */
- (void)cancelMediaLoader:(NSString *)preloadUrl {
    if (self.mediaLoader) {
        [self.mediaLoader cancel:preloadUrl];
        NSLog(@"[Step 4] 取消预加载");
    }
}

@end
