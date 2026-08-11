//
//  AUIShortPlayListDetailResponse.m
//  AUIPlayer
//
//  Created by aqi on 2025/11/6.
//

#import "AUIShortPlayListDetailResponse.h"
#import "AUIShortPlaylistInfo.h"

// 在 .m 文件顶部或公共头文件中定义
#define SafeValue(value) ({ \
    __typeof__(value) _v = (value); \
    (_v == [NSNull null] || _v == nil) ? nil : _v; \
})


@implementation AUIShortPlayListDetailResponse

+ (instancetype)responseObjectWithDictionary:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    AUIShortPlayListDetailResponse *response = [[AUIShortPlayListDetailResponse alloc] init];
    
    response.code = SafeValue(dict[@"code"]);
    response.httpCode = SafeValue(dict[@"httpCode"]);
    response.success = SafeValue(dict[@"success"]);
    response.message = SafeValue(dict[@"message"]);
    response.requestId = SafeValue(dict[@"requestId"]);
    
    id dataObj = dict[@"data"];
    if ([dataObj isKindOfClass:[NSDictionary class]] && dataObj) {
        response.data = [AUIShortPlaylistInfo responseObjectWithDictionary:dataObj];
    }
    
    return response;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (self.code != nil) dict[@"code"] = self.code;
    if (self.httpCode != nil) dict[@"httpCode"] = self.httpCode;
    if (self.success != nil) dict[@"success"] = self.success;
    if (self.message != nil) dict[@"message"] = self.message;
    if (self.requestId != nil) dict[@"requestId"] = self.requestId;
    if (self.data != nil) dict[@"data"] = [self.data toDictionary];
    
    return [dict copy];
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        _code = [coder decodeObjectOfClass:[NSString class] forKey:@"code"];
        _httpCode = [coder decodeObjectOfClass:[NSNumber class] forKey:@"httpCode"];
        _success = [coder decodeObjectOfClass:[NSNumber class] forKey:@"success"];
        _message = [coder decodeObjectOfClass:[NSString class] forKey:@"message"];
        _requestId = [coder decodeObjectOfClass:[NSString class] forKey:@"requestId"];
        _data = [coder decodeObjectOfClass:[AUIShortPlaylistInfo class] forKey:@"data"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.code forKey:@"code"];
    [coder encodeObject:self.httpCode forKey:@"httpCode"];
    [coder encodeObject:self.success forKey:@"success"];
    [coder encodeObject:self.message forKey:@"message"];
    [coder encodeObject:self.requestId forKey:@"requestId"];
    [coder encodeObject:self.data forKey:@"data"];
}

@end
