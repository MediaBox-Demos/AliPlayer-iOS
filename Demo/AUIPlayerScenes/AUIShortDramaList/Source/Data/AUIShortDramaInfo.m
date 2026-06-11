//
//  AUIDramaInfo.m
//  AUIPlayer
//
//  Created by keria on 2024/11/7.
//

#import "AUIShortDramaInfo.h"

@implementation AUIShortDramaInfo

// 初始化方法，用给定的字典来设置对象的属性。
- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        // 从字典中提取值并赋给属性
        _dramaId = [dict[@"dramaId"] integerValue];
        _title = dict[@"title"];
        _cover = dict[@"cover"];
        
        NSDictionary *firstDramaDict = dict[@"drama"];
        if (firstDramaDict) {
            _firstDrama = [[AUIShortVideoInfo alloc] initWithDict:firstDramaDict];
        }
        
        NSArray *dramasArray = dict[@"dramas"];
        _dramas = [NSMutableArray array];
        for (NSDictionary *dramaDict in dramasArray) {
            AUIShortVideoInfo *videoInfo = [[AUIShortVideoInfo alloc] initWithDict:dramaDict];
            [_dramas addObject:videoInfo];
        }
    }
    return self;
}

// 返回对象的字符串描述
- (NSString *)description {
    return [NSString stringWithFormat:@"AUIShortDramaInfo {dramaId: %ld, title: %@, cover: %@, firstDrama: %@, dramas: %@}",
                                      (long)_dramaId, _title, _cover, _firstDrama, _dramas];
}

@end
