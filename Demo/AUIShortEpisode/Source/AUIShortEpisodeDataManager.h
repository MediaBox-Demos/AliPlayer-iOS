//
//  AUIShortEpisodeDataManager.h
//  AUIShortEpisode
//
//  Created by Bingo on 2023/9/17.
//

#import <UIKit/UIKit.h>
#import "AUIShortEpisodeData.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIShortEpisodeDataManager : NSObject

+ (void)fetchData:(NSString *)eid completed:(void(^)(AUIShortEpisodeData * _Nullable data, NSError * _Nullable error))completed;

@end

NS_ASSUME_NONNULL_END

