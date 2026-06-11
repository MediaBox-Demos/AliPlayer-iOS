//
//  AUIShortVideoTrackView.m
//  Pods
//
//  Created by wyq on 2024/11/11.
//
#import "AUIShortVideoTrackView.h"
#import "AUIVideoTrackInfoUtil.h"
#import "AUIShortVideoListMacro.h"

@interface AUIShortVideoTrackView ()

@property (nonatomic, strong) UILabel *trackLabel;

@property (nonatomic, strong) NSArray<AVPTrackInfo *> *dataArray;

@end

@implementation AUIShortVideoTrackView

- (instancetype)initWithFrame:(CGRect)frame dataArray:(NSArray<AVPTrackInfo *> *)dataArray{
    self = [super initWithFrame:frame];
    
    if (self){
        _trackLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 40)];
        _trackLabel.text = SVString(@"video quality");
        _trackLabel.textColor = [UIColor whiteColor];
        _trackLabel.font = [UIFont systemFontOfSize:14];
        
        
        [self addSubview:_trackLabel];
        [self adjustLabelWidth:_trackLabel withText:_trackLabel.text andFont: _trackLabel.font];
        
        _groupView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [_groupView setScrollEnabled: YES];
        [_groupView setDirectionalLockEnabled: NO];
        [self addSubview:_groupView];
       
        [self setData:dataArray];
    }
    
    return self;
}


- (void)setData:(NSArray<AVPTrackInfo *> *)dataArray {
    __weak typeof(self) weakSelf = self;
    if (dataArray && dataArray.count >0){
        dispatch_async(dispatch_get_main_queue(),^{
            NSMutableArray<AVPTrackInfo *>* track = [[NSMutableArray alloc]init];
            if (dataArray){
                for(NSInteger i = 0; i<dataArray.count;i++){
                    if ([dataArray objectAtIndex:i].trackType == AVPTRACK_TYPE_VIDEO){
                        [track addObject:[dataArray objectAtIndex:i]];
                    }
                    if (i == dataArray.count-1){
                        weakSelf.dataArray = [track copy];
                        [weakSelf layoutReset];
                    }
                }
            }
        });
    }
    else {
        [weakSelf layoutReset];
    }
}

- (void) layoutReset{
    for (UIView *subView in self.groupView.subviews) {
        [subView removeFromSuperview];
    }
    
    CGFloat padding = 15.0; // 控件之间的间距
    CGFloat buttonWidth = 80.0; // 控件的宽度
    CGFloat buttonHeight = 30.0; // 控件的高度
    CGFloat xPosition = self.trackLabel.frame.size.width + 15; // 控件的初始 X 位置
    CGFloat yPosition = padding; // 控件的初始 Y 位置
    if (self.dataArray && self.dataArray.count > 1){
        for (NSInteger i = 0; i < self.dataArray.count; i++){

            AVPTrackInfo *trackInfo = [self.dataArray objectAtIndex:i];
            NSString *title = [AUIVideoTrackInfoUtil getQuality:trackInfo];
            
            UIButton *trackBtn = [[UIButton alloc]initWithFrame:CGRectMake(xPosition, yPosition, buttonWidth, buttonHeight)];
            trackBtn.clipsToBounds = YES;
            trackBtn.layer.cornerRadius = 10;
            trackBtn.backgroundColor = [UIColor whiteColor];
            [trackBtn setTitle:title forState:UIControlStateNormal];
            [trackBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
            trackBtn.tag = i;
            
            [trackBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
             
            
            [self.groupView addSubview:trackBtn];
            
            xPosition += buttonWidth + padding;
            
            if(xPosition + buttonWidth > _groupView.frame.size.width){
                xPosition = 15;
                yPosition += buttonHeight + padding;
            }
            self.groupView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height + trackBtn.frame.size.height + padding);
        }
    }
    else {
        UIButton *autoTrack = [[UIButton alloc]initWithFrame:CGRectMake(xPosition, 15, 60, 30)];
        autoTrack.clipsToBounds = YES;
        autoTrack.layer.cornerRadius = 10;
        autoTrack.backgroundColor = [UIColor whiteColor];
        [autoTrack setTitle:@"AUTO" forState:UIControlStateNormal];
        [autoTrack setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        autoTrack.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.groupView addSubview:autoTrack];
        return;
    }
}


// 点击事件处理方法
- (void)buttonClicked:(UIButton *)sender {
    // 通过 sender 访问按钮信息
    NSInteger buttonTag = sender.tag;
    
    __weak typeof(self) weakSelf = self;
    
    if (weakSelf.onTrackSelect){
        weakSelf.onTrackSelect([self.dataArray objectAtIndex:buttonTag]);
    }
}

- (void)adjustLabelWidth:(UILabel *)label withText:(NSString *)text andFont:(UIFont *)font {
    // 设置要显示的文本
    label.text = text;
    
    // 计算文本的宽度
    CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName: font}];
    
    // 更新UILabel的frame以适应文本宽度
    CGRect labelFrame = label.frame;
    labelFrame.size.width = textSize.width;
    label.frame = labelFrame;
}

@end
