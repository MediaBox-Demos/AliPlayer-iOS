//
//  AUIShortVideoRateView.m
//  Pods
//
//  Created by wyq on 2024/11/11.
//
#import "AUIShortVideoRateView.h"
#import "AUIShortVideoListMacro.h"

@interface AUIShortVideoRateView ()

@property(nonatomic,strong)UIButton *rateButton1;
@property(nonatomic,strong)UIButton *rateButton2;
@property(nonatomic,strong)UIButton *rateButton3;
@property(nonatomic,strong)UIButton *rateButton4;
@property(nonatomic,strong)UIButton *rateButton5;

@end

@implementation AUIShortVideoRateView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        CGFloat circleSize= 40;
        CGFloat cornerRadius= 20;
        
        UILabel *label = [[UILabel alloc]init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.text = SVString(@"playback speed");
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:14];
        
        [self adjustLabelWidth:label withText:SVString(@"playback speed") andFont:label.font];
        
        self.rateButton1 = [[UIButton alloc] init];
        self.rateButton1.translatesAutoresizingMaskIntoConstraints = NO;
        self.rateButton1.backgroundColor = [UIColor whiteColor];
        self.rateButton1.layer.cornerRadius = cornerRadius;
        self.rateButton1.clipsToBounds =YES;
        self.rateButton1.titleLabel.font =[UIFont systemFontOfSize:14];
        [self.rateButton1 setTitle:@"0.5x" forState:UIControlStateNormal];
        [self.rateButton1 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [self.rateButton1 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        self.rateButton2 = [[UIButton alloc] init];
        self.rateButton2.translatesAutoresizingMaskIntoConstraints = NO;
        self.rateButton2.backgroundColor = [UIColor whiteColor];
        self.rateButton2.layer.cornerRadius = cornerRadius;
        self.rateButton2.clipsToBounds = YES;
        self.rateButton2.titleLabel.font =[UIFont systemFontOfSize:14];
        [self.rateButton2 setTitle:@"0.8x" forState:UIControlStateNormal];
        [self.rateButton2 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [self.rateButton2 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        //1.0 speed
        self.rateButton3 = [[UIButton alloc] init];
        self.rateButton3.translatesAutoresizingMaskIntoConstraints = NO;
        self.rateButton3.backgroundColor = [UIColor whiteColor];
        self.rateButton3.layer.cornerRadius = cornerRadius;
        self.rateButton3.clipsToBounds = YES;
        self.rateButton3.titleLabel.font =[UIFont systemFontOfSize:14];
        [self.rateButton3 setTitle:@"1.0x" forState:UIControlStateNormal];
        [self.rateButton3 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [self.rateButton3 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        //2.0 speed
        self.rateButton4 = [[UIButton alloc] init];
        self.rateButton4.translatesAutoresizingMaskIntoConstraints = NO;
        self.rateButton4.backgroundColor = [UIColor whiteColor];
        self.rateButton4.layer.cornerRadius = cornerRadius;
        self.rateButton4.clipsToBounds = YES;
        self.rateButton4.titleLabel.font =[UIFont systemFontOfSize:14];
        [self.rateButton4 setTitle:@"2.0x" forState:UIControlStateNormal];
        [self.rateButton4 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [self.rateButton4 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        self.rateButton5 = [[UIButton alloc] init];
        self.rateButton5.translatesAutoresizingMaskIntoConstraints = NO;
        self.rateButton5.backgroundColor = [UIColor whiteColor];
        self.rateButton5.layer.cornerRadius = cornerRadius;
        self.rateButton5.clipsToBounds = YES;
        self.rateButton5.titleLabel.font =[UIFont systemFontOfSize:14];
        [self.rateButton5 setTitle:@"3.0x" forState:UIControlStateNormal];
        [self.rateButton5 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [self.rateButton5 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:label];
        [self addSubview:self.rateButton1];
        [self addSubview:self.rateButton2];
        [self addSubview:self.rateButton3];
        [self addSubview:self.rateButton4];
        [self addSubview:self.rateButton5];
        
        
        [NSLayoutConstraint activateConstraints:@[
            [label.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
            [label.topAnchor constraintEqualToAnchor:self.topAnchor constant:10],
            [label.widthAnchor constraintEqualToConstant:label.frame.size.width],
            [label.heightAnchor constraintEqualToConstant:circleSize],

            [self.rateButton1.leadingAnchor constraintEqualToAnchor:label.trailingAnchor constant:15],
            [self.rateButton1.topAnchor constraintEqualToAnchor:label.topAnchor],
            [self.rateButton1.widthAnchor constraintEqualToConstant:circleSize],
            [self.rateButton1.heightAnchor constraintEqualToConstant:circleSize],

            [self.rateButton2.leadingAnchor constraintEqualToAnchor:self.rateButton1.trailingAnchor constant:10],
            [self.rateButton2.topAnchor constraintEqualToAnchor:label.topAnchor],
            [self.rateButton2.widthAnchor constraintEqualToConstant:circleSize],
            [self.rateButton2.heightAnchor constraintEqualToConstant:circleSize],
            
            [self.rateButton3.leadingAnchor constraintEqualToAnchor:self.rateButton2.trailingAnchor constant:10],
            [self.rateButton3.topAnchor constraintEqualToAnchor:label.topAnchor],
            [self.rateButton3.widthAnchor constraintEqualToConstant:circleSize],
            [self.rateButton3.heightAnchor constraintEqualToConstant:circleSize],
            
            [self.rateButton4.leadingAnchor constraintEqualToAnchor:self.rateButton3.trailingAnchor constant:10],
            [self.rateButton4.topAnchor constraintEqualToAnchor:label.topAnchor],
            [self.rateButton4.widthAnchor constraintEqualToConstant:circleSize],
            [self.rateButton4.heightAnchor constraintEqualToConstant:circleSize],
            
            [self.rateButton5.leadingAnchor constraintEqualToAnchor:self.rateButton4.trailingAnchor constant:10],
            [self.rateButton5.topAnchor constraintEqualToAnchor:label.topAnchor],
            [self.rateButton5.widthAnchor constraintEqualToConstant:circleSize],
            [self.rateButton5.heightAnchor constraintEqualToConstant:circleSize],
            ]];
    }
    
    return self;
}

- (void)buttonClicked:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    if (!weakSelf.onRateChange) return;
    if (sender == self.rateButton1) {
        weakSelf.onRateChange(0.5);
    } else if (sender == self.rateButton2) {
        weakSelf.onRateChange(0.8);
    } else if (sender == self.rateButton3) {
        weakSelf.onRateChange(1.0);
    } else if (sender == self.rateButton4) {
        weakSelf.onRateChange(2.0);
    } else if (sender == self.rateButton5) {
        weakSelf.onRateChange(3.0);
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
