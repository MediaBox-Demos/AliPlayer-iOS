//
//  FloatWindowView.m
//  FloatWindow
//
//  Created by aqi on 2025/6/24.
//

#import "FloatWindowView.h"
#import "AliyunPlayer/AliyunPlayer.h"
#import "Common/Common.h"

@interface FloatWindowView ()

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture; // 拖动手势
@property (nonatomic, assign) CGPoint originalPosition;           // 记录触摸起始点
@property (nonatomic, strong) UIWindow *keyWindow;                // 主窗口
@property (nonatomic, strong) UIView *playerView;                 // 播放器视图
@property (nonatomic, strong) AliPlayer *player;                  // 播放器

@end

@implementation FloatWindowView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self setupGesture];
        [self setupPlayer];
        [self startupPlayer];
    }
    return self;
}

#pragma mark - UI Setup
/**
 @brief Step 1 初始化UI
 */
- (void)setupUI {
    // 设置悬浮窗的基本属性
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    self.layer.cornerRadius = 10;
    self.clipsToBounds = YES;
}

/**
 * @brief Step 2 初始化播放器&&播放器视图
 */
- (void)setupPlayer {
    self.playerView = [[UIView alloc] initWithFrame:self.bounds];
    self.player = [[AliPlayer alloc] init];
    self.player.playerView = self.playerView;

    [self addSubview:self.playerView];
}

/**
 * @brief Step 3 设置播放源&& prepare 播放器（准备播放）
 */
- (void)startupPlayer {
    AVPVidAuthSource *authSource = [[AVPVidAuthSource alloc]init];
    [authSource setVid:kSampleVideoId];
    [authSource setPlayAuth:kSampleVideoAuth];
    [self.player setAuthSource:authSource];
    [self.player prepare];
}

#pragma mark - Gesture Setup
/**
 * @brief 悬浮窗拖拽处理
 */
- (void)setupGesture {
    // 添加拖动手势
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:self.panGesture];
}

#pragma mark - Gesture Handler

/**
 * @brief 悬浮窗拖拽实现
 */
- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    // 获取手势的位置变化
    CGPoint translation = [gesture translationInView:self.superview];

    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            // 记录起始位置
            self.originalPosition = self.center;
            break;
        }

        case UIGestureRecognizerStateChanged: {
            // 计算新的中心点
            CGPoint newCenter = CGPointMake(self.originalPosition.x + translation.x,
                                            self.originalPosition.y + translation.y);

            // 获取屏幕边界
            CGRect bounds = [UIScreen mainScreen].bounds;
            CGFloat halfWidth = CGRectGetWidth(self.frame) / 2;
            CGFloat halfHeight = CGRectGetHeight(self.frame) / 2;

            // 确保不超出屏幕边界
            newCenter.x = MAX(halfWidth, MIN(bounds.size.width - halfWidth, newCenter.x));
            newCenter.y = MAX(halfHeight, MIN(bounds.size.height - halfHeight, newCenter.y));

            // 更新位置
            self.center = newCenter;
            break;
        }

        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            // 可以在这里添加动画效果，比如自动贴边
            [self stickToNearestEdge];
            break;
        }

        default:
            break;
    }
}

#pragma mark - Helper Methods
/**
 * 自动贴边
 */
- (void)stickToNearestEdge {
    // 贴边动画效果
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat centerX = self.center.x;

    // 判断是贴左边还是右边
    BOOL shouldStickToRight = (centerX > screenBounds.size.width / 2);
    CGFloat targetX = shouldStickToRight ? (screenBounds.size.width - self.frame.size.width / 2) : (self.frame.size.width / 2);

    [UIView animateWithDuration:0.3
                     animations:^{
                       CGPoint center = self.center;
                       center.x = targetX;
                       self.center = center;
                     }];
}

#pragma mark - Public Methods
/**
 * @brief Step 4  显示窗口&&播放视频
 */
- (void)show {
    // 获取主窗口
    self.keyWindow = [UIApplication sharedApplication].keyWindow;
    self.keyWindow.windowLevel = UIWindowLevelAlert + 1;

    if (@available(iOS 13.0, *)) {
        UIWindowScene *windowScene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
        self.keyWindow.windowScene = windowScene;
    }

    // 添加到主窗口
    if (![self.keyWindow.subviews containsObject:self]) {
        [self.keyWindow addSubview:self];
    }

    // 显示动画
    self.alpha = 0;
    [UIView animateWithDuration:0.3
        animations:^{
          self.alpha = 1;
        }
        completion:^(BOOL finished) {
          if (self.player) {
              [self.player start];
          }
        }];
}

/**
 * @brief Step 5  隐藏窗口&&暂停视频
 */
- (void)hide {
    // 隐藏动画
    [UIView animateWithDuration:0.3
        animations:^{
          self.alpha = 0;
        }
        completion:^(BOOL finished) {
          if (self.player) {
              [self.player pause];
          }
          [self removeFromSuperview];
        }];
}

/**
 * @brief Step 6 销毁窗口&&播放器
 */
- (void)destroy {
    if (self.player) {
        [self.player stop];
        [self.player destroy];

        self.player = nil;
        self.playerView = nil;
    }
}

@end
