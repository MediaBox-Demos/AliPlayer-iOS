//
//  AppDelegate.m
//  AlivcPlayerDemo
//
//  Created by ISS013602000846 on 2023/7/24.
//

#import "AppDelegate.h"
#import "AUIFoundation.h"
#import "AUIPlayerViewController.h"
#import "AlivcPlayerDemoConfig.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    // 仅支持暗黑模式
    AVTheme.supportsAutoMode = NO;
    AVTheme.currentMode = AVThemeModeDark;
    
    AUIPlayerViewController *rootVC = [AUIPlayerViewController new];
    rootVC.hiddenBackButton = YES;
    AVNavigationController *nav =[[AVNavigationController alloc]initWithRootViewController:rootVC];
    [self.window setRootViewController:nav];
    [self.window makeKeyAndVisible];
    
    AlivcPlayerDemoConfig *config = [AlivcPlayerDemoConfig new];
    [config didFinishLaunching];
    
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    UIInterfaceOrientationMask orientationMask = UIViewController.av_topViewController.supportedInterfaceOrientations;
    AlivcPlayerDemoConfig *config = [AlivcPlayerDemoConfig new];
    orientationMask = [config supportedInterfaceOrientation];
    return orientationMask;
}

@end
