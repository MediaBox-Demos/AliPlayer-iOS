//
//  AUIShortVideoInfo.m
//  AUIPlayer
//
//  Created by keria on 2024/11/7.
//

#import "AUIShortVideoInfo.h"
#import <CommonCrypto/CommonDigest.h>

#define SafeValue(value) ({ \
    __typeof__(value) _v = (value); \
    (_v == [NSNull null] || _v == nil) ? nil : _v; \
})

@interface AUIShortVideoInfo ()
/**
 * @brief 生成对象的唯一标识符。
 *
 * 基于 videoId（优先）或 playlistId 生成 SHA256 哈希值作为 uniqueKey，
 * 确保相同视频内容在多次解析时获得相同的唯一标识，便于缓存和比较。
 *
 * @return 返回十六进制字符串形式的 SHA256 哈希值；若无有效 ID，则回退到随机 UUID。
 */
- (NSString *)generateUniqueKey;
@end

@implementation AUIShortVideoInfo

/**
 * @brief 使用字典初始化 AUIShortVideoInfo 实例（JSON 反序列化）。
 *
 * 解析来自 Android 端对齐的视频数据字典，兼容多种类型（如 boolean 字符串或 NSNumber），
 * 并在初始化完成后生成稳定的 uniqueKey 用于对象标识。
 *
 * @param dict 包含完整视频信息的原始字典，字段需与 Android VideoInfo 一致。
 * @return 返回初始化后的 AUIShortVideoInfo 实例。
 */
- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        // ========== 解析 Android VideoInfo 字段 ==========
        _playlistId = SafeValue(dict[@"playlistId"]);
        _videoId = SafeValue(dict[@"videoId"]);
        _title = SafeValue(dict[@"title"]);
        _author = SafeValue(dict[@"author"]);

        // 数值类型：先安全取值，再判断是否为 nil，避免向 nil 发送 doubleValue 消息
        id durationObj = SafeValue(dict[@"duration"]);
        _duration = durationObj ? [durationObj doubleValue] : 0.0;

        _descriptionText = SafeValue(dict[@"description"]); // JSON key 为 "description"
        _coverUrl = SafeValue(dict[@"coverUrl"]);
        _playAuth = SafeValue(dict[@"playAuth"]);
        _playUrl = SafeValue(dict[@"playUrl"]);
        _accessKeyId = SafeValue(dict[@"accessKeyId"]);
        _accessKeySecret = SafeValue(dict[@"accessKeySecret"]);
        _securityToken = SafeValue(dict[@"securityToken"]);
        _region = SafeValue(dict[@"region"]);

        
        // downloadSwitch: 兼容 boolean（NSNumber）或字符串（"1"/"0"/"true"/"false"）
        id downloadSwitchObj = dict[@"downloadSwitch"];
        if ([downloadSwitchObj isKindOfClass:[NSNumber class]]) {
            _downloadSwitch = [downloadSwitchObj boolValue];
        } else if ([downloadSwitchObj isKindOfClass:[NSString class]]) {
            NSString *str = (NSString *)downloadSwitchObj;
            _downloadSwitch = [str isEqualToString:@"1"] ||
                              [str isEqualToString:@"true"] ||
                              [str isEqualToString:@"YES"];
        } // 否则保持默认 NO
        
        
        
        _tags = SafeValue(dict[@"tags"]);
        _cateName = SafeValue(dict[@"cateName"]);
        _sourceType = SafeValue(dict[@"sourceType"]);
        _webVTT = SafeValue(dict[@"webVTT"]);
        _videoType = SafeValue(dict[@"videoType"]);
        _seriesNum = [dict[@"seriesNum"] isKindOfClass:[NSNumber class]] ? dict[@"seriesNum"] : nil;


        // 数值类型：安全转换
        id cateIdObj = SafeValue(dict[@"cateId"]);
        _cateId = cateIdObj ? [cateIdObj longLongValue] : 0LL;

        id likeCountObj = SafeValue(dict[@"likeCount"]);
        _likeCount = likeCountObj ? [likeCountObj integerValue] : 0;

        id commentCountObj = SafeValue(dict[@"commentCount"]);
        _commentCount = commentCountObj ? [commentCountObj integerValue] : 0;

        id shareCountObj = SafeValue(dict[@"shareCount"]);
        _shareCount = shareCountObj ? [shareCountObj integerValue] : 0;

        id favoriteCountObj = SafeValue(dict[@"favoriteCount"]);
        _favoriteCount = favoriteCountObj ? [favoriteCountObj integerValue] : 0;

        // ========== 生成唯一 Key（基于业务 ID，确保稳定性）==========
        _uniqueKey = [self generateUniqueKey];
    }
    return self;
}

/**
 * @brief 重写 description 方法，返回精简版视频信息。
 *
 * 调用类方法 getSlimVideoInfo: 生成易读的调试字符串，适用于 NSLog 或控制台输出。
 *
 * @return 格式如：[Video: videoId=vid123, title='第1集', duration=120.5s]
 */
- (NSString *)description {
    return [AUIShortVideoInfo getSlimVideoInfo:self];
}

/**
 * @brief 生成基于业务 ID 的稳定唯一键。
 *
 * 使用随机 UUID 保证非空。
 *
 * @return 十六进制小写字符串形式的 SHA256 哈希值。
 */
- (NSString *)generateUniqueKey {
    NSString *uuidString = [[NSUUID UUID] UUIDString];
    const char *cStr = [uuidString UTF8String];
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

#pragma mark - Utility Class Methods

/**
 * @brief 获取视频对象的精简调试信息字符串。
 *
 * 提取关键字段（videoId、title、duration）生成紧凑描述，便于日志追踪。
 *
 * @param video 要描述的 AUIShortVideoInfo 实例。
 * @return 返回格式化的摘要字符串。
 */
+ (NSString *)getSlimVideoInfo:(AUIShortVideoInfo *)video {
    if (!video) return @"<null video>";
    return [NSString stringWithFormat:@"[Video: videoId=%@, title='%@', duration=%.1fs]",
            video.videoId ?: @"nil",
            video.title ?: @"(no title)",
            video.duration];
}

/**
 * @brief 将当前对象转换为字典（用于 JSON 序列化）。
 *
 * 将所有属性映射回与 Android 端一致的 JSON 结构，其中 descriptionText 输出为 "description"。
 *
 * @return 返回可直接转 JSON 的 NSDictionary。
 */
- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    dict[@"playlistId"] = self.playlistId ?: @"";
    dict[@"videoId"] = self.videoId ?: @"";
    dict[@"title"] = self.title ?: @"";
    dict[@"author"] = self.author ?: @"";
    dict[@"duration"] = @(self.duration);
    dict[@"description"] = self.descriptionText ?: @""; // 映射回 JSON 字段名
    dict[@"coverUrl"] = self.coverUrl ?: @"";
    dict[@"playAuth"] = self.playAuth ?: @"";
    dict[@"playUrl"] = self.playUrl ?: @"";
    dict[@"accessKeyId"] = self.accessKeyId ?: @"";
    dict[@"accessKeySecret"] = self.accessKeySecret ?: @"";
    dict[@"securityToken"] = self.securityToken ?: @"";
    dict[@"region"] = self.region ?: @"";
    dict[@"downloadSwitch"] = @(self.downloadSwitch);
    dict[@"tags"] = self.tags ?: @"";
    dict[@"cateId"] = @(self.cateId);
    dict[@"cateName"] = self.cateName ?: @"";
    dict[@"likeCount"] = @(self.likeCount);
    dict[@"commentCount"] = @(self.commentCount);
    dict[@"shareCount"] = @(self.shareCount);
    dict[@"favoriteCount"] = @(self.favoriteCount);
    dict[@"seriesNum"] = self.seriesNum ?: @"";
    dict[@"sourceType"] = self.sourceType ?: @"";
    dict[@"webVTT"] = self.webVTT ?: @"";
    dict[@"videoType"] = self.videoType ?: @"";
    
    return [dict copy];
}

- (nonnull NSString *)summaryString {
    return [NSString stringWithFormat:@"[Video] playlistId=%@, videoId=%@, series=%@, title='%@', duration=%.1fs",
                self.playlistId ?: @"(null)",
                self.videoId ?: @"(null)",
                self.seriesNum ?: @"(null)",
                self.title ?: @"(no title)",
                self.duration];
}

@end
