//
//  AUIShortPlayListResponse.h
//  AUIPlayer
//
//  Created by aqi on 2025/11/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class AUIShortPlayListResponse
 *
 * @brief 该类用于封装短剧列表接口的完整响应数据，包含状态码、提示信息及实际剧集列表。
 *
 * AUIShortPlayListResponse 是网络请求返回结果的标准包装类，支持从 JSON 字典解析和反向序列化，
 * 便于统一处理业务逻辑与错误状态。
 */
@interface AUIShortPlayListResponse : NSObject

/**
 * @brief 业务状态码（如 "200"）。
 * 表示后端业务逻辑的执行结果，通常为字符串类型，例如 "200" 表示成功，"400" 表示参数错误等。
 */
@property (nonatomic, copy, nullable) NSString *code;

/**
 * @brief HTTP 状态码（可能为 null）。
 * 对应 HTTP 响应的状态码（如 200、404、500），用于判断网络层是否成功，类型为 NSNumber。
 */
@property (nonatomic, strong, nullable) NSNumber *httpCode;

/**
 * @brief 是否成功（可能为 null）。
 * 业务层面的成功标识，通常为 @YES 或 @NO，用于快速判断请求是否可继续处理。
 */
@property (nonatomic, strong, nullable) NSNumber *success;

/**
 * @brief 错误或提示信息。
 * 当请求失败或需要提示用户时，返回的可读性消息，例如“参数错误”、“服务繁忙”等。
 */
@property (nonatomic, copy, nullable) NSString *message;

/**
 * @brief 请求唯一标识 ID。
 * 用于追踪单次请求的唯一 ID，便于日志排查和问题定位，通常由服务端生成并返回。
 */
@property (nonatomic, copy, nullable) NSString *requestId;

/**
 * @brief 剧集列表数据。
 * 包含多个 AUIShortPlaylistInfo 对象，代表本次请求返回的实际短剧内容列表；若无数据则为 nil 或空数组。
 */
@property (nonatomic, strong, nullable) NSArray<AUIShortPlaylistInfo *> *data;

/**
 * @brief 初始化方法：从字典解析。
 *
 * 将网络返回的原始 JSON 字典转换为 AUIShortPlayListResponse 对象，自动解析嵌套的 data 列表。
 *
 * @param dict 原始响应字典，应包含 code、message、data 等字段。
 * @return 返回初始化后的实例；若 dict 无效则返回 nil。
 */
- (instancetype)initWithDict:(NSDictionary *)dict;

/**
 * @brief 转为字典（用于调试或序列化）。
 *
 * 将当前对象转换为可打印或可传输的 NSDictionary，便于日志输出、缓存或二次处理。
 *
 * @return 返回包含所有属性的字典，空值字段将被转换为空字符串或默认值以保证结构完整。
 */
- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END
