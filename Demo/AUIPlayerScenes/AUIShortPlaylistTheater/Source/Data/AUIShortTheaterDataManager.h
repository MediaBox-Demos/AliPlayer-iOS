//
//  AUIShortTheaterDataManager.h
//  AUIPlayer
//
//  Created by keria on 2024/11/7.
//

#import <Foundation/Foundation.h>
#import "AUIShortVideoInfo.h"
#import "AUIShortPlaylistInfo.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @typedef PlaylistInfoListRequestBlock
 *
 * @brief 定义一个块类型，用于请求短剧剧集信息列表后的回调。
 *
 * @param data 请求到的短剧剧集信息数组，如果请求失败则为 nil。
 * @param error 请求过程中发生的错误，如果请求成功则为 nil。
 */
typedef void(^PlaylistInfoListRequestBlock)(NSArray<AUIShortPlaylistInfo *> * _Nullable data, NSError * _Nullable error);

/**
 * @typedef PlaylistInfoDetailRequestBlock
 *
 * @brief 定义一个块类型，用于请求短剧剧集详情后的回调。
 *
 * @param data 请求到的短剧剧集信息详情，如果请求失败则为 nil。
 * @param error 请求过程中发生的错误，如果请求成功则为 nil。
 */
typedef void(^PlaylistInfoDetailRequestBlock)(AUIShortPlaylistInfo * _Nullable data, NSError * _Nullable error);

/**
 * @class AUIShortTheaterDataManager
 *
 * @brief 数据管理器类，用于请求和处理短剧剧集信息列表。通过网络请求获取短剧剧集列表数据，并将数据解析成模型，处理完成后返回给调用方。
 */
@interface AUIShortTheaterDataManager : NSObject

/**
 * @brief 请求短剧剧集信息列表
 *
 * @param url 短剧剧集信息列表的请求 URL。
 * @param completed 请求完成后的回调，包含获取的数据数组或错误信息。
 */
+ (void)requestPlayListInfoList:(NSString *)url completed:(PlaylistInfoListRequestBlock)completed;

/**
 * @brief 从短剧剧集列表中提取每个短剧的第一个视频信息。
 *
 * 该方法用于迭代给定的短剧信息列表，从每个短剧中提取出其首个视频信息（如果存在）并返回一个包含这些信息的可变数组。
 * 如果输入数组为空或所有短剧都没有视频信息，则返回 nil。
 *
 * @param playlistInfos 包含短剧信息的数组，每个元素为 AUIShortPlaylistInfo 类型。数组可以为空或 nil。
 * @return 一个可变数组，包含每个短剧的第一个视频信息（AUIShortVideoInfo）。如果输入列表为空或不包含有效信息，则返回 nil。
 */
+ (NSMutableArray<AUIShortVideoInfo *> * _Nullable)getFirstVideoFromPlayListInfos:(NSArray<AUIShortPlaylistInfo *> * _Nullable)playlistInfos;

/**
 * @brief 根据视频信息获取对应的短剧剧集信息。
 *
 * 该方法通过给定的视频信息（AUIShortVideoInfo）来索引匹配的短剧剧集信息（AUIShortPlaylistInfo）。
 * 通过比较视频的URL，返回与该视频关联的短剧信息。
 *
 * @param videoInfo 包含视频信息的对象，它应包含有效的 `url` 属性，作为识别视频的依据。
 * @param playlistInfos 一个短剧剧集信息的数组，每个元素是 AUIShortPlaylistInfo 类型，其中包含多个短视频的信息，列表可为空或 nil。
 *
 * @return 返回与给定视频信息匹配的 AUIShortPlaylistInfo 对象。如果没有找到匹配的短剧信息，或者输入无效（例如，videoInfo 为 nil），则返回 nil。
 */
+ (AUIShortPlaylistInfo * _Nullable)getPlayListFromVideoInfo:(AUIShortVideoInfo *)videoInfo playlistInfos:(NSArray<AUIShortPlaylistInfo *> * _Nullable)playlistInfos;



/**
 * @brief 根据视频信息异步请求对应的短剧剧集详情。
 *
 * 该方法通过给定的视频信息（AUIShortVideoInfo）向服务器发起网络请求，
 * 获取该视频所属的完整短剧剧集信息（AUIShortPlaylistInfo）。
 * 通常使用视频的 playlistId 或 videoId 作为查询参数。
 *
 * @param videoInfo 包含视频信息的对象，用于提取查询参数（如 playlistId、videoId 等）。
 *                  若为 nil，将直接通过 completed 回调返回 nil。
 * @param complete  请求完成后的回调 block。
 *                  - 参数1: 获取到的短剧剧集信息（AUIShortPlaylistInfo），若失败或无结果则为 nil。
 *                  - 参数2: 请求过程中发生的错误（NSError），若成功则为 nil。
 *
 * @note 该方法为异步操作，结果通过 completed block 返回，不会阻塞主线程。
 */
+ (void)getPlayListDetail:(AUIShortVideoInfo *)videoInfo completed:(PlaylistInfoDetailRequestBlock)complete;

@end

NS_ASSUME_NONNULL_END
