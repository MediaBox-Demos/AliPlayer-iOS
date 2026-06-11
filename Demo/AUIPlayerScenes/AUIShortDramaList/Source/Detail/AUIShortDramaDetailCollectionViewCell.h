//
//  AUIShortDramaDetailCollectionViewCell.h
//  AUIPlayer
//
//  Created by keria on 2024/11/7.
//

#import <UIKit/UIKit.h>
#import "AUIShortDramaInfo.h"
#import <AUIFoundation/AUIFoundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class AUIShortDramaDetailCollectionViewCell
 *
 * @brief 该类用于短剧剧场场景-剧场页，显示每个短剧的封面及其标题信息。
 */
@interface AUIShortDramaDetailCollectionViewCell : UICollectionViewCell

/**
 * @brief 使用短剧剧集信息来配置单元格。
 *
 * @param info 包含短剧剧集信息的 AUIShortDramaInfo 对象。
 */
- (void)configureWithDramaInfo:(AUIShortDramaInfo *)info;

@end

NS_ASSUME_NONNULL_END
