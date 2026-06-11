//
//  AUIShortVideoListListPanel.h
//  AUIShortVideoList
//
//  Created by Bingo on 2023/9/17.
//

#import "AUIFoundation.h"
#import "AUIShortVideoInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIShortVideoListListPanel : AVBaseCollectionControllPanel

@property (nonatomic, copy) void(^onVideoSelectedBlock)(AUIShortVideoListListPanel *sender, AUIShortVideoInfo *videoInfo);
- (instancetype)initWithFrame:(CGRect)frame withVideoInfoList:(NSArray<AUIShortVideoInfo *> *)videoInfoList withPlaying:(AUIShortVideoInfo *)videoInfo;

+ (void)setPanelHeight:(NSArray<AUIShortVideoInfo *> *)videoInfoList max:(CGFloat)max;

@end

NS_ASSUME_NONNULL_END
