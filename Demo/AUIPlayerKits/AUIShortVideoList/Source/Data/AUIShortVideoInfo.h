//
//  AUIShortVideoInfo.h
//  AUIPlayer
//
//  Created by keria on 2024/11/7.
//

// AUIShortVideoInfo.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class AUIShortVideoInfo
 *
 * @brief 视频信息数据类，对应 Android 的 VideoInfo。
 *        保留 uniqueKey 用于对象唯一标识，其余字段与 Android 完全对齐，确保双端数据结构一致。
 */
@interface AUIShortVideoInfo : NSObject

#pragma mark - 唯一标识符

/**
 * @brief 对象的唯一标识符（只读）。
 * 由系统在初始化时生成（如基于 videoId 或 playlistId），用于在内存中区分不同视频对象。
 */
@property (nonatomic, copy, readonly) NSString *uniqueKey;

/**
 * @brief 剧集中该视频的唯一标识 ID（业务侧定义）。
 * 由业务系统分配，用于标识某部短剧中的一集视频，通常与剧集上下文绑定。
 */
@property (nonatomic, copy) NSString *playlistId;

/**
 * @brief 视频资源的唯一标识 ID（平台侧 ID）。
 * 由视频平台（如阿里云点播）分配的全局唯一视频 ID，用于播放、管理等底层操作。
 */
@property (nonatomic, copy) NSString *videoId;

/**
 * @brief 视频标题。
 * 用于在 UI 中展示该集视频的名称或副标题，例如“第3集：真相揭晓”。
 */
@property (nonatomic, copy) NSString *title;

/**
 * @brief 视频作者/创作者名称。
 * 表示内容生产者或发布者的名称，可用于个人主页跳转或版权展示。
 */
@property (nonatomic, copy) NSString *author;

/**
 * @brief 视频时长（单位：秒）。
 * 精确到小数点后一位或两位，用于进度条计算、预估观看时间等场景。
 */
@property (nonatomic, assign) double duration;

/**
 * @brief 视频描述信息。
 * 对视频内容的简要介绍或剧情概要；命名为 descriptionText 以避免与 NSObject 的 description 方法冲突。
 */
@property (nonatomic, copy) NSString *descriptionText; // 避免与 NSObject.description 冲突

/**
 * @brief 视频封面图地址。
 * 用于在列表或详情页展示视频缩略图，通常为 CDN 加速的图片 URL。
 */
@property (nonatomic, copy) NSString *coverUrl;

/**
 * @brief 播放凭证（PlayAuth）。
 * 阿里云点播服务所需的临时播放授权字符串，适用于 vidAuth 播放模式；可能为 nil。
 */
@property (nonatomic, copy, nullable) NSString *playAuth;

/**
 * @brief 视频播放地址 URL。
 * 直接可播放的视频流地址（如 HLS 或 MP4），适用于 url 播放模式；可能为 nil。
 */
@property (nonatomic, copy, nullable) NSString *playUrl;

/**
 * @brief 临时访问密钥 ID（STS）。
 * 用于 STS 安全令牌认证的 Access Key ID，配合 accessKeySecret 和 securityToken 使用；可能为 nil。
 */
@property (nonatomic, copy, nullable) NSString *accessKeyId;

/**
 * @brief 临时访问密钥 Secret。
 * 与 accessKeyId 配对使用的密钥 Secret，用于签名验证；可能为 nil。
 */
@property (nonatomic, copy, nullable) NSString *accessKeySecret;

/**
 * @brief 临时安全令牌（SecurityToken）。
 * STS 临时凭证的一部分，用于增强安全性；可能为 nil。
 */
@property (nonatomic, copy, nullable) NSString *securityToken;

/**
 * @brief 视频所在区域/地域（如 "cn-shanghai"）。
 * 指定视频资源所属的云服务区域，影响播放器初始化和 CDN 调度；可能为 nil。
 */
@property (nonatomic, copy, nullable) NSString *region;

/**
 * @brief 是否开启下载功能开关。
 * 若为 YES，表示该视频允许用户下载到本地；否则禁止下载。
 */
@property (nonatomic, assign) BOOL downloadSwitch;

/**
 * @brief 视频标签集合。
 * 以字符串形式存储多个标签（如逗号分隔："甜宠,古装,逆袭"），用于推荐或筛选。
 */
@property (nonatomic, copy) NSString *tags;

/**
 * @brief 分类 ID。
 * 视频所属内容分类的数字 ID，用于后台统计或频道划分。
 */
@property (nonatomic, assign) long long cateId;

/**
 * @brief 分类名称。
 * 对应 cateId 的可读分类名称，例如“都市情感”、“悬疑推理”等。
 */
@property (nonatomic, copy) NSString *cateName;

/**
 * @brief 点赞数量。
 * 用户对该视频的点赞总数，用于热度排序或社交互动展示。
 */
@property (nonatomic, assign) NSInteger likeCount;

/**
 * @brief 评论数量。
 * 该视频下的评论总数，反映用户参与度。
 */
@property (nonatomic, assign) NSInteger commentCount;

/**
 * @brief 分享次数。
 * 视频被分享到外部平台（如微信、微博）的总次数。
 */
@property (nonatomic, assign) NSInteger shareCount;

/**
 * @brief 收藏/喜欢次数。
 * 用户将视频加入收藏夹或标记为喜欢的总次数。
 */
@property (nonatomic, assign) NSInteger favoriteCount;

/**
 * @brief 所属剧集的序号（数值型）。
 * 表示该视频在短剧中的播放顺序，如 1、2、10 等。
 * 若未设置或无效，则为 nil。
 */
@property (nonatomic, copy, nullable) NSNumber *seriesNum;

/**
 * @brief 视频来源类型（"url" / "vidAuth" / "vidSts"）。
 * 指示播放器应采用哪种方式加载视频：
 *   - "url": 直接使用 playUrl；
 *   - "vidAuth": 使用 videoId + playAuth；
 *   - "vidSts": 使用 videoId + STS 三元组（accessKeyId/accessKeySecret/securityToken）。
 * 可能为 nil，此时需根据其他字段推断。
 */
@property (nonatomic, copy, nullable) NSString *sourceType;

/**
 * @brief WebVTT 字幕文件地址。
 * 指向标准 WebVTT 格式的字幕文件 URL，支持多语言字幕加载；可能为 nil。
 */
@property (nonatomic, copy, nullable) NSString *webVTT;

/**
 * @brief 视频类型标识。
 * 自定义视频类型标签，如 "trailer"（预告片）、"full"（正片）等，用于业务逻辑区分；可能为 nil。
 */
@property (nonatomic, copy, nullable) NSString *videoType;


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


#pragma mark - 方法

/**
 * @brief 初始化方法，用字典设置属性。
 *
 * 从 JSON 字典解析并填充所有字段，同时生成 uniqueKey（如基于 videoId 或 playlistId）。
 *
 * @param dict 包含视频原始数据的字典。
 * @return 返回初始化后的 AUIShortVideoInfo 实例。
 */
- (instancetype)initWithDict:(NSDictionary *)dict;

/**
 * @brief 转为字典（用于调试、缓存或网络上传）。
 *
 * 将对象转换为可序列化的 NSDictionary，便于日志输出或二次传输。
 *
 * @return 返回包含所有有效字段的字典。
 */
- (NSDictionary *)toDictionary;

/**
 * @brief 获取精简版视频信息字符串。
 *
 * 返回一个简洁的调试字符串，包含 videoId、title、duration 等关键信息，
 * 适用于日志打印或断点查看。
 *
 * @return 格式如：[Video: videoId=xxx, title='...', duration=120.5s]
 */
- (NSString *)summaryString;

@end

NS_ASSUME_NONNULL_END

