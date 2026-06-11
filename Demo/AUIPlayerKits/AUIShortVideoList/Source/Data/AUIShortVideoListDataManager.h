//
//  AUIShortVideoListDataManager.h
//  AUIShortVideoList
//
//  Created by Bingo on 2023/9/17.
//

#import <UIKit/UIKit.h>
#import "AUIShortVideoInfo.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^VideoInfoListRequestBlock)(NSArray<AUIShortVideoInfo *> * _Nullable data, NSError * _Nullable error);

/**
 * @class AUIShortVideoListDataManager
 *
 * @brief 数据管理器类，用于请求和处理短视频信息列表。通过网络请求获取视频列表数据，并将数据解析成模型，处理完成后返回给调用方。
 */
@interface AUIShortVideoListDataManager : NSObject

/**
 * @brief 请求视频信息列表
 *
 * @param url 视频信息列表的请求 URL。
 * @param completed 请求完成后的回调，包含获取的数据数组或错误信息。
 */
+ (void)requestVideoInfoList:(NSString *)url completed:(VideoInfoListRequestBlock)completed;

@end

NS_ASSUME_NONNULL_END

