//
//  AUIShortDramaDetailView.m
//  AUIPlayer
//
//  Created by keria on 2024/11/7.
//

#import "AUIShortDramaDetailView.h"
#import "AUIShortVideoListMacro.h"

@interface AUIShortDramaDetailView () <CAAnimationDelegate>

// 内部使用的图片视图，显示视频图标
@property (nonatomic, strong) UIImageView *detailsImageView;

// 用于显示详情标题的标签
@property (nonatomic, strong) UILabel *detailsTitleLabel;

// 用于显示"继续看"的标签
@property (nonatomic, strong) UILabel *continueWatchLabel;

// 用于存储传入的点击事件的回调 block
@property (nonatomic, copy) AUIShortDramaDetailViewTapHandler tapHandler;

@end

@implementation AUIShortDramaDetailView

#pragma mark - LifeCycle

// 初始化自定义视图
- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame tapHandler:nil];
}

// 初始化自定义视图
- (instancetype)initWithFrame:(CGRect)frame tapHandler:(AUIShortDramaDetailViewTapHandler)tapHandler {
    self = [super initWithFrame:frame];
    if (self) {
        self.tapHandler = tapHandler; // 设置点击事件回调
        [self configureView];
    }
    return self;
}


#pragma mark - View Layout

// 配置子视图的外观和属性
- (void)configureView {
    // 设置背景颜色
    self.backgroundColor = [UIColor av_colorWithHexString:@"#3A3D48"];
    
    // 设置整个视图的圆角
    self.layer.cornerRadius = 20;
    self.layer.masksToBounds = YES;
    
    // 初始化图标视图
    self.detailsImageView = [[UIImageView alloc] initWithImage:[AVTheme imageWithCommonNamed:@"ic_video" withModule:@"AUIShortDramaList"]];
    self.detailsImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.detailsImageView.layer.cornerRadius = 15;
    self.detailsImageView.layer.masksToBounds = YES;
    [self addSubview:self.detailsImageView];
    
    // 初始化标题标签
    self.detailsTitleLabel = [[UILabel alloc] init];
    self.detailsTitleLabel.text = AVGetString(@"Continue Watching", @"AUIShortDramaList"); // @"观看完整短剧"
    self.detailsTitleLabel.textColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
    self.detailsTitleLabel.font = [UIFont systemFontOfSize:16];
    self.detailsTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.detailsTitleLabel];
    
    // 初始化"继续看"标签
    self.continueWatchLabel = [[UILabel alloc] init];
    self.continueWatchLabel.text = AVGetString(@"Continue Watching", @"AUIShortDramaList");
    self.continueWatchLabel.backgroundColor = [UIColor av_colorWithHexString:@"#23262F"];
    self.continueWatchLabel.textColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
    self.continueWatchLabel.font = [UIFont systemFontOfSize:16];
    self.continueWatchLabel.textAlignment = NSTextAlignmentCenter;
    self.continueWatchLabel.layer.cornerRadius = 15;
    self.continueWatchLabel.clipsToBounds = YES;
    [self addSubview:self.continueWatchLabel];
    
    // 初始化手势识别器
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapGestureRecognizer];
}

// 视图布局设置
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat padding = 20; // 左侧图标到视图边缘的间距
    CGFloat standardHeight = 30; // 子视图的标准高度
    
    // 布局图标视图
    self.detailsImageView.frame = CGRectMake(padding, (self.bounds.size.height - standardHeight) / 2, standardHeight, standardHeight);
    
    // 布局标题标签
    CGSize titleSize = [self.detailsTitleLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, self.bounds.size.height)];
    self.detailsTitleLabel.frame = CGRectMake(CGRectGetMaxX(self.detailsImageView.frame) + padding, (self.bounds.size.height - titleSize.height) / 2, titleSize.width, titleSize.height);
    
    // 布局"继续看"标签
    CGFloat continueLabelWidth = 30 + 2 * 30; // 标签宽度包括内边距
    self.continueWatchLabel.frame = CGRectMake(self.bounds.size.width - continueLabelWidth - padding, (self.bounds.size.height - standardHeight) / 2, continueLabelWidth, standardHeight);
}

#pragma mark - Navigation

// 点击事件的处理
- (void)handleTap:(UITapGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self];
    [self addRippleEffectAtLocation:location];
    
    // 执行点击事件后应有的逻辑
    if (self.tapHandler) {
        self.tapHandler();
    }
}

// 添加波纹效果
- (void)addRippleEffectAtLocation:(CGPoint)location {
    CALayer *rippleLayer = [CALayer layer];
    rippleLayer.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3].CGColor;
    rippleLayer.bounds = CGRectMake(0, 0, 20, 20);
    rippleLayer.cornerRadius = 10;
    rippleLayer.position = location;
    rippleLayer.masksToBounds = YES;
    [self.layer insertSublayer:rippleLayer above:self.layer];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @(1.0);
    scaleAnimation.toValue = @(5.0);
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @(0.3);
    opacityAnimation.toValue = @(0.0);
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[scaleAnimation, opacityAnimation];
    animationGroup.duration = 0.4;
    animationGroup.delegate = self;
    [animationGroup setValue:rippleLayer forKey:@"animationLayer"];
    [animationGroup setValue:@"removeRippleEffect" forKey:@"identifier"];
    
    [rippleLayer addAnimation:animationGroup forKey:nil];
}

#pragma mark - CAAnimationDelegate

// 动画结束后移除图层
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag && [[anim valueForKey:@"identifier"] isEqualToString:@"removeRippleEffect"]) {
        CALayer *layer = [anim valueForKey:@"animationLayer"];
        [layer removeFromSuperlayer];
    }
}

@end
