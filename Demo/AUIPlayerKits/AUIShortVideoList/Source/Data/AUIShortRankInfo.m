//
//  AUIShortRankInfo.m
//  AUIPlayer
//
//  Created by aqi on 2025/11/10.
//

#import "AUIShortRankInfo.h"

@implementation AUIShortRankInfo

/**
 * @brief 从字典创建 AUIShortRankInfo 实例（JSON 反序列化入口）。
 *
 * 将服务端返回的榜单数据字典解析为 AUIShortRankInfo 对象，安全处理空输入，
 * 并将 JSON 中的 "description" 字段映射到 descriptionText 属性以避免与 NSObject 冲突。
 *
 * @param dict 包含榜单信息的原始字典，应包含 rankId、rankName 和 description 等键。
 * @return 返回初始化后的 AUIShortRankInfo 实例；若输入无效则返回 nil。
 */
+ (instancetype)responseObjectWithDictionary:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    AUIShortRankInfo *info = [[AUIShortRankInfo alloc] init];
    info.rankId = dict[@"rankId"];
    info.rankName = dict[@"rankName"];
    info.descriptionText = dict[@"description"]; // JSON key 为 "description"
    return info;
}

/**
 * @brief 将当前对象转换为字典（用于 JSON 序列化）。
 *
 * 将对象属性转换为可序列化的 NSDictionary，其中 descriptionText 重新映射回 JSON 标准字段名 "description"，
 * 空值字段替换为空字符串以确保输出结构稳定。
 *
 * @return 返回包含 rankId、rankName 和 description 字段的不可变字典。
 */
- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"rankId"] = self.rankId ?: @"";
    dict[@"rankName"] = self.rankName ?: @"";
    dict[@"description"] = self.descriptionText ?: @""; // 对应回 JSON 的 "description"
    return [dict copy];
}

#pragma mark - NSSecureCoding

/**
 * @brief 声明支持 NSSecureCoding 协议。
 *
 * 返回 YES 表示该类在归档/解档过程中仅允许已知类，防止反序列化任意对象带来的安全风险。
 */
+ (BOOL)supportsSecureCoding {
    return YES;
}

/**
 * @brief 从 NSCoder 解码并初始化对象（安全归档反序列化）。
 *
 * 从归档数据中恢复对象状态，使用 decodeObjectOfClass: 确保只加载 NSString 类型，
 * 防止类型混淆攻击。
 *
 * @param coder 包含归档数据的 NSCoder 实例。
 * @return 初始化后的 AUIShortRankInfo 对象。
 */
- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        _rankId = [coder decodeObjectOfClass:[NSString class] forKey:@"rankId"];
        _rankName = [coder decodeObjectOfClass:[NSString class] forKey:@"rankName"];
        _descriptionText = [coder decodeObjectOfClass:[NSString class] forKey:@"descriptionText"];
    }
    return self;
}

/**
 * @brief 将对象编码到 NSCoder（安全归档序列化）。
 *
 * 将所有属性写入归档流，供 NSKeyedArchiver 持久化存储。
 *
 * @param coder 用于写入数据的 NSCoder 实例。
 */
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.rankId forKey:@"rankId"];
    [coder encodeObject:self.rankName forKey:@"rankName"];
    [coder encodeObject:self.descriptionText forKey:@"descriptionText"];
}

#pragma mark - NSCopying

/**
 * @brief 实现 NSCopying 协议，支持对象深拷贝。
 *
 * 创建当前对象的一个独立副本，所有字符串属性均通过 copy 语义赋值，
 * 确保副本与原对象互不影响。
 *
 * @param zone 内存分配区域（通常可忽略，传入 nil 即可）。
 * @return 返回一个新的 AUIShortRankInfo 实例，内容与原对象一致。
 */
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    AUIShortRankInfo *copy = [[AUIShortRankInfo allocWithZone:zone] init];
    copy.rankId = self.rankId;
    copy.rankName = self.rankName;
    copy.descriptionText = self.descriptionText;
    return copy;
}

#pragma mark - NSObject

/**
 * @brief 重写 description 方法，便于调试和日志输出。
 *
 * 返回一个格式化的字符串，清晰展示榜单的关键信息，适用于 NSLog 或断点调试。
 *
 * @return 格式如：RankInfo{rankId='123', rankName='热播榜', description='根据播放量排序'}
 */
- (NSString *)description {
    return [NSString stringWithFormat:@"RankInfo{rankId='%@', rankName='%@', description='%@'}",
            self.rankId ?: @"",
            self.rankName ?: @"",
            self.descriptionText ?: @""];
}

@end

