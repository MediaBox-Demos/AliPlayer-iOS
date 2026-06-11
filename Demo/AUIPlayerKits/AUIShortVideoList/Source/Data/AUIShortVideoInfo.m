//
//  AUIShortVideoInfo.m
//  AUIPlayer
//
//  Created by keria on 2024/11/7.
//

#import "AUIShortVideoInfo.h"
#import <CommonCrypto/CommonDigest.h>

@interface AUIShortVideoInfo ()

/**
 * @brief 生成对象的唯一标识符
 * @details 该方法负责生成一个唯一的字符串，用作该对象的标识符。通常用于标识每个对象实例
 *          的唯一性，确保在需要识别不重复对象的时候有一个可靠的标识。
 *
 * @return 返回生成的唯一键字符串，用于标识对象的独特身份。
 *
 * @note 该方法采用某种算法保证生成的Key在特定的环境和时间段内不会重复。
 *       具体的生成算法可以根据需要调整，以适应不同的唯一性和安全性需求。
 */
- (NSString *)generateUniqueKey;

@end

@implementation AUIShortVideoInfo

// 初始化方法，用给定的字典来设置对象的属性。
- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        // 解析字典并初始化属性
        _videoId = [dict[@"id"] integerValue]; // 使用键 "id" 初始化 videoId
        _url = dict[@"url"];                   // 使用键 "url" 初始化 url
        _coverUrl = dict[@"coverUrl"];         // 使用键 "coverUrl" 初始化 coverUrl
        _author = dict[@"author"];             // 使用键 "author" 初始化 author
        _title = dict[@"title"];               // 使用键 "title" 初始化 title
        _type = dict[@"type"];                 // 使用键 "type" 初始化 type
        
        // 生成唯一Key
        _uniqueKey = [self generateUniqueKey];
    }
    return self;
}

// 返回对象的字符串描述
- (NSString *)description {
    return [AUIShortVideoInfo getSlimVideoInfo:self];
}

// 生成对象的唯一标识符
- (NSString *)generateUniqueKey {
    // 使用 UUID 生成器生成一个唯一的字符串
    NSString *uuidString = [[NSUUID UUID] UUIDString];
    
    // 使用 SHA256 对 UUID 字符串进行加密处理
    const char *cStr = [uuidString UTF8String];
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

// 获取精简版的视频信息字符串
+ (NSString *)getSlimVideoInfo:(AUIShortVideoInfo *)videoInfo {
    // 检查视频信息是否有效
    if (!videoInfo) {
        return @"nil";
    }

    NSInteger videoId = videoInfo.videoId;
//    NSString *videoUrl = videoInfo.url ? videoInfo.url.lastPathComponent : nil;
//    NSString *coverUrl = videoInfo.coverUrl ? videoInfo.coverUrl.lastPathComponent : nil;
//    return [NSString stringWithFormat:@"<%@: %p; id = %ld; video = %@; cover = %@>", NSStringFromClass([AUIShortVideoInfo class]), videoInfo, videoId, videoUrl, coverUrl];
    return [NSString stringWithFormat:@"<%@: %p; id = %ld>", NSStringFromClass([AUIShortVideoInfo class]), videoInfo, videoId];
}

@end
