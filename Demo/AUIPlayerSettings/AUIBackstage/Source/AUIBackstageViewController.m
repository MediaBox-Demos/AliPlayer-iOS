//
//  AUIBackstageViewController.m
//  AUIPlayer
//
//  Created by keria on 2024/11/6.
//

#import "AUIBackstageViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "AUIShortQRScanViewController.h"
#import "AUIShortVideoInfo.h"
#import "AUIShortVideoListViewController.h"

// 定义获取剧集信息列表的 URL
static NSString * const kDramaInfoListTotalUrl = @"https://alivc-demo-cms.alicdn.com/versionProduct/resources/shortdrama/drama-info-list-total.json";

@interface AUIBackstageViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

// 标题标签
@property (nonatomic, strong) UILabel *titleLabel;

// 清除缓存按钮
@property (nonatomic, strong) UIButton *clearCacheButton;

// 封面图回退策略标签
@property (nonatomic, strong) UILabel *coverImageFallbackLabel;
// 封面图回退策略开关
@property (nonatomic, strong) UISwitch *coverImageFallbackSwitch;
//广告标题
@property (nonatomic, strong) UILabel *advertisementPageLabel;
//广告开关
@property (nonatomic, strong) UISwitch *advertisementPageSwitch;

// 播放器池容量标签
@property (nonatomic, strong) UILabel *playerPoolCapacityLabel;
// 播放器池容量开关
@property (nonatomic, strong) UISwitch *playerPoolCapacitySwitch;

// 剧集信息列表 URL 标签
@property (nonatomic, strong) UILabel *dramaInfoListURLLabel;
// QR 二维码扫描
@property (nonatomic, strong) UIButton *dramaInfoQRButton;
// QR 二维码扫码tips
@property (nonatomic, strong) UILabel *dramaInfoQRLabel;
// 当前剧集信息 URL 标签
@property (nonatomic, strong) UILabel *currentDramaInfoListURLLabel;
// 剧集信息选择器
@property (nonatomic, strong) UIPickerView *dramaInfoListURLPicker;

// 构建版本标签
@property (nonatomic, strong) UILabel *buildVersionLabel;

// 选项数组
@property (nonatomic, strong) NSMutableArray<NSString *> *spinnerArray;
// 剧集 URL 数组
@property (nonatomic, strong) NSMutableArray<NSString *> *spinnerURLArray;

@end

@implementation AUIBackstageViewController

#pragma mark - LifeCycle

// 初始化方法
- (instancetype)init {
    self = [super init];
    if (self) {
        // 初始化代码
        NSLog(@"[init] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
    }
    return self;
}

// 释放资源的方法
- (void)dealloc {
    NSLog(@"[dealloc] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
}


#pragma mark - View Layout

// 加载布局
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置视图的背景颜色
    self.view.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22"];
    
    // 初始化选项数组
    self.spinnerArray = [NSMutableArray array];
    self.spinnerURLArray = [NSMutableArray array];
    
    // 设置 UI 组件
    [self setupViews];
    
    // 加载 SDK 版本
    [self loadVersion];
    // 加载剧集信息列表
    [self loadDramaInfoList];
}

// 设置 UI 组件
- (void)setupViews {
    // 设置标题标签
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"Backstage";
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    // 设置清除缓存按钮
    self.clearCacheButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.clearCacheButton setTitle:@"Clear Local Cache" forState:UIControlStateNormal];
    [self.clearCacheButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.clearCacheButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.clearCacheButton addTarget:self action:@selector(clearCache) forControlEvents:UIControlEventTouchUpInside];
    
    // 设置封面图回退策略标签及开关
    self.coverImageFallbackLabel = [[UILabel alloc] init];
    self.coverImageFallbackLabel.text = @"Enable cover image fallback strategy";
    self.coverImageFallbackLabel.textColor = [UIColor whiteColor];
    self.coverImageFallbackLabel.font = [UIFont boldSystemFontOfSize:15];
    self.coverImageFallbackLabel.textAlignment = NSTextAlignmentCenter;
    
    // 封面图回退策略开关初始化
    self.coverImageFallbackSwitch = [[UISwitch alloc] init];
    [self.coverImageFallbackSwitch setOn:AUIShortVideoListConstants.enableCoverURLStrategy animated:NO];
    [self.coverImageFallbackSwitch addTarget:self action:@selector(coverImageFallbackSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.advertisementPageLabel = [[UILabel alloc] init];
    self.advertisementPageLabel.text = @"Enable advertising page";
    self.advertisementPageLabel.textColor = [UIColor whiteColor];
    self.advertisementPageLabel.font = [UIFont boldSystemFontOfSize:15];
    self.advertisementPageLabel.textAlignment = NSTextAlignmentCenter;
    
    self.advertisementPageSwitch = [[UISwitch alloc] init];
    [self.advertisementPageSwitch setOn:AUIShortVideoListConstants.enableAdvertisementPage animated:NO];
    [self.advertisementPageSwitch addTarget:self action:@selector(advertisingBackSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    // 设置播放器池容量标签及开关
    self.playerPoolCapacityLabel = [[UILabel alloc] init];
    self.playerPoolCapacityLabel.text = @"Player pool capacity to three (default: two)";
    self.playerPoolCapacityLabel.textColor = [UIColor whiteColor];
    self.playerPoolCapacityLabel.font = [UIFont boldSystemFontOfSize:15];
    self.playerPoolCapacityLabel.textAlignment = NSTextAlignmentCenter;
    
    self.playerPoolCapacitySwitch = [[UISwitch alloc] init];
    [self.playerPoolCapacitySwitch setOn:(AUIShortVideoListConstants.playerPoolCapacity == 3) animated:NO];
    [self.playerPoolCapacitySwitch addTarget:self action:@selector(playerPoolCapacitySwitchChanged:) forControlEvents:UIControlEventValueChanged];
    
    // 设置剧集信息列表 URL 标签
    self.dramaInfoListURLLabel = [[UILabel alloc] init];
    self.dramaInfoListURLLabel.text = @"Drama Info List URL: ";
    self.dramaInfoListURLLabel.textColor = [UIColor whiteColor];
    self.dramaInfoListURLLabel.font = [UIFont boldSystemFontOfSize:15];
    self.dramaInfoListURLLabel.textAlignment = NSTextAlignmentCenter;
    
    // 设置短视频扫码按钮
    self.dramaInfoQRButton = [[UIButton alloc] init];
    self.dramaInfoQRButton.layer.borderWidth = 0.5;
    self.dramaInfoQRButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.dramaInfoQRButton.layer.cornerRadius = 8.0;
    self.dramaInfoQRButton.contentEdgeInsets = UIEdgeInsetsMake(5, 20, 5, 20);
    self.dramaInfoQRButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.dramaInfoQRButton addTarget:self action:@selector(openQRCode:) forControlEvents:UIControlEventTouchUpInside];
    [self.dramaInfoQRButton setTitle:@"短 视 频 扫 码" forState:UIControlStateNormal];
    [self.dramaInfoQRButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    // 设置短视频扫码Tips
    self.dramaInfoQRLabel = [[UILabel alloc] init];
    self.dramaInfoQRLabel.text = @"Tips：点击后扫码进行短剧场景的播放";
    self.dramaInfoQRLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.dramaInfoQRLabel.textColor = [UIColor whiteColor];
    self.dramaInfoQRLabel.font = [UIFont boldSystemFontOfSize:15];
    self.dramaInfoQRLabel.textAlignment = NSTextAlignmentCenter;
    
    // 设置当前剧集信息 URL 标签
    self.currentDramaInfoListURLLabel = [[UILabel alloc] init];
    self.currentDramaInfoListURLLabel.textColor = [UIColor lightGrayColor];
    self.currentDramaInfoListURLLabel.font = [UIFont systemFontOfSize:10];
    self.currentDramaInfoListURLLabel.textAlignment = NSTextAlignmentLeft;
    self.currentDramaInfoListURLLabel.numberOfLines = 0; // 允许多行
    self.currentDramaInfoListURLLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    // 设置剧集信息选择器
    self.dramaInfoListURLPicker = [[UIPickerView alloc] init];
    self.dramaInfoListURLPicker.backgroundColor = [UIColor darkGrayColor];
    self.dramaInfoListURLPicker.delegate = self;
    self.dramaInfoListURLPicker.dataSource = self;
    
    // 设置构建版本标签
    self.buildVersionLabel = [[UILabel alloc] init];
    self.buildVersionLabel.textColor = [UIColor whiteColor];
    self.buildVersionLabel.font = [UIFont systemFontOfSize:12];
    self.buildVersionLabel.textAlignment = NSTextAlignmentCenter;
    
    // 将所有视图添加到主视图
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.clearCacheButton];
    [self.view addSubview:self.coverImageFallbackLabel];
    [self.view addSubview:self.coverImageFallbackSwitch];
    [self.view addSubview:self.advertisementPageLabel];
    [self.view addSubview:self.advertisementPageSwitch];
    [self.view addSubview:self.playerPoolCapacityLabel];
    [self.view addSubview:self.playerPoolCapacitySwitch];
    [self.view addSubview:self.dramaInfoListURLLabel];
    [self.view addSubview:self.dramaInfoQRButton];
    [self.view addSubview:self.dramaInfoQRLabel];
    [self.view addSubview:self.currentDramaInfoListURLLabel];
    [self.view addSubview:self.dramaInfoListURLPicker];
    [self.view addSubview:self.buildVersionLabel];
    
    // 使用 Auto Layout 设置约束
    [self setConstraints];
}

// UI布局
- (void)setConstraints {
    // 使用 Auto Layout 的约束设置
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.clearCacheButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.coverImageFallbackLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.coverImageFallbackSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    self.advertisementPageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.advertisementPageSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    self.playerPoolCapacityLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.playerPoolCapacitySwitch.translatesAutoresizingMaskIntoConstraints = NO;
    self.dramaInfoListURLLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.dramaInfoQRButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.dramaInfoQRLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.currentDramaInfoListURLLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.dramaInfoListURLPicker.translatesAutoresizingMaskIntoConstraints = NO;
    self.buildVersionLabel.translatesAutoresizingMaskIntoConstraints = NO;

    // 约束激活
    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:[AUIShortVideoListUtils additionalTopPaddingForTabBar]],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        
        // Clear Cache Button
        [self.clearCacheButton.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:20],
        [self.clearCacheButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20],
        
        // Cover Image Fallback Label
        [self.coverImageFallbackLabel.topAnchor constraintEqualToAnchor:self.clearCacheButton.bottomAnchor constant:20],
        [self.coverImageFallbackLabel.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20],
        
        // Cover Image Fallback Switch
        [self.coverImageFallbackSwitch.leftAnchor constraintEqualToAnchor:self.coverImageFallbackLabel.rightAnchor constant:20],
        [self.coverImageFallbackSwitch.centerYAnchor constraintEqualToAnchor:self.coverImageFallbackLabel.centerYAnchor],
        
        
        [self.advertisementPageLabel.topAnchor constraintEqualToAnchor:self.coverImageFallbackLabel.bottomAnchor constant:20],
        [self.advertisementPageLabel.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20],
        
        [self.advertisementPageSwitch.leftAnchor constraintEqualToAnchor:self.advertisementPageLabel.rightAnchor constant:20],
        [self.advertisementPageSwitch.centerYAnchor constraintEqualToAnchor:self.advertisementPageLabel.centerYAnchor],
        
        
        // Player Pool Capacity Label
        [self.playerPoolCapacityLabel.topAnchor constraintEqualToAnchor:self.advertisementPageSwitch.bottomAnchor constant:20],
        [self.playerPoolCapacityLabel.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20],
        
        // Player Pool Capacity Switch
        [self.playerPoolCapacitySwitch.leftAnchor constraintEqualToAnchor:self.playerPoolCapacityLabel.rightAnchor constant:20],
        [self.playerPoolCapacitySwitch.centerYAnchor constraintEqualToAnchor:self.playerPoolCapacityLabel.centerYAnchor],
        
        // Drama Info List URL Label
        [self.dramaInfoListURLLabel.topAnchor constraintEqualToAnchor:self.playerPoolCapacitySwitch.bottomAnchor constant:20],
        [self.dramaInfoListURLLabel.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20],
        
        [self.dramaInfoQRButton.topAnchor constraintEqualToAnchor:self.playerPoolCapacitySwitch.bottomAnchor constant:200],
        [self.dramaInfoQRButton.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-20],
        [self.dramaInfoQRButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20],
        [self.dramaInfoQRButton.heightAnchor constraintEqualToConstant:40], // 设置高度为 40
        
        [self.dramaInfoQRLabel.topAnchor constraintEqualToAnchor:self.playerPoolCapacitySwitch.bottomAnchor constant:245],
        [self.dramaInfoQRLabel.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20],
    
        // Current Drama Info List URL Label
        [self.currentDramaInfoListURLLabel.topAnchor constraintEqualToAnchor:self.dramaInfoListURLLabel.bottomAnchor constant:10],
        [self.currentDramaInfoListURLLabel.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20],
        [self.currentDramaInfoListURLLabel.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-20],
        
        // Picker View
        [self.dramaInfoListURLPicker.topAnchor constraintEqualToAnchor:self.dramaInfoListURLLabel.bottomAnchor constant:40],
        [self.dramaInfoListURLPicker.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20],
        [self.dramaInfoListURLPicker.heightAnchor constraintEqualToConstant:100],
        
        // Build Version Label
        [self.buildVersionLabel.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-20],
        [self.buildVersionLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
    ]];
}


#pragma mark - Control

// 显示 SDK 版本
- (void)loadVersion {
    NSString *sdkVersion = [AliPlayer getSDKVersion];
    self.buildVersionLabel.text = [NSString stringWithFormat:@"Build Version: %@", sdkVersion];
}

// 请求剧集信息列表
- (void)loadDramaInfoList {
    // 使用 AFNetworking 进行请求
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // 设置可以接受的内容类型
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // 创建弱引用，以避免循环引用
    __weak typeof(self) weakSelf = self;
    // GET请求
    [manager GET:kDramaInfoListTotalUrl parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        // 获取强引用
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) { // 确保 strongSelf 仍然存在
            if ([responseObject isKindOfClass:[NSArray class]]) {
                NSArray *dramaInfoList = (NSArray *)responseObject;
                [strongSelf.spinnerArray removeAllObjects]; // 清空选项数组
                [strongSelf.spinnerURLArray removeAllObjects]; // 清空 URL 数组
                
                // 遍历剧集信息并添加标题和 URL
                for (NSDictionary *dramaInfo in dramaInfoList) {
                    [strongSelf.spinnerArray addObject:dramaInfo[@"title"]];
                    [strongSelf.spinnerURLArray addObject:dramaInfo[@"url"]];
                }
                
                // 更新 UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.dramaInfoListURLPicker reloadAllComponents]; // 刷新选择器
                });
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // 打印错误信息
        NSLog(@"Error fetching data: %@", error);
        dispatch_async(dispatch_get_main_queue(), ^{
            // 在主线程显示错误提示
            [AVToastView show:@"获取剧集信息失败，请检查网络" view:weakSelf.view position:AVToastViewPositionBottom];
        });
    }];
}

// 清除缓存
- (void)clearCache {
    [AUIShortVideoListGlobalSetting clearCaches]; // 调用缓存清除方法
    [AVToastView show:@"已清除缓存！" view:self.view position:AVToastViewPositionBottom]; // 提示用户缓存已清除
}

// 封面图兜底策略开关
- (void)coverImageFallbackSwitchChanged:(UISwitch *)sender {
    AUIShortVideoListConstants.enableCoverURLStrategy = sender.isOn; // 更新封面图策略开关状态
    NSString *message = [NSString stringWithFormat:@"封面图兜底策略开关：%@", AUIShortVideoListConstants.enableCoverURLStrategy ? @"YES" : @"NO"];
    [AVToastView show:message view:self.view position:AVToastViewPositionBottom]; // 提示用户策略已更新
}

// 广告页开关
- (void)advertisingBackSwitchChanged:(UISwitch *)sender {
    AUIShortVideoListConstants.enableAdvertisementPage = sender.isOn; // 更新封面图策略开关状态
    NSString *message = [NSString stringWithFormat:@"广告页策略开关：%@", AUIShortVideoListConstants.enableAdvertisementPage ? @"YES" : @"NO"];
    [AVToastView show:message view:self.view position:AVToastViewPositionBottom]; // 提示用户策略已更新
}

// 播放器池实例数切换开关
- (void)playerPoolCapacitySwitchChanged:(UISwitch *)sender {
    AUIShortVideoListConstants.playerPoolCapacity = sender.isOn ? 3 : 2; // 更新播放器池容量
    NSString *message = [NSString stringWithFormat:@"播放器实例数：%ld", (long)AUIShortVideoListConstants.playerPoolCapacity];
    [AVToastView show:message view:self.view position:AVToastViewPositionBottom]; // 提示用户播放器实例数已更新
}


#pragma mark - UIPickerView Delegate & DataSource

// 返回组件数量
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    // 只有一列
    return 1;
}

// 返回选项数量
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    // 返回选项数组的数量
    return self.spinnerArray.count;
}

// 返回对应行的标题
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    // 返回当前行的标题
    return self.spinnerArray[row];
}

// 更新当前剧集信息 URL 标签
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *selectedURL = self.spinnerURLArray[row]; // 获取选中的 URL
    self.currentDramaInfoListURLLabel.text = selectedURL; // 更新标签显示选中的 URL
    
    // 保存选中的剧集信息 URL
    [AUIShortDramaListViewController setDramaInfoURL:selectedURL];
}

// 返回 UILabel 作为行的视图
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = [[UILabel alloc] init]; // 创建 UILabel
    label.text = self.spinnerArray[row]; // 设置文本
    label.textColor = [UIColor whiteColor]; // 设置文本颜色
    label.font = [UIFont systemFontOfSize:12]; // 设置字体大小
    label.textAlignment = NSTextAlignmentCenter; // 设置文本居中对齐
    return label; // 返回 UILabel 作为选项的视图
}

// openQRCode
- (void)openQRCode:(UIButton *)sender {
    NSLog(@"test QRCode");
    __weak typeof(self) weakSelf = self;
    AUIShortQRScanViewController *vc = [[AUIShortQRScanViewController alloc]init];
     vc.scannedTextCallBack = ^(NSString *text) {
         NSLog(@"QRCode Result %@",text);
         if (text.length > 0) {
             [AVToastView show:[NSString stringWithFormat:@"scan result is %@",text] view:weakSelf.view position:AVToastViewPositionBottom];
             [self getJSON:text];
         } else {
             [AVToastView show:[NSString stringWithFormat:@"scan result is null"] view:weakSelf.view position:AVToastViewPositionBottom];
         }
     };
     [self.navigationController pushViewController:vc animated:YES];
}

- (void)getJSON:(NSString *)url {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    __weak typeof(self) weakSelf = self;
    // 获取当前的 JSON 响应序列化器
    AFJSONResponseSerializer *responseSerializer = (AFJSONResponseSerializer *)manager.responseSerializer;

    // 添加对 text/plain 的支持
    responseSerializer.acceptableContentTypes = [responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        // 请求成功的回调
        if ([responseObject isKindOfClass:[NSArray class]]) {
            SLOGE(@"GETJSON SUCCESS: %@",responseObject);
            // 如果数据格式不正确，通过 completed block 返回错误
            [self decodeJson:responseObject];
            return;
        } else {
            SLOGE(@"GETJSON FAIL:%@",responseObject);
        }
//        
        
    }  failure:^(NSURLSessionDataTask *task, NSError *error) {
        // 请求失败的回调
        SLOGE(@"GETJSON Failure: %@", error.localizedDescription);
        [AVToastView show:[NSString stringWithFormat:@"Request Fail :%@",error.localizedDescription] view:weakSelf.view position:AVToastViewPositionBottom];
    }];
}


- (void)decodeJson:(NSArray *)jsonArray{
    __weak typeof(self) weakSelf = self;
    NSMutableArray<AUIShortVideoInfo *> *videoInfoArray = [NSMutableArray array];
    if (jsonArray && jsonArray.count > 0){
        for (NSDictionary *dict in jsonArray) {
            AUIShortVideoInfo *info = [[AUIShortVideoInfo alloc]initWithDict:dict];
//          info.videoId = [jsonArray indexOfObject:dict];
            [videoInfoArray addObject:info];
        }
        
        if (videoInfoArray.count == 0){
            SLOGE(@"VideoInfo data count is 0");
            [AVToastView show:@"Drama Info List size is 0 !!!" view:weakSelf.view position:AVToastViewPositionBottom];
            return;
        }
        AUIShortVideoListViewController *vc = [[AUIShortVideoListViewController alloc] initWithData:[videoInfoArray copy]];
        [vc enableRefresh:false];
        // 使用 UINavigationController 推送新视图控制器
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }
}


@end
