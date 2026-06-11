//
//  AliPlayerPreload.h
//  AUIShortVideoList
//
//  Created by keria on 2024/10/16.
//

#import <Foundation/Foundation.h>
#import "AUIShortVideoInfo.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @class AliPlayerPreload
 *
 * @brief 该类负责管理视频的预加载功能，处理数据源的设置和控制视频播放的预加载行为。
 */
@interface AliPlayerPreload : NSObject

#pragma mark - LifeCycle

/**
 * @brief 初始化播放器预加载实例。
 *
 * @discussion 该方法用于在使用该类之前进行必要的设置。
 */
- (void)setup;

/**
 * @brief 清理播放器预加载实例。
 *
 * @discussion 该方法用于释放资源，确保正确关闭和清理播放器预加载时使用的资源。
 */
- (void)destroy;

#pragma mark - DataSource

/**
 * @brief 设置视频数据源。
 *
 * @param items 要设置的视频信息数组，数组中的对象类型为 AUIShortVideoInfo。
 *
 * @discussion 该方法会替换当前的数据源。
 */
- (void)setItems:(NSArray<AUIShortVideoInfo *> *)items;

/**
 * @brief 添加视频数据源。
 *
 * @param items 要添加的视频信息数组，数组中的对象类型为 AUIShortVideoInfo。
 *
 * @discussion 该方法会将视频信息附加到当前的数据源。
 */
- (void)addItems:(NSArray<AUIShortVideoInfo *> *)items;

#pragma mark - Control

/**
 * @brief 移动浮标到指定位置。
 *
 * @param position 要移动到的目标位置的索引。
 *
 * @discussion 该方法控制播放器的播放位置，移动到指定的索引位置。
 */
- (void)moveTo:(NSInteger)position;

/**
 * @brief 设置带宽值。
 *
 * @param bandwidth 带宽值。如果为 0 或负数，则重置为默认状态。
 */
- (void)setBandwidth:(NSInteger)bandwidth;

/**
 * @brief 获取当前设置的带宽值。
 *
 * @return 当前的带宽值。如果未设置或已重置，则返回 0。
 */
- (NSInteger)getBandwidth;

@end

NS_ASSUME_NONNULL_END
