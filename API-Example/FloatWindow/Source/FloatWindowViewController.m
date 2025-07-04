//
//  FloatWindowViewController.m
//  FloatWindow
//
//  Created by aqi on 2025/6/24.
//

#import "FloatWindowViewController.h"
#import "FloatWindowView.h"
#import <AliyunPlayer/AliyunPlayer.h>
#import <Common/Common.h>

@interface FloatWindowViewController ()

@property (nonatomic, strong) UIButton *floatWindowBtn;
@property (nonatomic, assign) BOOL isShowFloat;
@property (nonatomic, strong) FloatWindowView *floatWindowView;

@end

@implementation FloatWindowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;

    self.floatWindowBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 2 - 40, self.view.bounds.size.height / 2 - 25, 80, 50)];
    self.floatWindowBtn.layer.cornerRadius = 10;
    self.floatWindowBtn.clipsToBounds = YES;
    if (@available(iOS 13.0, *)) {
        self.floatWindowBtn.backgroundColor = [UIColor systemTealColor];
    } else {
        // 回退到自定义颜色
        self.floatWindowBtn.backgroundColor = [UIColor colorWithRed:135.0 / 255.0 green:206.0 / 255.0 blue:235.0 / 255.0 alpha:1.0];
    }

    NSString *title = AppGetString(@"flow.btn.title");
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName : self.floatWindowBtn.titleLabel.font}];
    self.floatWindowBtn.frame = CGRectMake(self.view.bounds.size.width / 2 - (size.width / 2 + 10), self.view.bounds.size.height / 2 - 25, size.width + 20, 50);

    [self.floatWindowBtn setTitle:title forState:UIControlStateNormal];
    [self.floatWindowBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    // 点击事件
    [self.floatWindowBtn addTarget:self action:@selector(floatWindowBtnClicked:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.floatWindowBtn];

    NSInteger viewWidth = [UIScreen mainScreen].bounds.size.width;
    NSInteger viewHeight = [UIScreen mainScreen].bounds.size.height;
    if (viewWidth > viewHeight) {
        viewWidth = [UIScreen mainScreen].bounds.size.height;
        viewHeight = [UIScreen mainScreen].bounds.size.width;
    }

    // 初始化悬浮窗
    if (self.floatWindowView == nil) {
        self.floatWindowView = [[FloatWindowView alloc] initWithFrame:CGRectMake(0, 100, viewWidth / 3 * 2, viewWidth / 48 * 18 + 44)];
    }
}

// 显示播放器
- (void)floatWindowBtnClicked:(UIButton *)sender {
    NSLog(@"onClick");
    if (!self.isShowFloat) {
        [self.floatWindowView show];
        self.isShowFloat = YES;
    } else {
        [self.floatWindowView hide];
        self.isShowFloat = NO;
    }
}

- (void)dealloc {
    if (self.floatWindowView) {
        [self.floatWindowView hide];
        [self.floatWindowView destroy];
    }
}

@end
