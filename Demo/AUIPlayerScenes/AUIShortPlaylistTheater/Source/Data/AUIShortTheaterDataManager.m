//
//  AUIShortTheaterDataManager.m
//  AUIPlayer
//
//  Created by keria on 2024/11/7.
//

#import "AUIShortTheaterDataManager.h"
#import "AUIShortPlayListResponse.h"
#import "AUIShortPlayListDetailResponse.h"
#import <AFNetworking/AFNetworking.h>

@implementation AUIShortTheaterDataManager

// 请求短剧剧集信息列表
+ (void)requestPlayListInfoList:(NSString *)url completed:(PlaylistInfoListRequestBlock)completed {
    // 创建 AFNetworking 会话管理器
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer]; // 自动设置 Content-Type 为 application/json
    manager.responseSerializer =  [AFJSONResponseSerializer serializer];
    NSLog(@"[requestPlayListInfoList] %@",url);
    // 发起 POST 请求
    [manager POST:url parameters:@{
        @"pageNo": @"1",
         @"pageSize": @"10",
         @"sortBy": @"Asc"
    } headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task,
                                                                       id  _Nullable responseObject) {
        NSLog(@"Response: %@",
              responseObject);
        
        // 检查 responseObject 是否为 NSArray 类型
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            // 如果数据格式不正确，通过 completed block 返回错误
            if (completed) {
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                                     code:NSURLErrorCannotParseResponse
                                                 userInfo:@{NSLocalizedDescriptionKey: @"数据格式错误"}];
                completed(nil,
                          error);
            }
            return;
        }
        
        NSDictionary* responseDictionary =  (NSDictionary*) responseObject;
        
        AUIShortPlayListResponse* playlistResponse = [[AUIShortPlayListResponse alloc]initWithDict:responseDictionary];
        if (playlistResponse && playlistResponse.data && playlistResponse.data.count > 0) {
            if (completed){
                completed([playlistResponse.data copy],
                          nil);
            }
            return;
        }
        
        
        if (completed) {
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                                 code:NSURLErrorCannotParseResponse
                                             userInfo:@{NSLocalizedDescriptionKey: @"数据异常错误"}];
            completed(nil,
                      error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task,
                NSError * _Nonnull error) {
        NSLog(@"Failed to request data: %@",
              error);
        
        // 请求失败时，通过 completed block 返回错误
        if (completed) {
            completed(nil,
                      error);
        }
    }];
}

// 从短剧剧集列表中提取每个短剧的第一个视频信息。
+ (NSMutableArray<AUIShortVideoInfo *> *)getFirstVideoFromPlayListInfos:(NSArray<AUIShortPlaylistInfo *> *)playListInfos {
    // 确认新数据非空且有内容
    if (!playListInfos || playListInfos.count == 0) {
        return nil;
    }
    
    NSMutableArray<AUIShortVideoInfo *> *videoInfoList = [NSMutableArray array];
    for (AUIShortPlaylistInfo *playlistInfo in playListInfos) {
        // 检查每个短剧信息的有效性，并获取第一个视频信息
        if (playlistInfo && playlistInfo.playlistVideos && playlistInfo.playlistVideos.count > 0) {
            [videoInfoList addObject:playlistInfo.playlistVideos[0]];
        }
    }
    
    // 返回包含第一个视频信息的数组
    return videoInfoList;
}

// 根据视频信息获取对应的短剧剧集信息。
+ (AUIShortPlaylistInfo *)getPlayListFromVideoInfo:(AUIShortVideoInfo *)videoInfo playlistInfos:(NSArray<AUIShortPlaylistInfo *> *)playlistInfos {
    // 确保输入有效
    if (!videoInfo || !playlistInfos || playlistInfos.count == 0) {
        return nil;
    }
    
    // 遍历短剧信息列表寻找匹配的短剧
    for (AUIShortPlaylistInfo *playlistInfo in playlistInfos) {
        // 检查短剧信息和短剧的第一个视频信息的有效性
        if (playlistInfo && playlistInfo.playlistVideos && playlistInfo.playlistVideos.count > 0) {
            // 比较视频的 URL 并返回匹配的短剧信息
            if ([videoInfo.playlistId isEqualToString:playlistInfo.playlistVideos[0].playlistId]) {
                return playlistInfo;
            }
        }
    }
    
    // 如果未找到匹配的短剧信息，则返回 nil
    return nil;
}


+(void)getPlayListDetail:(AUIShortVideoInfo *)videoInfo completed:(PlaylistInfoDetailRequestBlock)complete{
    
    NSString *baseURL = [NSString stringWithFormat:@"%@/appServer/getPlaylistInfo",DEFAULT_APP_SERVER_URL];
    
    NSDictionary *params = @{@"playListId": videoInfo.playlistId};

    // 创建 manager（建议复用，此处为演示）
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];// 若返回 JSON，可用 AFJSONResponseSerializer

    // 发起 POST 请求（body 为空）
    [manager POST:baseURL
      parameters:params
         headers:nil
         progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task,
                   id  _Nullable responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            NSDictionary* dict = (NSDictionary *)responseObject;
            
            AUIShortPlayListDetailResponse* detailResponse = [AUIShortPlayListDetailResponse responseObjectWithDictionary:dict];
            
            if (detailResponse) {
                AUIShortPlaylistInfo* info = detailResponse.data;
                if (info && info.playlistVideos && info.playlistVideos.count > 0){
                    info.playlistVideos = [self sortVideoInfoBySerialNum:info];
                    complete(info,
                             nil);
                    return;
                }
            }
        }
        
        if (complete) {
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                                 code:NSURLErrorCannotParseResponse
                                             userInfo:@{NSLocalizedDescriptionKey: @"数据格式错误"}];
            complete(nil,
                      error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task,
                NSError * _Nonnull error) {
        NSLog(@"Failed to request data: %@",
              error);
        
        // 请求失败时，通过 completed block 返回错误
        if (complete) {
            complete(nil,
                      error);
        }
    }];
}


+ (NSArray<AUIShortVideoInfo *> *) sortVideoInfoBySerialNum:(AUIShortPlaylistInfo *)playlistInfo{
    // 假设 videos 是 NSArray<AUIShortVideoInfo *> *
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"seriesNum"
                                                                     ascending:YES
                                                                      selector:@selector(compare:)];
    NSArray<AUIShortVideoInfo *> *sortedVideos = [playlistInfo.playlistVideos sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    return sortedVideos;
}



@end
