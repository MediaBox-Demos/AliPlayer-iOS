//
//  AUIShortDramaListDataManager.m
//  AUIPlayer
//
//  Created by keria on 2024/11/7.
//

#import "AUIShortDramaListDataManager.h"
#import <AFNetworking/AFNetworking.h>

@implementation AUIShortDramaListDataManager

// 请求短剧剧集信息列表
+ (void)requestDramaInfoList:(NSString *)url completed:(DramaInfoListRequestBlock)completed {
    // 创建 AFNetworking 会话管理器
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // 发起 GET 请求
    [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Response: %@", responseObject);
        
        // 检查 responseObject 是否为 NSArray 类型
        if (![responseObject isKindOfClass:[NSArray class]]) {
            // 如果数据格式不正确，通过 completed block 返回错误
            if (completed) {
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                                     code:NSURLErrorCannotParseResponse
                                                 userInfo:@{NSLocalizedDescriptionKey: @"数据格式错误"}];
                completed(nil, error);
            }
            return;
        }
        
        // 将字典数组转换为剧集信息模型数组
        NSArray<NSDictionary *> *responseArray = (NSArray<NSDictionary *> *)responseObject;
        NSMutableArray<AUIShortDramaInfo *> *dramaInfoArray = [NSMutableArray arrayWithCapacity:responseArray.count];
        
        for (NSDictionary *dict in responseArray) {
            // 初始化 AUIShortDramaInfo 模型对象并添加到数组中
            AUIShortDramaInfo *dramaInfo = [[AUIShortDramaInfo alloc] initWithDict:dict];
            [dramaInfoArray addObject:dramaInfo];
        }
        
        // 通过 completed block 返回成功结果
        if (completed) {
            completed([dramaInfoArray copy], nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Failed to request data: %@", error);
        
        // 请求失败时，通过 completed block 返回错误
        if (completed) {
            completed(nil, error);
        }
    }];
}

// 从短剧剧集列表中提取每个短剧的第一个视频信息。
+ (NSMutableArray<AUIShortVideoInfo *> *)getFirstDramasFromDramaInfoList:(NSArray<AUIShortDramaInfo *> *)dramaInfoList {
    // 确认新数据非空且有内容
    if (!dramaInfoList || dramaInfoList.count == 0) {
        return nil;
    }
    
    NSMutableArray<AUIShortVideoInfo *> *videoInfoList = [NSMutableArray array];
    for (AUIShortDramaInfo *dramaInfo in dramaInfoList) {
        // 检查每个短剧信息的有效性，并获取第一个视频信息
        if (dramaInfo && dramaInfo.firstDrama) {
            [videoInfoList addObject:dramaInfo.firstDrama];
        }
    }
    
    // 返回包含第一个视频信息的数组
    return videoInfoList;
}

// 根据视频信息获取对应的短剧剧集信息。
+ (AUIShortDramaInfo *)getDramaInfoFromVideoInfo:(AUIShortVideoInfo *)videoInfo dramaInfoList:(NSArray<AUIShortDramaInfo *> *)dramaInfoList {
    // 确保输入有效
    if (!videoInfo || !videoInfo.url || !dramaInfoList || dramaInfoList.count == 0) {
        return nil;
    }
    
    // 遍历短剧信息列表寻找匹配的短剧
    for (AUIShortDramaInfo *dramaInfo in dramaInfoList) {
        // 检查短剧信息和短剧的第一个视频信息的有效性
        if (dramaInfo && dramaInfo.firstDrama) {
            // 比较视频的 URL 并返回匹配的短剧信息
            if ([videoInfo.url isEqualToString:dramaInfo.firstDrama.url]) {
                return dramaInfo;
            }
        }
    }
    
    // 如果未找到匹配的短剧信息，则返回 nil
    return nil;
}

@end
