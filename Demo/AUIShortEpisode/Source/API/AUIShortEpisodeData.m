//
//  AUIShortEpisodeData.m
//  AUIShortEpisode
//
//  Created by Bingo on 2023/9/17.
//

#import "AUIShortEpisodeData.h"

@implementation AUIShortEpisodeData

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.eid = [dict objectForKey:@"id"];
        self.title = [dict objectForKey:@"title"];
        NSMutableArray *list = [NSMutableArray array];
        NSArray<NSDictionary *> *datas = [dict objectForKey:@"list"];
        [datas enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            AUIVideoInfo *info = [[AUIVideoInfo alloc] initWithDict:obj];
            info.uid = NSUUID.UUID.UUIDString;
            [list addObject:info];
        }];
        self.list = list;
    }
    return self;
}

@end

