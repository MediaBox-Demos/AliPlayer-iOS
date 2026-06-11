//
//  AUIShortVideoListCollectionPanel.m
//  Pods
//
//  Created by wyq on 2024/11/6.
//

#import "AUIShortVideoListCollectionPanel.h"
#import "AUIShortVideoInfo.h"
#import "AUIShortVideoListMacro.h"
#import <SDWebImage/SDWebImage.h>


@interface AUIShortVideoListCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *uiButton;

@property (nonatomic, strong) AUIShortVideoInfo* videoInfo;

@end

@implementation AUIShortVideoListCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _uiButton =[[UILabel alloc] init];
        _uiButton.clipsToBounds = YES;
        _uiButton.layer.cornerRadius = 10;
        _uiButton.backgroundColor = UIColor.whiteColor;
        _uiButton.textColor = UIColor.blackColor;
        [self.contentView addSubview: _uiButton];
        
        NSLog(@"[init] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
    }
    return self;
}

// 释放资源的方法
- (void)dealloc {
    NSLog(@"[dealloc] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.uiButton.frame = CGRectMake(0, 0, 50, 50);
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.uiButton.backgroundColor = selected ? [UIColor av_colorWithHexString:@"#87CEEB"] : UIColor.whiteColor;
    self.uiButton.textColor = selected ? UIColor.whiteColor : UIColor.grayColor;
}

- (void)updateVideoInfo:(AUIShortVideoInfo *)videoInfo index:(NSInteger)index{
    self.videoInfo = videoInfo;
    if (!videoInfo)return;
    self.uiButton.textAlignment = NSTextAlignmentCenter;
    self.uiButton.text =[NSString stringWithFormat:@"%d",(int)index + 1];
    [self setNeedsLayout];
}


@end

@interface AUIShortVideoListCollectionPanel()

@property (nonatomic, strong) NSArray<AUIShortVideoInfo *> *videoInfoList;

@end

@implementation AUIShortVideoListCollectionPanel

- (instancetype)initWithFrame:(CGRect)frame withVideoInfoList:(NSArray *)videoInfoList withPlaying:(id)videoInfo{
    self = [super initWithFrame:frame];
    
    if (self){
        //率选非广告数据
        if (videoInfoList){
            NSMutableArray<AUIShortVideoInfo*>* array =[[NSMutableArray alloc]init];
            for (AUIShortVideoInfo* info in videoInfoList) {
                if (![info.type isEqualToString:@"advertisement"]){
                    [array addObject:info];
                }
                _videoInfoList = [array copy];
            }
        }
        
        self.showMenuButton = YES;
        [self.menuButton setImage:AVGetImage(@"ic_list_dimiss", @"AUIShortVideoList") forState:UIControlStateNormal];
        
        self.titleView.text = SVString(@"series selection");
        self.titleView.av_left = 20;
        self.titleView.av_width = self.menuButton.av_left - 20 - 20;
        self.titleView.textAlignment = NSTextAlignmentLeft;
        self.collectionView.allowsMultipleSelection = NO;
        [self.collectionView registerClass:AUIShortVideoListCollectionCell.class forCellWithReuseIdentifier:@"defaultCollectionCell"];
        NSInteger index = [self.videoInfoList indexOfObject:videoInfo];
        NSLog(@"videoListInfo : %ld",(long)_videoInfoList.count);
        if (index >= 0 && index < self.videoInfoList.count) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionTop];
        }
    }
    
    return self;
}
/**
 *     panel menu click
 */
- (void)onMenuBtnClicked:(UIButton *)sender {
    //panel dismiss
    [AUIShortVideoListCollectionPanel dismiss:self];
}

/**
 *  item cell ui setting
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AUIShortVideoListCollectionCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"defaultCollectionCell" forIndexPath:indexPath];
    [cell updateVideoInfo:self.videoInfoList[indexPath.row] index:indexPath.row];
    return cell;
}

/**
     item click event
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"选中了第 %ld 个单元格", (long)indexPath.item);
    if(self.onVideoSelectedBlock){
        self.onVideoSelectedBlock(self,self.videoInfoList[indexPath.row]);
    }
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videoInfoList.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (self.av_width) / 5; // 设置每个 cell 的宽度
    return CGSizeMake(width, 50); // 返回相同的宽高实现正方形
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 20, AVSafeBottom <= 0 ? 20 : AVSafeBottom, 0);
}


static CGFloat g_panelHeight = 200;
+ (void)setPanelHeight:(NSArray<AUIShortVideoInfo *> *)videoInfoList max:(CGFloat)max {
    // 高度需要自己实现
    g_panelHeight = MIN((videoInfoList.count / 4) * 70 + 100 + (AVSafeBottom <= 0 ? 20 : AVSafeBottom), max);
}

+ (CGFloat)panelHeight {
    return g_panelHeight;
}


@end
