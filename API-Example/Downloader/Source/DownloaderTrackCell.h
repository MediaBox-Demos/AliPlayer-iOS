//
//  DownloaderTrackCell.h
//  Downloader
//
//  Created by 叶俊辉 on 2025/6/26.
//

#import <AliyunPlayer/AliyunPlayer.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DownloaderTrackCell : UITableViewCell

- (void)configureWithTrackInfo:(AVPTrackInfo *)trackInfo isSelected:(BOOL)selected;

@end

NS_ASSUME_NONNULL_END
