//
//  AUIShortVideoListCollectionPanel.h
//  Pods
//
//  Created by wyq on 2024/11/6.
//

#import "AUIFoundation.h"
#import <UIKit/UIKit.h>
#import "AUIShortVideoInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIShortVideoListCollectionPanel : AVBaseCollectionControllPanel

@property (nonatomic, copy) void(^onVideoSelectedBlock)(AUIShortVideoListCollectionPanel *sender, AUIShortVideoInfo *videoInfo);

- (instancetype)initWithFrame:(CGRect)frame withVideoInfoList:(NSArray<AUIShortVideoInfo *> *)videoInfoList withPlaying:(AUIShortVideoInfo *)videoInfo;

+ (void)setPanelHeight:(NSArray<AUIShortVideoInfo *> *)videoInfoList max:(CGFloat)max;

@end

NS_ASSUME_NONNULL_END
