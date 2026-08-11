//
//  AUIShortVideoListDataManager.h
//  AUIShortVideoList
//
//  Created by Bingo on 2023/9/17.
//

#import <UIKit/UIKit.h>
#import "AUIShortVideoInfo.h"

/**
 * @brief VOD App Server 部署后的接口 API 地址
 *
 * 请将此地址修改为您自己部署的 App Server 地址
 * 客户端将通过该地址访问服务端功能（如鉴权、上传、播放信息获取等）
 */
#define DEFAULT_APP_SERVER_URL @"https://vodappserver-gwzwacvbyf.cn-shanghai.fcapp.run"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 视频信息列表请求完成回调 Block。
 *
 * 当视频列表请求成功时，data 包含解析后的 AUIShortVideoInfo 对象数组；
 * 若请求失败或数据无效，则 data 为 nil，error 包含具体错误信息。
 *
 * @param data 成功时返回的视频信息列表，可能为空数组但不会是未初始化状态；失败时为 nil。
 * @param error 请求过程中发生的错误（如网络异常、JSON 解析失败等），成功时为 nil。
 */
typedef void(^VideoInfoListRequestBlock)(NSArray<AUIShortVideoInfo *> * _Nullable data, NSError * _Nullable error);

/**
 * @class AUIShortVideoListDataManager
 *
 * @brief 数据管理器类，用于请求和处理短视频信息列表。
 *
 * 封装了从网络获取视频列表数据的完整流程，包括发起 HTTP 请求、解析 JSON 响应、
 * 转换为 AUIShortVideoInfo 模型对象，并通过回调将结果传递给业务层。
 * 支持通用 URL 请求和基于剧集 ID 的专用接口。
 */
@interface AUIShortVideoListDataManager : NSObject

/**
 * @brief 通过指定 URL 请求视频信息列表。
 *
 * 发起 GET 请求到给定的 url，期望返回符合 AUIShortVideoListResponse 结构的 JSON 数据，
 * 自动解析并提取其中的 video 列表（需确保响应中包含可映射为 AUIShortVideoInfo 的数组）。
 *
 * @param url 视频信息列表的完整请求 URL（必须为有效 HTTPS 地址）。
 * @param completed 请求完成后的回调 Block，运行在主线程，可用于直接更新 UI。
 */
+ (void)requestVideoInfoList:(NSString *)url completed:(VideoInfoListRequestBlock)completed;

/**
 * @brief 通过剧集 ID 请求对应的视频列表。
 *
 * 根据 playListId 构造专用接口地址（如 /appServer/getPlaylistInfo?playListId={playListId}），获取该短剧下的所有分集视频信息。
 * 内部会自动处理路径拼接、参数注入及响应解析。
 *
 * @param playListId 目标短剧的唯一标识符（不能为空或空字符串）。
 * @param completed 请求完成后的回调 Block，运行在主线程，data 为该短剧的视频分集列表。
 */
+ (void)requestPlayListDetail:(nullable NSString *)playListId completed:(VideoInfoListRequestBlock)completed;

/**
 * @brief 请求默认短剧播放列表。
 *
 * 当未指定具体剧集 ID 时，调用此方法可获取系统预设或推荐的默认视频列表。
 *
 * @param completed 请求完成后的回调 Block，运行在主线程，data 为默认短剧的视频分集列表。
 */
+ (void)requestDefaultPlayList:(VideoInfoListRequestBlock)completed;

@end

NS_ASSUME_NONNULL_END


