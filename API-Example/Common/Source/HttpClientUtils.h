//
//  HttpClientUtils.h
//  Common
//
//  Created by 叶俊辉 on 2025/7/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HttpClientUtils : NSObject
- (void)fetchPlayAuthWithVideoId:(NSString *)requesturl videoId:(NSString *)videoId completion:(void (^)(NSString *playAuth, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
