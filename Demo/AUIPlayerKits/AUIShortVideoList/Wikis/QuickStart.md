# **快速开始**

下面介绍 **AUIShortVideoList** 组件的对外接口和使用方法介绍，用于实现短视频列表播放功能。在完成 AUIShortVideoList 组件的集成步骤后，您可以直接将以下代码拷贝到项目中使用。

## **1. 使用方法**

* **AUIShortVideoListViewController**

该组件提供两种方式来初始化和推送 `AUIShortVideoListViewController`：

1.1 使用 UINavigationController 进行跳转

Objective-C 

```objective-c
// 创建视频信息数组，可用户自定义，默认无数据
NSArray<AUIShortVideoInfo *> *videoInfoList = [[NSArray alloc] init];
// 初始化 AUIShortVideoListViewController，传入视频数据
AUIShortVideoListViewController *vc = [[AUIShortVideoListViewController alloc] initWithData:videoInfoList];
// 使用 UINavigationController 推送新视图控制器
[self.navigationController pushViewController:vc animated:YES];
```

Swift 

```swift
// 创建视频信息数组
let info = Array<AUIShortVideoInfo>() // 添加数据源，可用户自定义，默认无数据
// 初始化 AUIShortVideoListViewController，传入视频数据
let vc = AUIShortVideoListViewController(data: info)
// 使用 UINavigationController 推送新视图控制器
self.navigationController?.pushViewController(vc, animated: true)
```

1.2 使用模态（Modal）方式跳转

**请注意**：如果您选择采用模态（Modal）方式进行页面跳转而不使用 UINavigationController，那么可能需要调整内部的页面跳转逻辑，并自定义返回路径。这样做是为了确保能够顺利地以模态形式打开目标页面。

Objective-C 

```objective-c
// 创建视频信息数组
NSArray<AUIShortVideoInfo *> *videoInfoList = [[NSArray alloc] init];
// 初始化 AUIShortVideoListViewController，传入视频数据，可用户自定义，默认无数据
AUIShortVideoListViewController *vc = [[AUIShortVideoListViewController alloc] initWithData:videoInfoList];
// 设置模态展示样式（可选）
vc.modalPresentationStyle = UIModalPresentationFullScreen;
// 以模态方式展示新视图控制器
[self presentViewController:vc animated:YES completion:nil];
```

Swift

```swift
// 创建视频信息数组
let info = Array<AUIShortVideoInfo>() // 添加数据源，可用户自定义，默认无数据
// 初始化 AUIShortVideoListViewController，传入视频数据
let vc = AUIShortVideoListViewController(data: info)
// 设置模态展示样式
vc.modalPresentationStyle = .fullScreen // 可选，根据需求设置样式
// 以模态方式展示新视图控制器
self.present(vc, animated: true, completion: nil)
```

您还可以通过实现 `AUIShortVideoDataProviderDelegate` 委托来注册数据回调，从而自定义加载视频数据。


* **UINavigationController 集成**

#### **在 Objective-C 项目中集成 UINavigationController**

**请注意**：在 XCode 更新到 11 之后，新增了 SceneDelegate；在 iOS 13 之前，AppDelegate 会处理 App 的生命周期和 UI 生命周期，但 iOS 13 之后，AppDelegate 不再处理 UI 生命周期了，只负责处理 App 的生命周期和新的 Scene Session 生命周期，而 UI 的生命周期就会由 Scene Delegate 处理。代码示例如下：

- AppDelegate.m（适用于 iOS 13 之前）

```objective-c
#import "MyViewController.h"
#import "AlivcPlayerDemoConfig.h"
#import "AVTheme.h"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    // Override point for customization after application launch.
    
  	// 仅支持暗黑模式
    AVTheme.supportsAutoMode = NO;
    AVTheme.currentMode = AVThemeModeDark;
    
    // 创建根视图控制器，可自定义
    MyViewController *mainViewController = [MyViewController new];
    // 使用封装后的AVNavigationController
    AVNavigationController *nav =[[AVNavigationController alloc]initWithRootViewController:mainViewController];
    // 使用系统的UINavigationController
//  UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mainViewController];
    [self.window setRootViewController:nav];
    [self.window makeKeyAndVisible];
    return YES;
}
```

- SceneDelegate.m（适用于 iOS 13 之后）

```objective-c
#import "MyViewController.h"
#import "AlivcPlayerDemoConfig.h"
#import "AVTheme.h"

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    
    // Override point for customization after application launch.
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc]initWithWindowScene:scene];
    self.window.frame = windowScene.coordinateSpace.bounds;
  	
    // 仅支持暗黑模式
    AVTheme.supportsAutoMode = NO;
    AVTheme.currentMode = AVThemeModeDark;
    
    // 创建根视图控制器
    MyViewController *mainViewController = [MyViewController new];

    AVNavigationController *nav =[[AVNavigationController alloc]initWithRootViewController:mainViewController];
//    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mainViewController];
    [self.window setRootViewController:nav];
    [self.window makeKeyAndVisible];
}
```

#### **在 Swift 项目中集成 UINavigationController**

- AppDelegate.swift（适用于 iOS 13 之前）

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    UIApplication.shared.statusBarStyle = UIStatusBarStyle.darkContent;
    self.window = UIWindow(frame: UIScreen.main.bounds)

    let myViewController = MyViewController();

    let nav = AVNavigationController(rootViewController: myViewController );
    //使用系统 UINavigationController
    //let nav = UINavigationController(rootViewController: myViewController );

    self.window?.rootViewController = nav;
    self.window?.makeKeyAndVisible();
    guard let _ = (scene as? UIWindowScene) else { return }
}
```

- SceneDelegate.swift（适用于 iOS 13 之后）

```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    UIApplication.shared.statusBarStyle = UIStatusBarStyle.darkContent;
    let windowScene = scene as! UIWindowScene;

    self.window = UIWindow(windowScene: windowScene);
    self.window?.frame = windowScene.coordinateSpace.bounds;

    let myViewController = MyViewController();

    let nav = AVNavigationController(rootViewController: myViewController );
    // 使用系统的 UINavigationController
    // let nav = UINavigationController(rootViewController: myViewController );

    self.window?.rootViewController = nav;
    self.window?.makeKeyAndVisible();
    guard let _ = (scene as? UIWindowScene) else { return }
}
```


## **2. 获取数据**

### **2.1. 数据结构**

AUIShortVideoList 组件的数据结构为 `NSArray<AUIShortVideoInfo *>`，其中 `AUIShortVideoInfo` 是用于存储视频信息的数据类。其数据结构如下：

| 字段     | 类型   | 释义       | 备注                                   |
| -------- | ------ | ---------- | -------------------------------------- |
| videoId  | int    | 视频唯一id | 用于唯一标识每一个视频                 |
| url      | String | 视频源地址 | 您可以自定义视频源格式，如 MP4/M3U8 等 |
| coverUrl | String | 视频封面图 |                                        |
| author   | String | 视频作者   |                                        |
| title    | String | 视频标题   |                                        |
| type     | String | 视频类型   | 参考 VideoType 枚举，视频源 or 广告    |

### **2.2. 组件初始化**

为了确保 AUIShortVideoList 组件正常运行，请在初始化 `AUIShortVideoListViewController` 时，传入 `NSArray<AUIShortVideoInfo *>` 数据源。以下是示例代码：

Objective-C 

```objective-c
// 在当前视图控制器中创建视频信息数组并初始化控制器
NSArray<AUIShortVideoInfo *> *videoInfoList = [[NSArray alloc] init];
AUIShortVideoListViewController *vc = [[AUIShortVideoListViewController alloc] initWithData:videoInfoList];
// 使用 UINavigationController 推送新视图控制器
[self.navigationController pushViewController:vc animated:YES];
```

Swift

```swift
// 在当前视图控制器中创建视频信息数组并初始化控制器
let info = [AUIShortVideoInfo]() // 添加数据源，默认为空数据。您可以根据自身的业务去添加相应的数据
let vc = AUIShortVideoListViewController(data: info)
// 使用 UINavigationController 推送新视图控制器
self.navigationController?.pushViewController(vc, animated: true)
```

### **2.3. 自定义数据加载**

除了直接传递数据数组，您还可以通过实现 `AUIShortVideoDataProviderDelegate` 协议来自定义数据加载：

* **通过代理初始化组件**

  建议在初始化时实现数据代理：

  Objective-C

  ```objective-c
  // 在当前视图控制器中初始化控制器，传入数据提供者
  AUIShortVideoListViewController *videoListVC = [[AUIShortVideoListViewController alloc] initWithDataProvider:self];
  // 使用 UINavigationController 推送新视图控制器
  [self.navigationController pushViewController:videoListVC animated:YES];
  ```

  Swift

  ```swift
  // 在当前视图控制器中初始化控制器，传入数据提供者
  let videoListVC = AUIShortVideoListViewController(dataProvider: self)
  // 使用 UINavigationController 推送新视图控制器
  self.navigationController?.pushViewController(videoListVC, animated: true)
  ```

* **AUIShortVideoDataProviderDelegate 协议**

  通过实现以下协议，可以实现自定义数据加载和刷新：

  ```objective-c
  @protocol AUIShortVideoDataProviderDelegate <NSObject>
  @required
  - (void)loadData:(id _Nullable)controller; //加载数据
  @optional
  - (void)refreshData:(id _Nullable)controller;//刷新数据（可选）
  @end
  ```

### **2.4. 更新数据列表**

当获取到视频数据后，使用以下接口更新 `ViewController` 中的数据列表：

* **追加数据**

```objective-c
/**
* @brief 将新的视频数据追加到当前视频列表中。
*
* @param videoInfoList 新的视频数据列表，可以为空。
*                      当提供的数据列表不为空时，这些数据将被追加到现有的视频列表的末尾。
*                      如果提供为空的数据列表，则不对当前列表进行任何修改。
*/
- (void)appendVideoInfoList:(NSArray<AUIShortVideoInfo *> * _Nullable)videoInfoList;
```

* **重置数据**

```objective-c
/**
* @brief 重置当前的视频列表为指定的新视频数据列表。
*
* @param videoInfoList 新的视频数据列表，可以为空。
*                      将当前的视频列表替换为提供的数据列表。
*                      如果提供为空的数据列表，将清空当前视频列表。
*/
- (void)resetVideoInfoList:(NSArray<AUIShortVideoInfo *> * _Nullable)videoInfoList;
```

### **2.5. 获取数据示例**

以下提供了通过网络请求和数据转换获取 `NSArray<AUIShortVideoInfo *>` 数据源的示例：


* **网络请求示例**

Objective-C:

```objective-c
// 请求额外数据 AUIShortVideoListConstants.defaultVideoInfoListURL 为请求 URL，您可以尝试将其替换为自己的请求地址 URL
- (void)loadData:(id)controller {
    __weak typeof(self) weakSelf = self;  // 弱引用 self
    [AUIShortVideoListDataManager requestVideoInfoList:AUIShortVideoListConstants.defaultVideoInfoListURL completed:^(NSArray<AUIShortVideoInfo *> * _Nullable data, NSError * _Nullable error) {
        if (error) {
            __strong typeof(weakSelf) strongSelf = weakSelf; // 强引用 self
            [AVToastView show:[NSString stringWithFormat:@"Unable to retrieve short video list, error: %@", error.localizedDescription]
                        view:strongSelf.view
                    position:AVToastViewPositionMid];
            return;
        }

        // 调用相应子视图控制器的 appendVideoInfoList: 方法
        if (controller && [controller respondsToSelector:@selector(appendVideoInfoList:)]) {
            [controller appendVideoInfoList:data];
        }
    }];
}
```
Swift:  

```swift
// 请求额外数据 AUIShortVideoListConstants.defaultVideoInfoListURL 为请求 URL，您可以尝试将其替换为自己的请求地址 URL
func loadData(_ controller: Any?) {
    weak var weakSelf = self  // Weak reference to self
    AUIShortVideoListDataManager.requestVideoInfoList(AUIShortVideoListConstants.defaultVideoInfoListURL) { (data: [AUIShortVideoInfo]?, error: Error?) in
        if let error = error {
            guard let strongSelf = weakSelf else { return } // Strong reference to self
            AVToastView.show("Unable to retrieve short video list, error: \(error.localizedDescription)", view: strongSelf.view, position: .mid)
            return
        }

        if let myController = controller as? AUIShortVideoListViewController {
            // 成功转型，使用 myController
            if  myController.responds(to: #selector(myController.appendVideoInfoList(_:))) {
                myController.appendVideoInfoList(data)
            }
        }
    }
}
```


* **数据转换示例**

Objective-C：

```objective-c
// 将字典数组转换为视频信息模型数组
NSArray<NSDictionary *> *responseArray = (NSArray<NSDictionary *> *)responseObject;
NSMutableArray<AUIShortVideoInfo *> *videoInfoArray = [NSMutableArray arrayWithCapacity:responseArray.count];
for (NSDictionary *dict in responseArray) {
    // 初始化 AUIShortVideoInfo 模型对象并添加到数组中
    AUIShortVideoInfo *videoInfo = [[AUIShortVideoInfo alloc] initWithDict:dict];
    [videoInfoArray addObject:videoInfo];
}
```

Swift：

```swift
let responseArray = responseObject as? [[AnyHashable : Any]]
var videoInfoArray = [AnyHashable](repeating: 0, count: responseArray?.count ?? 0) as? [AUIShortVideoInfo]
for dict in responseArray ?? [:] {
    guard let dict = dict as? [AnyHashable : Any] else {
            continue
    }
    // 初始化 AUIShortVideoInfo 模型对象并添加到数组中
    let videoInfo = AUIShortVideoInfo(dict: dict)
    videoInfoArray?.append(videoInfo)
}
```

## **3. 搭建场景**

AUIShortVideoList 组件支持低代码集成，适用于多种场景。您可以基于此组件构建短视频列表的场景化功能。请参考 AUIPlayerScenes 中的示例及文档，例如 AUIShortDramaList（短剧剧场场景化模块）和 AUIShortDramaFeeds（短剧 Feeds 流场景化模块）。