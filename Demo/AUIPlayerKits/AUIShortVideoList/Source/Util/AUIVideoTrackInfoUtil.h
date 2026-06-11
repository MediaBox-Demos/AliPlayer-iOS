//
//  AUIVideoTrackInfoUtil.h
//  AUIPlayer
//
//  Created by keria on 2024/11/20.
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

@interface AUIVideoTrackInfoUtil : NSObject

/**
 * @brief 获取工具类的单例实例。
 *
 * 该方法提供了工具类的单例实例，避免了不必要的实例化。由于这是一个
 * 工具类，其方法均为类方法，因此通常不需要实例化。
 *
 * @return AUIVideoTrackInfoUtil 的唯一实例。
 */
+ (instancetype)sharedInstance;

/**
 * @brief 过滤并返回仅包含视频清晰度轨的列表。
 *
 * 该方法接收一个音视频轨道信息的列表，并返回其中包含视频清晰度轨道的子集。
 * 在处理多种不同类型的轨道（如音频和视频）时，这是一个非常有用的工具。
 *
 * @param trackInfoList 包含音视频轨道信息的数组。
 *                      输入的列表可以包含不同类型的轨道，方法将筛选出其中的视频轨道。
 *
 * @return 仅包含视频清晰度轨的数组。如果输入为空或不包含视频轨道，返回空数组。
 */
+ (NSArray<AVPTrackInfo *> *)filterVideoTrackInfoList:(NSArray<AVPTrackInfo *> *)trackInfoList;

/**
 * @brief 获取视频轨道的质量描述。
 *
 * 通过分析输入的视频轨道信息，返回与该视频轨道最匹配的分辨率描述（如 "720P"）。
 * 如果给定的轨道信息为空，则返回 "AUTO" 表示自动选择质量。
 *
 * @param trackInfo 视频轨道信息对象。
 *                  该对象应该包含有关轨道的视频宽度、高度等信息。
 *
 * @return 表示视频质量的字符串（如 "720P"）。如果轨道信息无效或为空，返回 "AUTO"。
 */
+ (NSString *)getQuality:(AVPTrackInfo *)trackInfo;

@end

NS_ASSUME_NONNULL_END
