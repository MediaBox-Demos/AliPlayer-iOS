//
//  AppDelegate.swift
//  SwiftExample
//
//  Created by keria on 2025/6/6.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// 业务来源信息
    static let extraDataApiExample = "{\"scene\":\"api-example\",\"platform\":\"ios\",\"style\":\"swift-call-oc\"}";

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // 直接启动到 OC 的 AppHomeViewController
        if let appHomeVCClass = NSClassFromString("AppHomeViewController") as? UIViewController.Type {
            let appHomeVC = appHomeVCClass.init()
            
            let navController = UINavigationController(rootViewController: appHomeVC)
            window?.rootViewController = navController
        } else {
            // 如果找不到 OC 类，显示错误信息
            let alertVC = UIViewController()
            alertVC.view.backgroundColor = .white
            
            let label = UILabel()
            label.text = "Cannot find AppHomeViewController\nPlease ensure the bridging header is properly configured"
            label.textAlignment = .center
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            
            alertVC.view.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: alertVC.view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: alertVC.view.centerYAnchor),
                label.leadingAnchor.constraint(greaterThanOrEqualTo: alertVC.view.leadingAnchor, constant: 20),
                label.trailingAnchor.constraint(lessThanOrEqualTo: alertVC.view.trailingAnchor, constant: -20)
            ])
            
            window?.rootViewController = alertVC
        }
        
        window?.makeKeyAndVisible()

        // 设置业务来源信息
        AliPlayerGlobalSettings.setOption(SET_EXTRA_DATA, value: AppDelegate.extraDataApiExample);
        // 可选：如有其他全局初始化操作，请在此处添加
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits the application.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
