//
//  ViewController.m
//  Example
//
//  Created by keria on 2025/6/2.
//

#import "ViewController.h"
#import <App/App.h>

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - View Layout

// 视图加载完毕后的初始化设置
- (void)viewDidLoad {
    [super viewDidLoad];

    // 设置导航控制器
    AppHomeViewController *homeVC = [[AppHomeViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:homeVC];

    // 添加导航控制器到当前视图控制器
    [self addChildViewController:navController];
    navController.view.frame = self.view.bounds;
    navController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:navController.view];
    [navController didMoveToParentViewController:self];
}

@end
