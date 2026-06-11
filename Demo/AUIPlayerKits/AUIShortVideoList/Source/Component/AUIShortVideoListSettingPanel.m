//
//  AUIShortVideoRatePopViewController.m
//  Pods
//
//  Created by wyq on 2024/11/5.
//
#import "AUIShortVideoListSettingPanel.h"
#import "AUIShortVideoRateView.h"
#import "AUIShortVideoTrackView.h"
#import "AUIShortVideoListMacro.h"

@interface AUIShortVideoListSettingPanel()  

@property(nonatomic,strong)AUIShortVideoRateView *rateView;
@property(nonatomic,strong)AUIShortVideoTrackView *trackView;
@property(nonatomic,strong)UIView *separatorLine;
@property(nonatomic, strong) NSArray<AVPTrackInfo *> *dataArray;

@end

@implementation AUIShortVideoListSettingPanel

- (instancetype)initWithFrame:(CGRect)frame dataArray:(NSArray *)dataArray; {
    self = [super initWithFrame:frame];
    if (self) {
        _dataArray = dataArray;
        self.showMenuButton = NO;
        
        self.titleView.text =SVString(@"playback settings");
        
        __weak typeof(self) weakSelf = self;
        _rateView = [[AUIShortVideoRateView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 80)];
        _rateView.onRateChange = ^(CGFloat value) {
            NSLog(@"value:%f",value);
            [AUIShortVideoListSettingPanel dismiss:weakSelf];
            if(!weakSelf.onRateChange)return;
            weakSelf.onRateChange(value);
        };
        
        [self.contentView addSubview:_rateView];

        
        // 创建一个分割线的 UIView
        _separatorLine = [[UIView alloc] init]; // 设置分割线的位置和大小
        _separatorLine.backgroundColor = [UIColor darkGrayColor]; // 设置分割线的颜色
        
        // 将分割线添加到父视图
        [self.contentView addSubview:_separatorLine];
        
        _trackView = [[AUIShortVideoTrackView alloc]initWithFrame: CGRectMake(0, 80, self.contentView.frame.size.width, self.frame.size.height - 80) dataArray:dataArray];
        _trackView.onTrackSelect = ^(AVPTrackInfo *value) {
            if (!value)return;
            NSLog(@"onTrackSelect -> %d",value.trackBitrate);
            [AUIShortVideoListSettingPanel dismiss:weakSelf];
            if(!weakSelf.onTrackSelect)return;
            weakSelf.onTrackSelect(value);
        };
        
        [self.contentView addSubview:_trackView];
        [self layoutIfNeeded];
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    _separatorLine.frame = CGRectMake(10, 65, self.contentView.frame.size.width - 20, 1);
}

@end
