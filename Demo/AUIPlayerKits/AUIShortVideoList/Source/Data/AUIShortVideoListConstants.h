//
//  AUIShortVideoListConstants.h
//  AUIPlayer
//
//  Created by keria on 2024/11/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class AUIShortVideoListConstants
 *
 * @brief 该类包含与短视频列表功能相关的常量值和配置设置，包括默认视频信息列表的 URL、播放器池的容量，以及是否启用封面 URL 策略。
 */
@interface AUIShortVideoListConstants : NSObject

#pragma mark - VideoInfoListURL

/**
 * @brief 默认视频信息列表的 URL - 网络视频源（默认）
 */
@property (class, nonatomic, readonly) NSString *defaultVideoInfoListURL;


#pragma mark - PlayerPoolCapacity

/**
 * @brief 播放器池容量，默认值为 2
 */
@property (class, nonatomic) NSInteger playerPoolCapacity;


#pragma mark - CoverURLStrategy

/**
 * @brief 启用封面 URL 策略，默认开启
 */
@property (class, nonatomic) BOOL enableCoverURLStrategy;


#pragma mark - Enable Advertisement

/**
 *@brief 启用广告页
 */
@property (class, nonatomic) BOOL enableAdvertisementPage;

@end

NS_ASSUME_NONNULL_END
