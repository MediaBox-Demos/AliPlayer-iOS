//
//  AUIShortPlayListDetailResponse.h
//  AUIPlayer
//
//  Created by aqi on 2025/11/6.
//

#import <Foundation/Foundation.h>
#import <AUIShortPlaylistInfo.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIShortPlayListDetailResponse : NSObject <NSSecureCoding>

/// 业务状态码（字符串形式，如 "200"、"500"）
@property (nonatomic, copy, nullable) NSString *code;

/// HTTP 状态码（可能为 null）
@property (nonatomic, strong, nullable) NSNumber *httpCode;

/// 是否成功（可能为 null，通常应为 BOOL，但按原结构保留为 NSNumber）
@property (nonatomic, strong, nullable) NSNumber *success;

/// 错误或提示信息
@property (nonatomic, copy, nullable) NSString *message;

/// 请求唯一标识 ID
@property (nonatomic, copy, nullable) NSString *requestId;

/// 响应数据主体
@property (nonatomic, strong, nullable) AUIShortPlaylistInfo *data;

/// 从字典初始化（用于 JSON 反序列化）
+ (instancetype)responseObjectWithDictionary:(NSDictionary *)dict;

/// 转为字典（用于 JSON 序列化）
- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END
