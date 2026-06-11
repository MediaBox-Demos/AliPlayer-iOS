//
//  AUIShortDramaListViewController.h
//  AUIPlayer
//
//  Created by keria on 2024/11/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


/**
 * @class AUIShortDramaListViewController
 *
 * @brief 该类用于短剧剧场场景，显示推荐和详情 TAB
 */
@interface AUIShortDramaListViewController : UIViewController

/**
 * @brief 设置获取剧集信息的 URL。
 *
 * @param dramaInfoURL 获取剧集信息的 URL 字符串。
 */
+ (void)setDramaInfoURL:(NSString *)dramaInfoURL;

@end

NS_ASSUME_NONNULL_END
