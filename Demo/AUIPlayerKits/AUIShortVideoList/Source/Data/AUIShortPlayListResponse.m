//
//  UIShortPlayListResponse.m
//  AUIPlayer
//
//  Created by aqi on 2025/11/10.
//

#import "AUIShortPlayListResponse.h"
#import "AUIShortPlaylistInfo.h"

@implementation AUIShortPlayListResponse

/**
 * @brief 使用字典初始化 AUIShortPlayListResponse 实例（JSON 反序列化）。
 *
 * 该方法将网络接口返回的原始 JSON 字典解析为结构化的响应对象，自动处理嵌套的短剧列表（data 字段），
 * 并安全转换基础类型（如布尔值、数字）为对应的 Objective-C 对象。
 *
 * @param dict 包含完整响应数据的字典，通常来自 AFNetworking 或 URLSession 的 JSON 解析结果。
 * @return 返回初始化后的 AUIShortPlayListResponse 实例；即使 data 为空也会返回有效对象（非 nil）。
 */
- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _code = dict[@"code"];
        _httpCode = dict[@"httpCode"];     // JSON number → NSNumber
        _success = dict[@"success"];       // JSON boolean → NSNumber
        _message = dict[@"message"];
        _requestId = dict[@"requestId"];
        
        // 解析 data 数组：将每个短剧字典转换为 AUIShortPlaylistInfo 对象
        NSArray *dataArray = dict[@"data"];
        NSMutableArray *playlistInfos = [NSMutableArray array];
        if ([dataArray isKindOfClass:[NSArray class]]) {
            for (NSDictionary *playlistDict in dataArray) {
                AUIShortPlaylistInfo *playlistInfo = [AUIShortPlaylistInfo responseObjectWithDictionary:playlistDict];
                if (playlistInfo) {
                    [playlistInfos addObject:playlistInfo];
                }
            }
        }
        _data = [playlistInfos copy];
    }
    return self;
}

/**
 * @brief 将当前响应对象转换为字典（用于调试、日志记录或二次序列化）。
 *
 * 该方法递归地将所有属性（包括嵌套的短剧列表）转换为可序列化的 NSDictionary，
 * 仅包含非 nil 字段以保持输出简洁，并对不支持 toDictionary 的子对象发出警告。
 *
 * @return 返回一个包含有效字段的 NSMutableDictionary 副本，可用于 NSLog、缓存或转 JSON。
 */
- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (self.code != nil) dict[@"code"] = self.code;
    if (self.httpCode != nil) dict[@"httpCode"] = self.httpCode;
    if (self.success != nil) dict[@"success"] = self.success;
    if (self.message != nil) dict[@"message"] = self.message;
    if (self.requestId != nil) dict[@"requestId"] = self.requestId;
    
    // 序列化 data 列表：将每个 AUIShortPlaylistInfo 转为字典
    if (self.data != nil) {
        NSMutableArray *dataArr = [NSMutableArray array];
        for (AUIShortPlaylistInfo *playlistInfo in self.data) {
            if ([playlistInfo respondsToSelector:@selector(toDictionary)]) {
                [dataArr addObject:[playlistInfo toDictionary]];
            } else {
                NSLog(@"Warning: AUIShortPlaylistInfo does not implement -toDictionary");
            }
        }
        dict[@"data"] = [dataArr copy];
    }
    
    return [dict copy];
}

@end
