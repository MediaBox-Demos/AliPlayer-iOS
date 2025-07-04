//
//  AppDelegate.m
//  Example
//
//  Created by keria on 2025/6/2.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <Common/Common.h>

// 业务来源信息
static NSString *const kExtraDataApiExample = @"{\"scene\":\"api-example\",\"platform\":\"ios\",\"style\":\"objc\"}";

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    ViewController *rootVC = [[ViewController alloc] init];
    [self.window setRootViewController:rootVC];
    [self.window makeKeyAndVisible];

    // 设置业务来源信息
    [AliPlayerGlobalSettings setOption:SET_EXTRA_DATA value:kExtraDataApiExample];

    // 可选：如有其他全局初始化操作，请在此处添加

    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}

@end
