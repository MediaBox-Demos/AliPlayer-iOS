//
//  AUIShortVideoAdvertisementCell.m
//  Pods
//
//  Created by wyq on 2024/11/11.
//

#import "AUIShortVideoAdvertisementCell.h"
#import "AUIShortVideoListMacro.h"

@interface AUIShortVideoAdvertisementCell ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) AVBlockButton *backButton;

@end


@implementation AUIShortVideoAdvertisementCell


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        __weak typeof(self) weakSelf = self;
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)]; // 创建 UILabel，宽200高50
        _label.text = SVString(@"advertisement page");
        _label.textColor = UIColor.whiteColor;
        _label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_label]; // 将 label 添加到父视图中
        
        _backButton = [AVBlockButton new];
        [_backButton setImage:AUIFoundationImage(@"ic_back") forState:UIControlStateNormal];
        _backButton.clickBlock = ^(AVBlockButton * _Nonnull sender) {
            if (weakSelf.onBackBtnClickBlock) {
                weakSelf.onBackBtnClickBlock(weakSelf);
            }
        };
        [self.contentView addSubview:_backButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self){
        self.backButton.frame = CGRectMake(20, AVSafeTop + 20, 26, 26);
        self.label.center = self.contentView.center; // 将 label 的中心点设置为父视图的中心点
    }
}


@end
