//
//  AUIShortDramaRecommendViewController.h
//  AUIPlayer
//
//  Created by keria on 2024/11/6.
//

#import <UIKit/UIKit.h>
#import "AUIShortDramaInfo.h"
#import "AUIShortVideoListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIShortDramaRecommendViewController : UIViewController

/**
 * @brief 初始化方法，通过传入初始短剧剧集数据来创建实例。
 *
 * @param data 初始的短剧剧集数据列表。
 *
 * @return AUIShortDramaRecommendViewController 实例。
 */
- (instancetype)initWithData:(NSArray<AUIShortDramaInfo *> * _Nullable)data;

/**
 * @brief 初始化方法，通过传入数据请求代理来创建实例。
 *
 * @param dataProviderDelegate 通过代理请求更多数据。
 *
 * @return AUIShortDramaRecommendViewController 实例。
 */
- (instancetype)initWithDataProvider:(id<AUIShortVideoDataProviderDelegate> _Nullable)dataProviderDelegate;

/**
 * @brief 初始化方法，通过传入初始数据和数据请求代理来创建实例。
 *
 * @param data 初始的短剧剧集数据列表。
 * @param dataProviderDelegate 通过代理请求更多数据。
 *
 * @return AUIShortDramaRecommendViewController 实例。
 */
- (instancetype)initWithData:(NSArray<AUIShortDramaInfo *> * _Nullable)data
                dataProvider:(id<AUIShortVideoDataProviderDelegate> _Nullable)dataProviderDelegate;

/**
 * @brief 追加新的短剧剧集数据到当前列表中。
 *
 * @param dramaInfoList 新的短剧剧集数据列表，可空。
 */
- (void)appendDramaInfoList:(NSArray<AUIShortDramaInfo *> * _Nullable)dramaInfoList;

@end

NS_ASSUME_NONNULL_END
