//
//  AUIShortVideoListDataManager.m
//  AUIShortVideoList
//
//  Created by Bingo on 2023/9/17.
//

#import "AUIShortVideoListDataManager.h"
#import "AUIShortVideoListConstants.h"
#import <AFNetworking/AFNetworking.h>
#import "AUIShortVideoAdvertisementCell.h"

@implementation AUIShortVideoListDataManager

// 请求视频信息列表
+ (void)requestVideoInfoList:(NSString *)url completed:(VideoInfoListRequestBlock)completed {
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
        
        // 将字典数组转换为视频信息模型数组
        NSArray<NSDictionary *> *responseArray = (NSArray<NSDictionary *> *)responseObject;
        NSMutableArray<AUIShortVideoInfo *> *videoInfoArray = [NSMutableArray arrayWithCapacity:responseArray.count];
        int count = 0;
        for (NSDictionary *dict in responseArray) {
            // 初始化 AUIShortVideoInfo 模型对象并添加到数组中
            AUIShortVideoInfo *videoInfo = [[AUIShortVideoInfo alloc] initWithDict:dict];
            [videoInfoArray addObject:videoInfo];
            // 广告页添加:每隔5个视频添加一次
            if ([AUIShortVideoListConstants enableAdvertisementPage]){
                if (count < 4){
                    count += 1;
                }
                else {
                    AUIShortVideoInfo *videoInfo = [[AUIShortVideoInfo alloc]init];
                    videoInfo.type = AVCollectionViewCellAdvertisement;
                    [videoInfoArray addObject:videoInfo];
                    count = 0;
                }
            }
            
        }
        
        // 通过 completed block 返回成功结果
        if (completed) {
            completed([videoInfoArray copy], nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Failed to request data: %@", error);
        
        // 请求失败时，通过 completed block 返回错误
        if (completed) {
            completed(nil, error);
        }
    }];
}

@end
