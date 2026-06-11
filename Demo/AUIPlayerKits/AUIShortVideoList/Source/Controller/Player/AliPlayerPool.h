//
//  AliPlayerPool.h
//  AUIShortVideoList
//
//  Created by keria on 2024/10/16.
//

#import <Foundation/Foundation.h>

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

NS_ASSUME_NONNULL_BEGIN

/**
 * @class AliPlayerPool
 *
 * @brief 该类为管理视频播放器实例的池类，用于有效复用播放器资源，降低创建和销毁播放器时的资源开销。
 */
@interface AliPlayerPool : NSObject

#pragma mark - SingleInstance

/**
 * @brief 获取播放器池的共享实例
 * @return 返回播放器池的单例实例；如果创建失败，则返回 nil。
 */
+ (instancetype)sharedInstance;

#pragma mark - LifeCycle

/**
 * @brief 初始化播放器池
 * @note 在使用播放器池之前，必须调用此方法进行初始化设置。
 */
- (void)setup;

/**
 * @brief 销毁播放器池
 * @note 调用此方法以释放播放器池占用的所有资源，防止出现内存泄漏。
 */
- (void)destroy;

#pragma mark - Control

/**
 * @brief 从播放器池中获取播放器实例
 * @param key 唯一标识所需播放器实例的键
 * @return 返回与指定键对应的播放器实例；如果未找到，则返回 nil。
 */
- (AliPlayer *)acquire:(id<NSCopying>)key;

/**
 * @brief 将播放器池中的播放器实例主动回收
 * @param key 唯一标识所需播放器实例的键
 * @note 释放不再使用的播放器实例，以便后续使用。
 */
- (void)recycle:(id<NSCopying>)key;

@end

NS_ASSUME_NONNULL_END
