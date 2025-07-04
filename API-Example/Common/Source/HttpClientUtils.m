//
//  HttpClientUtils.m
//  Common
//
//  Created by 叶俊辉 on 2025/7/3.
//

#import "HttpClientUtils.h"

@implementation HttpClientUtils

- (void)fetchPlayAuthWithVideoId:(NSString *)requesturl videoId:(NSString *)videoId completion:(void (^)(NSString *playAuth, NSError *error))completion {
    NSString *urlString = [NSString stringWithFormat:@"%@%@", requesturl, videoId];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error fetching data: %@", error.localizedDescription);
            completion(nil, error);
            return;
        }
        if (data) {
            NSError *jsonError;
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            if (jsonError) {
                NSLog(@"Error parsing JSON: %@", jsonError.localizedDescription);
                completion(nil, jsonError);
                return;
            }
            // 从 JSON 中提取 playAuth
            NSDictionary *dataDict = jsonResponse[@"data"];
            NSString *playAuth = dataDict[@"playAuth"];
            completion(playAuth, nil);
        } else {
            NSLog(@"No data returned");
            completion(nil, nil); // No data error
        }
    }];
    [dataTask resume];
}

@end

