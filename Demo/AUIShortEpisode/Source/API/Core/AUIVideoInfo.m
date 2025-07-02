//
//  AUIVideoInfo.m
//  AUIShortEpisode
//
//  Created by zzy on 2022/5/25.
//

#import "AUIVideoInfo.h"

@implementation AUIVideoInfo

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.videoId = [[dict objectForKey:@"videoId"] intValue];
        self.url = [dict objectForKey:@"url"];
        self.duration = (NSTimeInterval)([[dict objectForKey:@"videoDuration"] longValue] / 1000.0);
        self.coverUrl = [dict objectForKey:@"coverUrl"];
        self.author = [dict objectForKey:@"author"];
        self.title = [dict objectForKey:@"title"];
        self.videoPlayCount = [[dict objectForKey:@"videoPlayCount"] intValue];
        self.likeCount = [[dict objectForKey:@"likeCount"] intValue];
        self.isLiked = [[dict objectForKey:@"isLiked"] boolValue];
        self.commentCount = [[dict objectForKey:@"commentCount"] intValue];
        self.shareCount = [[dict objectForKey:@"shareCount"] intValue];
    }
    return self;
}

@end
