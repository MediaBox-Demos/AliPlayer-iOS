//
//  DownloaderTrackCell.m
//  Downloader
//
//  Created by 叶俊辉 on 2025/6/26.
//

#import "DownloaderTrackCell.h"

@interface DownloaderTrackCell ()

@property (nonatomic, strong) UILabel *qualityLabel;
@property (nonatomic, strong) UILabel *sizeLabel;
@property (nonatomic, strong) UILabel *bitrateLabel;
@property (nonatomic, strong) UIImageView *checkmarkImageView;

@end

@implementation DownloaderTrackCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    // 清晰度标签
    self.qualityLabel = [[UILabel alloc] init];
    self.qualityLabel.font = [UIFont boldSystemFontOfSize:16];
    self.qualityLabel.textColor = [UIColor blackColor];
    self.qualityLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.qualityLabel];

    // 文件大小标签
    self.sizeLabel = [[UILabel alloc] init];
    self.sizeLabel.font = [UIFont systemFontOfSize:14];
    self.sizeLabel.textColor = [UIColor systemGrayColor];
    self.sizeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.sizeLabel];

    // 码率标签
    self.bitrateLabel = [[UILabel alloc] init];
    self.bitrateLabel.font = [UIFont systemFontOfSize:12];
    self.bitrateLabel.textColor = [UIColor systemGray2Color];
    self.bitrateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.bitrateLabel];

    // 选中标记
    self.checkmarkImageView = [[UIImageView alloc] init];
    self.checkmarkImageView.image = [UIImage systemImageNamed:@"checkmark.circle.fill"];
    self.checkmarkImageView.tintColor = [UIColor systemBlueColor];
    self.checkmarkImageView.hidden = YES;
    self.checkmarkImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.checkmarkImageView];

    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        // 清晰度标签
        [self.qualityLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor
                                                        constant:16],
        [self.qualityLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor
                                                    constant:8],

        // 文件大小标签
        [self.sizeLabel.leadingAnchor constraintEqualToAnchor:self.qualityLabel.leadingAnchor],
        [self.sizeLabel.topAnchor constraintEqualToAnchor:self.qualityLabel.bottomAnchor
                                                 constant:4],

        // 码率标签
        [self.bitrateLabel.leadingAnchor constraintEqualToAnchor:self.qualityLabel.leadingAnchor],
        [self.bitrateLabel.topAnchor constraintEqualToAnchor:self.sizeLabel.bottomAnchor
                                                    constant:2],
        [self.bitrateLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor
                                                       constant:-8],

        // 选中标记
        [self.checkmarkImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor
                                                               constant:-16],
        [self.checkmarkImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [self.checkmarkImageView.widthAnchor constraintEqualToConstant:24],
        [self.checkmarkImageView.heightAnchor constraintEqualToConstant:24]
    ]];
}

- (void)configureWithTrackInfo:(AVPTrackInfo *)trackInfo isSelected:(BOOL)selected {
    // 设置清晰度
    self.qualityLabel.text = trackInfo.trackDefinition ?: @"未知清晰度";

    // 设置文件大小
    if (trackInfo.vodFileSize && trackInfo.vodFileSize > 0) {
        self.sizeLabel.text = [NSString stringWithFormat:@"大小: %lld", trackInfo.vodFileSize];
    } else {
        self.sizeLabel.text = @"大小: 未知";
    }

    // 设置码率
    if (trackInfo.trackBitrate > 0) {
        self.bitrateLabel.text = [NSString stringWithFormat:@"码率: %ld kbps", (long)trackInfo.trackBitrate];
    } else {
        self.bitrateLabel.text = @"码率: 未知";
    }

    // 设置选中状态
    self.checkmarkImageView.hidden = !selected;
    self.backgroundColor = selected ? [UIColor systemBlueColor] : [UIColor clearColor];
}

@end
