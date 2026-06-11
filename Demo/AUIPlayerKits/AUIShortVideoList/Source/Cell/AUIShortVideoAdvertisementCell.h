//
//  AUIShortVideoAdvertisementCell.h
//  Pods
//
//  Created by wyq on 2024/11/11.
//
#import <UIKit/UIKit.h>

#ifndef AVCollectionViewCellAdvertisement
#define AVCollectionViewCellAdvertisement @"advertisement"
#endif


NS_ASSUME_NONNULL_BEGIN

@interface AUIShortVideoAdvertisementCell : UICollectionViewCell

@property (nonatomic, copy) void(^onBackBtnClickBlock)(AUIShortVideoAdvertisementCell *cell);

@end

NS_ASSUME_NONNULL_END
