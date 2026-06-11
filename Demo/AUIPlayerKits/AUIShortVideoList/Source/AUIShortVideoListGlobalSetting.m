//
//  AUIShortVideoListGlobalSetting.m
//  AUIShortVideoList
//
//

#import "AUIShortVideoListGlobalSetting.h"
#import "AUIShortVideoListUtils.h"
#import <SDWebImage/SDWebImage.h>

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

/**
 * @brief 业务标识
 * @note SDK增加了 SET_EXTRA_DATA 作为业务标识。SDK版本区间：> 6.11.0
 */
static NSString *const kExtraDataShortVideoList = @"{\"scene\":\"aui-episode\",\"platform\":\"ios\",\"style\":\"function-list\"}";

/**
 * @brief 本地缓存功能开关
 * @note 开启本地缓存
 */
static BOOL const kEnableLocalCacheFlag = YES;

/**
 * @brief 单个源的最大内存占用大小
 * @note 5.4.7.1及以后版本已废弃，暂无作用
 */
static NSInteger const kLocalCacheMaxBufferMemoryKb = 10 * 1024;

/**
 * @brief 本地缓存过期时间
 * @note 单位：分钟
 * @note 5.4.7.1及以后版本已废弃，暂无作用
 */
static NSInteger const kLocalCacheExpireMin = 30 * 24 * 60;

/**
 * @brief 最大缓存容量
 * @note 单位：MB，默认值 20 GB
 * @note 在清理时，如果缓存总容量超过此大小，则会以 cacheItem 为粒度，按缓存的最后时间排序，一个一个的删除最旧的缓存文件，直到小于等于最大缓存容量。
 */
static NSInteger const kLocalCacheMaxCapacityMB = 20 * 1024;

/**
 * @brief 磁盘最小空余容量
 * @note 单位：MB，默认值 0
 * @note 在清理时，同最大缓存容量，如果当前磁盘容量小于该值，也会按规则一个一个的删除缓存文件，直到freeStorage大于等于该值或者所有缓存都被清理掉。
 */
static NSInteger const kLocalCacheFreeStorageMB = 0;

/**
 * @brief 设置 SDWebImage 最大内存缓存
 * @note 单位：Byte
 */
static NSInteger const kSDImageCacheMaxMemoryCost = 50 * 1024 * 1024;

/**
 * @brief 设置 SDWebImage 最大磁盘缓存
 * @note 单位：Byte
 */
static NSInteger const kSDImageCacheMaxDiskSize = 200 * 1024 * 1024;


@interface AUIShortVideoListGlobalSetting()

/**
 * @brief 配置全局缓存设置的额外数据
 * @details 该方法主要用于初始化和设置播放器相关的全局参数。
 *          这些数据用于标识业务场景并帮助播放器结合具体业务逻辑进行处理。
 */
+ (void)setupExtraData;

/**
 * @brief 设置 MediaLoader 的本地缓存配置
 * @details 该方法设置 MediaLoader 的缓存，包括本地缓存路径的创建和缓存清理的相关策略。
 *          它确保在指定路径上的缓存目录存在，并为缓存策略提供最大容量和清理规则。
 * @note 需要确保目录是可写的，并且应用具备必要的存储权限。
 */
+ (void)setupMediaLoaderConfig;

/**
 * @brief 配置 SDWebImage 的图片缓存设置
 * @details 通过设置 SDWebImage 的内存和磁盘缓存最大值，优化图片的加载性能。
 *          并自定义磁盘缓存路径以确保图片缓存能按照预期进行存储和管理。
 * @note 如有必要，可以通过调整缓存大小和时间设置来优化应用性能。
 */
+ (void)setupSDWebImageConfig;

@end


@implementation AUIShortVideoListGlobalSetting

#pragma mark - Setup Methods

// 设置全局配置
+ (void)setupConfig {
    // 使用 dispatch_once 保证这些配置只被执行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 设置业务标识
        [AUIShortVideoListGlobalSetting setupExtraData];
        
        // 设置 MediaLoader 本地缓存
        [AUIShortVideoListGlobalSetting setupMediaLoaderConfig];
        
        // 配置 SDWebImage 的图片缓存设置
        [AUIShortVideoListGlobalSetting setupSDWebImageConfig];
    });
}

// 设置业务标识
+ (void)setupExtraData {
    [AliPlayerGlobalSettings setOption:SET_EXTRA_DATA value:kExtraDataShortVideoList];
}

// 设置 MediaLoader 本地缓存，包括缓存路径和缓存清理配置
+ (void)setupMediaLoaderConfig {
    // 获取文档目录路径
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *mediaCacheDir = [docDir stringByAppendingPathComponent:@"alipreload/media"];
    
    // 确保缓存目录存在
    [AUIShortVideoListUtils ensureDirectoryExistsAtPath:mediaCacheDir error:nil];
    
    // 启用本地缓存并配置缓存参数
    [AliPlayerGlobalSettings enableLocalCache:kEnableLocalCacheFlag
                            maxBufferMemoryKB:kLocalCacheMaxBufferMemoryKb
                                localCacheDir:mediaCacheDir];
    
    // 配置本地缓存文件的清理策略
    [AliPlayerGlobalSettings setCacheFileClearConfig:kLocalCacheExpireMin
                                       maxCapacityMB:kLocalCacheMaxCapacityMB
                                       freeStorageMB:kLocalCacheFreeStorageMB];
}

// 配置 SDWebImage 的图片缓存设置
+ (void)setupSDWebImageConfig {
    // 获取共享的缓存实例
    // NOTE: @keria, 获取 SDImageCache 实例较为耗时，大约7ms；影响面：第一次进入沉浸式列表播放页面
    SDImageCache *cache = [SDImageCache sharedImageCache];
    
    // 配置最大缓存大小（内存和磁盘）
    cache.config.maxMemoryCost = kSDImageCacheMaxMemoryCost;
    cache.config.maxDiskSize = kSDImageCacheMaxDiskSize;
    
    // NOTE: @keria, 不同 SDWebImage 版本，设置缓存路径的方法不一样，为确保集成兼容性，我们不额外设置缓存目录。
//    // 自定义磁盘缓存路径
//    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//    NSString *imageCacheDir = [docDir stringByAppendingPathComponent:@"alipreload/image"];
//    
//    // 确保缓存目录存在
//    [AUIShortVideoListUtils ensureDirectoryExistsAtPath:imageCacheDir error:nil];
    
    // 配置保留时间（以秒为单位）
    cache.config.maxDiskAge = 60 * kLocalCacheExpireMin;  // 设置磁盘缓存
    
    // 可选择地禁用内存缓存
    // cache.config.shouldCacheImagesInMemory = NO;
}

#pragma mark - Clear Methods

// 清理所有缓存
+ (void)clearCaches {
    // 清除本地缓存
    [AliPlayerGlobalSettings clearCaches];
    
    // 清除 SDWebImage 磁盘缓存
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    // 清除 SDWebImage 内存缓存
    [[SDImageCache sharedImageCache] clearMemory];
    
}

@end
