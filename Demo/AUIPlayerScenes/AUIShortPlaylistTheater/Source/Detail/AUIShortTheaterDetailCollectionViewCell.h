//
//  AUIShortTheaterDetailCollectionViewCell.h
//  AUIPlayer
//
//  Created by keria on 2024/11/7.
//

#import <UIKit/UIKit.h>
#import "AUIShortPlaylistInfo.h"
#import <AUIFoundation/AUIFoundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class AUIShortTheaterDetailCollectionViewCell
 *
 * @brief 该类用于短剧剧场场景-剧场页，显示每个短剧的封面及其标题信息。
 */
@interface AUIShortTheaterDetailCollectionViewCell : UICollectionViewCell

/**
 * @brief 使用短剧剧集信息来配置单元格。
 *
 * @param info 包含短剧剧集信息的 AUIShortPlaylistInfo    对象。
 */
- (void)configureWithPlaylistInfo:(AUIShortPlaylistInfo *)info;

@end

NS_ASSUME_NONNULL_END
