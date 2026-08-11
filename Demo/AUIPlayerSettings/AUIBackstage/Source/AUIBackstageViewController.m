//
//  AUIBackstageViewController.m
//  AUIPlayer
//
//  Created by keria on 2024/11/6.
//

#import "AUIBackstageViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "AUIShortVideoInfo.h"
#import "AUIShortVideoListViewController.h"

@interface AUIBackstageViewController ()

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

// 构建版本标签
@property (nonatomic, strong) UILabel *buildVersionLabel;

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
    
    // 设置 UI 组件
    [self setupViews];
    
    // 加载 SDK 版本
    [self loadVersion];
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

@end
