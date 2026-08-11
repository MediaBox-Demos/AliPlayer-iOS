//
//  AUIShortPlaylistInfo.h
//  AUIPlayer
//
//  Created by aqi on 2025/11/10.
//

// AUIShortPlaylistInfo.h
#import <Foundation/Foundation.h>
#import <AUIShortVideoInfo.h>
#import <AUIShortRankInfo.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @class AUIShortPlaylistInfo
 *
 * @brief 该类用于存储和管理短剧（Short Playlist）的相关信息，包括剧集 ID、封面、人气值、视频列表、所属榜单等核心数据。
 *
 * AUIShortPlaylistInfo 封装了一个完整短剧对象的所有关键属性，支持安全归档（NSSecureCoding），并提供便捷的 JSON 序列化与反序列化方法，
 * 便于在网络传输或本地缓存中使用。
 */
@interface AUIShortPlaylistInfo : NSObject <NSSecureCoding>

/**
 * @brief 剧集唯一标识 ID。
 * 用于唯一标识一个短剧资源。
 */
@property (nonatomic, copy) NSString *playlistId;

/**
 * @brief 视频总数量 / 剧集总集数。
 * 表示该短剧包含的视频总集数。
 */
@property (nonatomic, copy, nullable) NSNumber *videoCount;

/**
 * @brief 剧集封面图片 URL。
 * 用于在列表或详情页展示短剧的封面图。
 */
@property (nonatomic, copy) NSString *playlistCoverUrl;

/**
 * @brief 人气值。
 * 用于衡量该剧集的受欢迎程度，数值越高表示热度越高。
 */
@property (nonatomic, copy, nullable) NSNumber *popularity;

/**
 * @brief 追剧/订阅人数。
 * 表示当前有多少用户关注或订阅了该短剧。
 */
@property (nonatomic, copy, nullable) NSNumber *followCount;


/**
 * @brief 剧集所属榜单列表。
 * 包含多个 AUIShortRankInfo 对象，表示该剧参与的各类榜单或分类。
 */
@property (nonatomic, strong) NSArray<AUIShortRankInfo *> *rankList;

/**
 * @brief 剧集名称（主标题）。
 * 用于在 UI 中展示短剧的正式名称。
 */
@property (nonatomic, copy) NSString *playlistName;


/**
 * @brief 播放列表中的视频总数。
 * 来源于 playlistExtension.count，可能为 nil。
 */
@property (nonatomic, copy, nullable) NSNumber *count;

/**
 * @brief 预览视频的 videoId。
 * 来源于 playlistExtension.previewVideoId，用于首帧预览或封面推荐；可能为 nil。
 */
@property (nonatomic, copy, nullable) NSString *previewVideoId;


/**
 * @brief 视频总数
 * 新增：总时长或总数等，可为空
 */
@property (nonatomic, copy, nullable) NSNumber *total;


/**
 * @brief 剧集包含的视频列表。
 * 每个元素为 AUIShortVideoInfo 类型，代表一集具体的视频内容。
 */
@property (nonatomic, strong) NSArray<AUIShortVideoInfo *> *playlistVideos;

/**
 * @brief 从字典初始化一个 AUIShortPlaylistInfo 实例（用于 JSON 反序列化）。
 *
 * @param dict 包含短剧信息的字典，键需与属性名对应。
 * @return 返回初始化后的 AUIShortPlaylistInfo 对象；若 dict 为 nil 或格式错误，则返回 nil。
 */
+ (instancetype)responseObjectWithDictionary:(NSDictionary *)dict;

/**
 * @brief 将当前对象转换为字典（用于 JSON 序列化）。
 *
 * @return 返回包含所有属性的字典，可用于网络上传或持久化存储。
 */
- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END


