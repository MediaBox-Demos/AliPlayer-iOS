//
//  AUIShortVideoListController.m
//  AUIPlayer
//
//  Created by keria on 2024/11/13.
//

#import "AUIShortVideoListController.h"
#import "AUIShortVideoListGlobalSetting.h"
#import "AliPlayerPool.h"
#import "AliPlayerPreload.h"
#import "AUIShortVideoListUtils.h"

@interface AUIShortVideoListController ()

// 阿里播放器池的实例，负责管理共享多个播放器实例
@property (nonatomic, strong) AliPlayerPool *aliPlayerPool;

// 视频预加载器的实例，用于预加载视频内容
@property (nonatomic, strong) AliPlayerPreload *aliPreloader;

// 当前播放的位置
@property (nonatomic, assign) NSInteger currentPosition;

@end

@implementation AUIShortVideoListController

#pragma mark - LifeCycle

// 初始化播放器相关实例
- (instancetype)init {
    self = [super init];
    
    if (self) {
        // 初始化全局设置
        [AUIShortVideoListGlobalSetting setupConfig];
        
        // 创建播放器池
        self.aliPlayerPool = [AliPlayerPool sharedInstance];
        
        // 创建视频预加载器
        self.aliPreloader = [[AliPlayerPreload alloc] init];
        
        // 初始化播放位置为无效值
        self.currentPosition = -1;
        
        NSLog(@"[init] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
        
        // NOTE: @keria, 实测此处耗时：第一次初始化大约 9ms 左右，后面初始化大约 1~2ms；
        // 第一次初始化耗时较大的原因在 setupSDWebImageConfig 方法，约占 7ms 左右；
    }
    
    return self;
}

// 释放资源的方法
- (void)dealloc {
    [self destroy];
    
    NSLog(@"[dealloc] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - API Methods

// 初始化播放器及其资源。
- (void)setup {
    SLOGI(@"[setup]");
    
    // 初始化播放器池
    if (_aliPlayerPool) {
        [_aliPlayerPool setup];
    }
    
    // 初始化视频预加载器
    if (_aliPreloader) {
        [_aliPreloader setup];
    }
}

// 销毁并清理播放器相关资源。
- (void)destroy {
    SLOGI(@"[destroy]");
    
    // 销毁播放器池
    if (_aliPlayerPool) {
        [_aliPlayerPool destroy];
        _aliPlayerPool = nil;
    }
    
    // 销毁视频预加载器
    if (_aliPreloader) {
        [_aliPreloader destroy];
        _aliPreloader = nil;
    }
    
    self.currentPosition = -1;
}

// 移动浮标到指定位置。
- (void)moveTo:(NSInteger)position {
    SLOGW(@"[moveTo]: [%ld->%ld]", _currentPosition, position);
    
    if (_currentPosition == position) {
        return; // 如果目标位置与当前相同，无需移动
    }
    
    _currentPosition = position;
    
    if (_aliPreloader) {
        [_aliPreloader moveTo:position];
    }
}

// 设置带宽值。
- (void)setBandwidth:(NSInteger)bandwidth {
    if (_aliPreloader) {
        [_aliPreloader setBandwidth:bandwidth];
    }
}

// 设置替换视频资源列表。
- (void)loadSources:(NSArray<AUIShortVideoInfo *> *)videoInfoList {
    SLOGI(@"[loadSources]: [%ld]", videoInfoList ? videoInfoList.count : -1);
    
    if (_aliPreloader) {
        [_aliPreloader setItems:videoInfoList];
    }
}

// 添加更多视频资源到既有列表中。
- (void)addSources:(NSArray<AUIShortVideoInfo *> *)videoInfoList {
    SLOGI(@"[addSources]: [%ld]", videoInfoList ? videoInfoList.count : -1);
    
    if (_aliPreloader) {
        [_aliPreloader addItems:videoInfoList];
    }
}

@end
