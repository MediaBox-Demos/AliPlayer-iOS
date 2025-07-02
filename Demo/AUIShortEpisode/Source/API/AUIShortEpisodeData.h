//
//  AUIShortEpisodeData.h
//  AUIShortEpisode
//
//  Created by Bingo on 2023/9/17.
//

#import <UIKit/UIKit.h>
#import "AUIVideoInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIShortEpisodeData : NSObject

@property (nonatomic, copy) NSString *eid;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray<AUIVideoInfo *> *list;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

