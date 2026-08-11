//
//  AUIShortPlaylistInfo.m
//  AUIPlayer
//
//  Created by aqi on 2025/11/10.
//

#import <AUIShortPlaylistInfo.h>
#import "AUIShortRankInfo.h"
#import "AUIShortVideoInfo.h"

#define SafeValue(value) ({ \
    __typeof__(value) _v = (value); \
    (_v == [NSNull null] || _v == nil) ? nil : _v; \
})


@implementation AUIShortPlaylistInfo

/**
 * @brief 从字典创建 AUIShortPlaylistInfo 实例（JSON 反序列化入口）。
 *
 * 该方法将传入的 NSDictionary 转换为 AUIShortPlaylistInfo 对象，安全处理空值和类型错误，
 * 并递归解析嵌套的 rankList 和 playlistVideos 数组。
 *
 * @param dict 包含短剧原始数据的字典，通常来自网络接口返回的 JSON。
 * @return 返回初始化完成的 AUIShortPlaylistInfo 对象；若输入无效则返回 nil。
 */
+ (instancetype)responseObjectWithDictionary:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    AUIShortPlaylistInfo *info = [[AUIShortPlaylistInfo alloc] init];
    info.playlistId = SafeValue(dict[@"playlistId"]);
    info.playlistCoverUrl = SafeValue(dict[@"playlistCoverUrl"]);

    info.videoCount = SafeValue(dict[@"videoCount"]);
    info.popularity = SafeValue(dict[@"popularity"]);
    info.followCount = SafeValue(dict[@"followCount"]);
    
    
    
    // 解析 rankList：将字典数组转换为 AUIShortRankInfo 对象数组
    NSMutableArray *rankList = [NSMutableArray array];
    NSArray *rankArray = dict[@"rankList"];
    if ([rankArray isKindOfClass:[NSArray class]]) {
        for (NSDictionary *rankDict in rankArray) {
            AUIShortRankInfo *rank = [AUIShortRankInfo responseObjectWithDictionary:rankDict];
            if (rank) {
                [rankList addObject:rank];
            }
        }
    }
    info.rankList = [rankList copy];
    
    info.total = SafeValue(dict[@"total"]);
    info.playlistName = SafeValue(dict[@"playlistName"]);
    
    
    
    // 解析 videoList：将视频字典数组转换为 AUIShortVideoInfo 对象数组
    NSMutableArray *videoList = [NSMutableArray array];
    NSArray *videoArray = dict[@"playlistVideos"];
    if ([videoArray isKindOfClass:[NSArray class]]) {
        for (NSDictionary *videoDict in videoArray) {
            // 初始化方法
            AUIShortVideoInfo *video = [[AUIShortVideoInfo alloc] initWithDict:videoDict];
            if (video) {
                [videoList addObject:video];
            }
        }
    }
    
    // ========== 解析 playlistExtension 扩展字段 ==========
    id playlistExtValue = dict[@"playlistExtension"];
    if (playlistExtValue && [playlistExtValue isKindOfClass:[NSString class]]) {
        NSString *extStr = (NSString *)playlistExtValue;
        if (extStr.length > 0) {
            NSData *data = [extStr dataUsingEncoding:NSUTF8StringEncoding];
            if (data) {
                NSError *error = nil;
                NSDictionary *extDict = [NSJSONSerialization JSONObjectWithData:data
                                                                        options:0
                                                                          error:&error];
                if (error == nil && extDict && [extDict isKindOfClass:[NSDictionary class]]) {
                    // 安全提取 count（必须是 NSNumber）
                    id countValue = extDict[@"count"];
                    if ([countValue isKindOfClass:[NSNumber class]]) {
                        info.count = countValue;
                    }
                    // 安全提取 previewVideoId（必须是 NSString）
                    id previewIdValue = extDict[@"previewVideoId"];
                    if ([previewIdValue isKindOfClass:[NSString class]]) {
                        info.previewVideoId = previewIdValue;
                    }
                }
            }
        }
    }

    
    
    
    
    info.playlistVideos = [videoList copy];
    
    return info;
}

/**
 * @brief 将当前对象转换为字典（用于 JSON 序列化）。
 *
 * 该方法将 AUIShortPlaylistInfo 的所有属性转换为可序列化的 NSDictionary，
 * 并递归调用子对象（如 rankList 和 playlistVideos 中的元素）的 toDictionary 方法，
 * 确保整个对象树可被编码为 JSON。
 *
 * @return 返回包含完整数据的 NSMutableDictionary，所有字段均非 nil（空值转为空字符串或默认值）。
 */
- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    dict[@"playlistId"] = self.playlistId ?: @"";
    dict[@"playlistCoverUrl"] = self.playlistCoverUrl ?: @"";
    dict[@"videoCount"] = self.videoCount ?: @0;
    dict[@"popularity"] = self.popularity ?: @0;
    dict[@"followCount"] = self.followCount ?: @0;
    dict[@"playlistName"] = self.playlistName ?: @"";

    // rankList
    NSMutableArray *rankArray = [NSMutableArray array];
    for (AUIShortRankInfo *rank in self.rankList ?: @[]) {
        if (rank) {
            [rankArray addObject:[rank toDictionary]];
        }
    }
    dict[@"rankList"] = [rankArray copy];

    // playlistVideos
    NSMutableArray *videoArray = [NSMutableArray array];
    for (AUIShortVideoInfo *video in self.playlistVideos ?: @[]) {
        if (video && [video respondsToSelector:@selector(toDictionary)]) {
            [videoArray addObject:[video toDictionary]];
        }
    }
    dict[@"playlistVideos"] = [videoArray copy];
    if (self.total != nil) {
        dict[@"total"] = self.total;
    }

    // 重建 playlistExtension 字符串（如果 count 或 previewVideoId 存在）
    if (self.count != nil || self.previewVideoId.length > 0) {
        NSMutableDictionary *extDict = [NSMutableDictionary dictionary];
        if (self.count != nil) {
            extDict[@"count"] = self.count;
        }
        if (self.previewVideoId.length > 0) {
            extDict[@"previewVideoId"] = self.previewVideoId;
        }
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:extDict
                                                           options:0
                                                             error:&error];
        if (jsonData && !error) {
            NSString *extStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            if (extStr) {
                dict[@"playlistExtension"] = extStr;
            }
        }
    }

    return [dict copy];
}


#pragma mark - NSSecureCoding

/**
 * @brief 支持 NSSecureCoding 所需的类标识。
 *
 * 返回 YES 表示该类支持安全归档，防止反序列化时加载未知类。
 */
+ (BOOL)supportsSecureCoding {
    return YES;
}

/**
 * @brief 编码对象以支持归档（NSCoding 协议实现）。
 *
 * 将所有属性通过 NSCoder 安全编码，确保可持久化存储。
 *
 * @param coder 用于写入数据的 NSCoder 实例。
 */
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.playlistId forKey:@"playlistId"];
    [coder encodeObject:self.videoCount forKey:@"videoCount"];          // NSNumber*
    [coder encodeObject:self.playlistCoverUrl forKey:@"playlistCoverUrl"];
    [coder encodeObject:self.popularity forKey:@"popularity"];          // NSNumber*
    [coder encodeObject:self.followCount forKey:@"followCount"];        // NSNumber*
    [coder encodeObject:self.rankList forKey:@"rankList"];
    [coder encodeObject:self.playlistName forKey:@"playlistName"];
    [coder encodeObject:self.playlistVideos forKey:@"playlistVideos"];
    [coder encodeObject:self.count forKey:@"count"];                    // NSNumber*
    [coder encodeObject:self.previewVideoId forKey:@"previewVideoId"];
    [coder encodeObject:self.total forKey:@"total"];
}


/**
 * @brief 从归档数据解码并初始化对象（NSCoding 协议实现）。
 *
 * 从 NSCoder 中读取数据并恢复对象状态，确保类型安全。
 *
 * @param coder 包含归档数据的 NSCoder 实例。
 * @return 初始化后的实例。
 */
- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        _playlistId = [coder decodeObjectOfClass:[NSString class] forKey:@"playlistId"];
        _videoCount = [coder decodeObjectOfClass:[NSNumber class] forKey:@"videoCount"];
        _playlistCoverUrl = [coder decodeObjectOfClass:[NSString class] forKey:@"playlistCoverUrl"];
        _popularity = [coder decodeObjectOfClass:[NSNumber class] forKey:@"popularity"];
        _followCount = [coder decodeObjectOfClass:[NSNumber class] forKey:@"followCount"];
        _rankList = [coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class],
                                                  [AUIShortRankInfo class],
                                                  nil] forKey:@"rankList"];
        _playlistName = [coder decodeObjectOfClass:[NSString class] forKey:@"playlistName"];
        _playlistVideos = [coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class],
                                                        [AUIShortVideoInfo class],
                                                        nil] forKey:@"playlistVideos"];
        _count = [coder decodeObjectOfClass:[NSNumber class] forKey:@"count"];
        _previewVideoId = [coder decodeObjectOfClass:[NSString class] forKey:@"previewVideoId"];
        _total = [coder decodeObjectOfClass:[NSNumber class] forKey:@"total"];
    }
    return self;
}

@end
