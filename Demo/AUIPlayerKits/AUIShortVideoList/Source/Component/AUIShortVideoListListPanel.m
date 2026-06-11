//
//  AUIShortVideoListListPanel.m
//  AUIShortVideoList
//
//  Created by Bingo on 2023/9/17.
//

#import "AUIShortVideoListListPanel.h"
#import "AUIShortVideoListMacro.h"
#import <SDWebImage/SDWebImage.h>

@interface AUIShortVideoListListCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *countBtn;
@property (nonatomic, strong) UIImageView *playingView;

@property (nonatomic, strong) AUIShortVideoInfo* videoInfo;

@end

@implementation AUIShortVideoListListCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _coverView = [UIImageView new];
        _coverView.contentMode = UIViewContentModeScaleAspectFill;
        _coverView.layer.cornerRadius = 4.0;
        _coverView.layer.masksToBounds = YES;
        _coverView.backgroundColor = [UIColor av_colorWithHexString:@"#23262FFF"];
        [self.contentView addSubview:_coverView];
        
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor av_colorWithHexString:@"#FCFCFDFF"];
        _titleLabel.font = AVGetRegularFont(12);
        _titleLabel.numberOfLines = 2;
        _titleLabel.text = @"";
        [self.contentView addSubview:_titleLabel];
        
        _timeLabel = [UILabel new];
        _timeLabel.textColor = [UIColor av_colorWithHexString:@"#FCFCFDFF"];
        _timeLabel.font = AVGetRegularFont(9);
        _timeLabel.text = @"00:00";
        [self.contentView addSubview:_timeLabel];
        
        _countBtn = [UIButton new];
        _countBtn.titleLabel.font = AVGetRegularFont(9);
        [_countBtn setTitleColor:[UIColor av_colorWithHexString:@"#FCFCFDFF"] forState:UIControlStateNormal];
        [_countBtn setTitle:@"12123" forState:UIControlStateNormal];
        [_countBtn setImage:AVGetImage(@"ic_list_count", @"AUIShortVideoList") forState:UIControlStateNormal];
        _countBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _countBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
        [self.contentView addSubview:_countBtn];
        
        _playingView = [UIImageView new];
        _playingView.image = AVGetImage(@"ic_list_playing", @"AUIShortVideoList");
        _playingView.hidden = YES;
        [self.contentView addSubview:_playingView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.coverView.frame = CGRectMake(20, 10, 50, 50);
    self.playingView.frame = CGRectMake(self.contentView.av_width - 20 - 18, (self.contentView.av_height - 18) / 2.0, 18, 18);
    
    CGSize titleSize = [self.titleLabel sizeThatFits:CGSizeMake(self.playingView.av_left - self.coverView.av_right - 12 - 20, 0)];
    self.titleLabel.frame = CGRectMake(self.coverView.av_right + 12, self.coverView.av_top, titleSize.width, titleSize.height);
    
    self.timeLabel.frame = CGRectMake(self.coverView.av_right + 12, self.coverView.av_bottom - 14, 40, 14);
    self.countBtn.frame = CGRectMake(self.timeLabel.av_right + 8, self.timeLabel.av_top, self.playingView.av_left - self.timeLabel.av_right - 8 - 20, 14);
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.backgroundColor = selected ? [UIColor av_colorWithHexString:@"#3A3D48FF"]: UIColor.clearColor;
    self.playingView.hidden = !selected;
}

- (void)updateVideoInfo:(AUIShortVideoInfo *)videoInfo {
    self.videoInfo = videoInfo;
    [self.coverView sd_setImageWithURL:[NSURL URLWithString:self.videoInfo.coverUrl] placeholderImage:nil];
    self.titleLabel.text = self.videoInfo.title;
//    self.timeLabel.text = [AVStringFormat formatWithDuration:self.videoInfo.duration];
//    [self.countBtn setTitle:[AVStringFormat formatWithCount:self.videoInfo.videoPlayCount] forState:UIControlStateNormal];
    
    [self setNeedsLayout];
}

@end

@interface AUIShortVideoListListPanel ()

@property (nonatomic, strong) NSMutableArray<AUIShortVideoInfo *> *videoInfoList;

@end

@implementation AUIShortVideoListListPanel

- (instancetype)initWithFrame:(CGRect)frame withVideoInfoList:(NSMutableArray<AUIShortVideoInfo *> *) videoInfoList withPlaying:(AUIShortVideoInfo *)videoInfo {
    self = [super initWithFrame:frame];
    if (self) {
        _videoInfoList = videoInfoList;
        
        self.showMenuButton = YES;
        [self.menuButton setImage:AVGetImage(@"ic_list_dimiss", @"AUIShortVideoList") forState:UIControlStateNormal];
        

        self.titleView.text = videoInfoList[0].title;
        self.titleView.av_left = 20;
        self.titleView.av_width = self.menuButton.av_left - 20 - 20;
        self.titleView.textAlignment = NSTextAlignmentLeft;
        
        [self.collectionView registerClass:AUIShortVideoListListCell.class forCellWithReuseIdentifier:AVCollectionViewCellIdentifier];
        NSInteger index = [self.videoInfoList indexOfObject:videoInfo];
        if (index >= 0 && index < self.videoInfoList.count) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionTop];
        }
    }
    return self;
}

- (void)onMenuBtnClicked:(UIButton *)sender {
    [AUIShortVideoListListPanel dismiss:self];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videoInfoList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AUIShortVideoListListCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:AVCollectionViewCellIdentifier forIndexPath:indexPath];
    [cell updateVideoInfo:self.videoInfoList[indexPath.row]];
    return cell;
}

/**
     item click event
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.onVideoSelectedBlock) {
        self.onVideoSelectedBlock(self, self.videoInfoList[indexPath.row]);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.av_width, 70.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return .0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return .0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, AVSafeBottom <= 0 ? 20 : AVSafeBottom, 0);
}

static CGFloat g_panelHeight = 200;
+ (void)setPanelHeight:(NSArray<AUIShortVideoInfo *> *)videoInfoList max:(CGFloat)max {
    g_panelHeight = MIN(videoInfoList.count * 70 + 46 + (AVSafeBottom <= 0 ? 20 : AVSafeBottom), max);
}

+ (CGFloat)panelHeight {
    return g_panelHeight;
}

@end
