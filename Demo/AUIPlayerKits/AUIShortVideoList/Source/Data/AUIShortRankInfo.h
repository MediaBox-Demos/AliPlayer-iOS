//
//  AUIShortRankInfo.h
//  AUIPlayer
//
//  Created by aqi on 2025/11/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class AUIShortRankInfo
 *
 * @brief 该类用于表示短剧所属的榜单信息，包含榜单 ID、名称和描述等元数据。
 *
 * AUIShortRankInfo 封装了单个榜单的基本信息，支持安全归档（NSSecureCoding）和对象拷贝（NSCopying），
 * 并提供 JSON 序列化与反序列化能力，适用于网络传输和本地缓存场景。
 */
@interface AUIShortRankInfo : NSObject <NSSecureCoding, NSCopying>

/**
 * @brief 榜单唯一标识 ID。
 * 用于唯一标识一个榜单，通常由服务端生成并返回，不可重复。
 */
@property (nonatomic, copy) NSString *rankId;

/**
 * @brief 榜单名称。
 * 榜单的可读性标题，例如“热播榜”、“新剧推荐”等，用于 UI 展示。
 */
@property (nonatomic, copy) NSString *rankName;

/**
 * @brief 榜单描述。
 * 对榜单内容或规则的简要说明，例如“根据播放量实时更新”，避免与 NSObject 的 description 方法冲突而命名为 descriptionText。
 */
@property (nonatomic, copy) NSString *descriptionText; // 避免与 NSObject 的 description 冲突

/**
 * @brief 从字典初始化（用于 JSON 反序列化）。
 *
 * 将包含榜单信息的字典转换为 AUIShortRankInfo 实例，适用于解析网络接口返回的数据。
 *
 * @param dict 包含 rankId、rankName、descriptionText 等字段的字典。
 * @return 返回初始化后的 AUIShortRankInfo 对象；若 dict 无效则返回 nil。
 */
+ (instancetype)responseObjectWithDictionary:(NSDictionary *)dict;

/**
 * @brief 转为字典（用于 JSON 序列化）。
 *
 * 将当前榜单对象转换为可序列化的字典，便于网络上传、本地存储或调试输出。
 *
 * @return 返回包含所有属性的 NSDictionary，空值字段将被转换为空字符串以保证结构完整性。
 */
- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END
