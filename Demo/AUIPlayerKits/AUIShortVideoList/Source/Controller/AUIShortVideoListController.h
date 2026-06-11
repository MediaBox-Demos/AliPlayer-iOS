//
//  AUIShortVideoListController.h
//  AUIPlayer
//
//  Created by keria on 2024/11/13.
//

#import <Foundation/Foundation.h>
#import "AUIShortVideoInfo.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @class AUIShortVideoListController
 * @brief 管理短视频播放列表的控制器类
 *
 * @discussion 该类负责短视频播放列表的管理，比如初始化、销毁、资源加载、预加载和位置移动等功能。
 */
@interface AUIShortVideoListController : NSObject

/**
 * @brief 初始化播放器及其资源
 *
 * @discussion 调用此方法以完成播放器及预加载器的初始化操作。
 */
- (void)setup;

/**
 * @brief 销毁并清理播放器相关资源
 *
 * @discussion 在需要销毁播放器资源时调用此方法，以释放内存和其他资源。
 */
- (void)destroy;

/**
 * @brief 跳转到指定播放位置
 *
 * @param position 目标播放位置的索引
 *
 * @discussion 该方法控制播放器跳转到指定的索引位置。
 */
- (void)moveTo:(NSInteger)position;

/**
 * @brief 设置带宽值。
 *
 * @param bandwidth 带宽值。如果为 0 或负数，则重置为默认状态。
 */
- (void)setBandwidth:(NSInteger)bandwidth;

/**
 * @brief 设置替换新的视频资源列表
 *
 * @param videoInfoList 包含视频信息的列表
 *
 * @discussion 该方法用于替换现有的视频资源列表，加载新的视频源。
 */
- (void)loadSources:(NSArray<AUIShortVideoInfo *> *)videoInfoList;

/**
 * @brief 添加更多视频资源到现有列表中
 *
 * @param videoInfoList 要添加的视频信息列表
 *
 * @discussion 通过此方法可以向现有资源列表中追加更多的视频源。
 */
- (void)addSources:(NSArray<AUIShortVideoInfo *> *)videoInfoList;

@end

NS_ASSUME_NONNULL_END
