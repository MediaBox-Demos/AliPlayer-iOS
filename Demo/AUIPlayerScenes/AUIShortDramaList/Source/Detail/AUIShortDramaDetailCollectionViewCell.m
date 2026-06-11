//
//  AUIShortDramaDetailCollectionViewCell.m
//  AUIPlayer
//
//  Created by keria on 2024/11/7.
//

#import "AUIShortDramaDetailCollectionViewCell.h"
#import <SDWebImage/SDWebImage.h>

@interface AUIShortDramaDetailCollectionViewCell ()

// 剧集封面图
@property (nonatomic, strong) UIImageView *coverImageView;

// 剧集标题标签
@property (nonatomic, strong) UILabel *titleLabel;

// 剧集集数标签
@property (nonatomic, strong) UILabel *totalLabel;

@end

@implementation AUIShortDramaDetailCollectionViewCell

#pragma mark - LifeCycle

// 自定义初始化方法
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 初始化并配置剧集封面图
        self.coverImageView = [[UIImageView alloc] init];
        self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.coverImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.coverImageView];
        
        // 初始化并配置标题标签
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        self.titleLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.titleLabel];
        
        // 初始化并配置集数标签
        self.totalLabel = [[UILabel alloc] init];
        self.totalLabel.font = [UIFont systemFontOfSize:12];
        self.totalLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.totalLabel];
    }
    return self;
}

#pragma mark - View Layout

// 布局子视图
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width;
    self.coverImageView.frame = CGRectMake(0, 0, width, 160);
    self.titleLabel.frame = CGRectMake(0, CGRectGetMaxY(self.coverImageView.frame), width, 20);
    self.totalLabel.frame = CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), width, 20);
}

#pragma mark - Data

// 使用短剧剧集信息来配置单元格
- (void)configureWithDramaInfo:(AUIShortDramaInfo *)info {
    // 加载封面图像并设置标题和总集数
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:info.cover] placeholderImage:nil];
    self.titleLabel.text = info.title;
    self.totalLabel.text = [NSString stringWithFormat:AVGetString(@"Total %lu episodes", @"AUIShortDramaList"), (unsigned long)info.dramas.count];
}

@end
