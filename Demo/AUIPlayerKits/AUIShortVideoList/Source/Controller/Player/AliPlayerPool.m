//
//  AliPlayerPool.m
//  AUIShortVideoList
//
//  Created by keria on 2024/10/16.
//

#import "AliPlayerPool.h"
#import "AliLinkedHashMap.h"
#import "AUIShortVideoListUtils.h"


// 默认渲染显示模式，保持比例填充，需裁剪
static AVPScalingMode const kDefaultScalingMode = AVP_SCALINGMODE_SCALEASPECTFILL;

@interface AliPlayerPool ()

// 用于管理池使用的引用计数
@property (nonatomic, assign) NSInteger refCount;
// 存储播放器实例的 HashMap
@property (nonatomic, strong) AliLinkedHashMap *playerLinkedHashMap;
// 用于管理播放器实例的串行队列
@property (nonatomic, strong) dispatch_queue_t playerQueue;
// 播放器池中允许的最大 AliPlayer 实例数量
@property (nonatomic, assign) NSInteger kPlayerPoolCapacity;

@end


@implementation AliPlayerPool

#pragma mark - SingleInstance

// 获取单例实例的方法
+ (instancetype)sharedInstance {
    static AliPlayerPool *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AliPlayerPool alloc] init];
        sharedInstance.playerLinkedHashMap = [[AliLinkedHashMap alloc] init];
        sharedInstance.playerQueue = dispatch_queue_create("com.alivc.playerPoolQueue", DISPATCH_QUEUE_SERIAL);
        
        NSLog(@"[init] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
    });
    return sharedInstance;
}

#pragma mark - LifeCycle

// 释放资源的方法
- (void)dealloc {
    NSLog(@"[dealloc] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
}

// 初始化播放器池并增加引用计数
- (void)setup {
    SLOGW(@"[SETUP]: refCount=%ld", self.refCount);
    @synchronized (self) {
        self.refCount++;
        // 如有需要，可以在此处添加其他自定义初始化逻辑
    }
}

// 销毁播放器池，释放资源并减少引用计数
- (void)destroy {
    SLOGW(@"[DESTROY]: refCount=%ld", self.refCount);
    @synchronized (self) {
        if (self.refCount > 0) {
            self.refCount--;
        }
        // 如果引用计数减至零，释放所有播放器实例
        if (self.refCount == 0) {
            [self releasePlayers];
        }
    }
}

#pragma mark - Control

// 根据指定的键从池中获取播放器实例
- (AliPlayer *)acquire:(id<NSCopying>)key {
    @synchronized (self.playerLinkedHashMap) {
        // 尝试检索现有播放器实例
        AliPlayer *player = [self.playerLinkedHashMap objectForKey:key];
        
        if (player) {
            // 复用现有播放器，并重新加入 HashMap 队列
            [self.playerLinkedHashMap removeObjectForKey:key];
            [self.playerLinkedHashMap enqueue:player forKey:key];
            SLOGI(@"[ACQUIRE][REUSE]: %@ -> %@", key, player);
            return player;
        }
        
        // 检查池的容量是否已满
        if (self.playerLinkedHashMap.count >= self.kPlayerPoolCapacity) {
            // 如果已满，则使用 poll 方法逐出最旧的播放器实例
            AliPlayer *oldAliPlayer = [self.playerLinkedHashMap poll];
            SLOGI(@"[ACQUIRE][GC]: %@ -> nil", oldAliPlayer);
            [self destroyAliPlayerInstance:oldAliPlayer];
        }
        
        // 创建新的播放器实例
        player = [self createNewAliPlayerInstance];
        [self.playerLinkedHashMap enqueue:player forKey:key];
        SLOGI(@"[ACQUIRE][CREATE]: %@ -> %@", key, player);
        
        // 断言检测
        [self checkPlayerPoolSize];
        return player;
    }
}

// 将播放器实例回收到池中
- (void)recycle:(id<NSCopying>)key {
    @synchronized (self.playerLinkedHashMap) {
        // 根据给定的键查找播放器实例
        AliPlayer *player = [self.playerLinkedHashMap objectForKey:key];
        // 如果找到，则销毁播放器实例
        [self destroyAliPlayerInstance:player];
        // 从池中移除该实例
        [self.playerLinkedHashMap removeObjectForKey:key];
        SLOGI(@"[RECYCLE]: %@ -> %@", key, player);
    }
}

#pragma mark - PlayerInstance

// 释放池中所有的播放器实例
- (void)releasePlayers {
    @synchronized (self.playerLinkedHashMap) {
        NSArray *allKeys = [self.playerLinkedHashMap allKeys];
        for (id key in allKeys) {
            AliPlayer *player = [self.playerLinkedHashMap objectForKey:key];
            SLOGI(@"[CLEAR]: %@ -> %@", key, player);
            // 销毁每个播放器实例
            [self destroyAliPlayerInstance:player];
        }
        
        // 清空播放器池中的所有对象
        [self.playerLinkedHashMap removeAllObjects];
        
        // 断言检测
        [self checkPlayerPoolSize];
    }
}

// 创建并配置一个新的 AliPlayer 实例
- (AliPlayer *)createNewAliPlayerInstance {
    AliPlayer *player = [[AliPlayer alloc] init];
    SLOGW(@"[player][API][---alloc---], %@", player);
    
    // 设置播放器允许的预渲染选项
    [player setOption:ALLOW_PRE_RENDER valueInt:1];
    
    // 自定义播放器的配置
    AVPConfig *config = [player getConfig];
    // 确保播放停止时清除显示内容
    config.clearShowWhenStop = YES;
    // 开启快切模式后，手动调用 selectTrack 时，都会快速得到响应。
    config.selectTrackBufferMode = 1;
    [player setConfig:config];
    
    // 设置渲染模式
    [player setScalingMode:kDefaultScalingMode];
    return player;
}

// 销毁指定的 AliPlayer 实例，释放其资源
- (void)destroyAliPlayerInstance:(AliPlayer *)player {
    // 确保播放器实例不为 nil
    if (player == nil) {
        SLOGE(@"[ERROR]: Attempt to destroy a nil player!");
        return;
    }
    
    SLOGI(@"[player][API][destroyAsync], %@", player);
    [player destroyAsync];
    
    SLOGW(@"[player][API][---dealloc---], %@ -> nil", player);
    player = nil;
}

#pragma mark - Assert

// 检查播放器池的大小，确保不超过最大容量
- (void)checkPlayerPoolSize {
    NSAssert(self.playerLinkedHashMap.count <= self.kPlayerPoolCapacity, @"Player pool size exceeded. Current count: %lu",
             (unsigned long)self.playerLinkedHashMap.count);
}

- (NSInteger)kPlayerPoolCapacity{
    return [AUIShortVideoListConstants playerPoolCapacity];
}

@end
