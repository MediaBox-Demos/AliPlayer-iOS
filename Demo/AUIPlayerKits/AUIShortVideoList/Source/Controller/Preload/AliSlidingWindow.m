//
//  AliSlidingWindow.m
//  AUIShortVideoList
//
//  Created by keria on 2024/10/16.
//

#import "AliSlidingWindow.h"

// 方法锁名称
static NSString * const kMethodLockName = @"com.alivc.slidingwindow.lock";


@interface AliSlidingWindow ()

// 存储数据的列表
@property (nonatomic, strong) NSMutableArray<NSObject *> *itemList;
// 存储已执行项的集合
@property (nonatomic, strong) NSMutableSet<NSObject *> *executedItemSets;

// 委托属性，用于通知 delegate
@property (nonatomic, weak) id<AliSlidingWindowDelegate> delegate;

// 窗口数组
@property (nonatomic, copy) NSArray<NSNumber *> *windowItems;

// 附加信息
@property (nonatomic, assign) ExtraType extraType;

// 用于线程安全的方法锁
@property (nonatomic, strong) NSLock *lock;

// 当前窗口的位置
@property (nonatomic, assign) NSInteger currentPosition;

@end


@implementation AliSlidingWindow

#pragma mark - LifeCycle

// 使用给定的数据源初始化 AliSlidingWindow 实例
- (instancetype)initWithLeftWindowSize:(NSInteger)leftWindowSize rightWindowSize:(NSInteger)rightWindowSize eventObserver:(id<AliSlidingWindowDelegate>)delegate extraType:(ExtraType)extraType {
    self = [super init];
    if (self) {
        _windowItems = [self getWindowRangeWithLeft:leftWindowSize right:rightWindowSize];
        [self commonInit:delegate extraType:extraType];
    }
    return self;
}

// 初始化 AliSlidingWindow 实例
- (instancetype)initWithItems:(NSArray<NSNumber *> *)items eventObserver:(id<AliSlidingWindowDelegate>)delegate extraType:(ExtraType)extraType {
    self = [super init];
    if (self) {
        _windowItems = items;
        [self commonInit:delegate extraType:extraType];
    }
    return self;
}

// 释放资源的方法
- (void)dealloc {
    NSLog(@"[dealloc] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
}

// 销毁实例并释放资源
- (void)destroy {
    [self cancelAll];
    
    _currentPosition = -1;
}

// 初始化公共部分
- (void)commonInit:(id<AliSlidingWindowDelegate>)delegate
         extraType:(ExtraType)extraType {
    _itemList = [NSMutableArray array];
    _executedItemSets = [NSMutableSet set];
    
    _delegate = delegate;
    _extraType = extraType;
    
    _lock = [[NSLock alloc] init];
    _lock.name = kMethodLockName;
    
    _currentPosition = -1;
    
    NSLog(@"[init] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
}

// 获取窗口范围
- (NSArray<NSNumber *> *)getWindowRangeWithLeft:(NSInteger)left right:(NSInteger)right {
    NSMutableArray<NSNumber *> *range = [NSMutableArray array];
    NSInteger totalSize = left + right + 1;
    for (NSInteger i = 0; i < totalSize; i++) {
        [range addObject:@(i - left)];
    }
    return [range copy];
}

#pragma mark - DataSource

// 设置替换数据源
- (void)setItems:(NSArray<NSObject *> *)items {
    [self cancelAll];
    
    NSMutableArray *validItems = [NSMutableArray array];
    for (NSObject* item in items) {
        if ([self isValid:item]) {
            [validItems addObject:item];
        }
    }
    
    [_lock lock];
    [_itemList setArray:validItems];
    [_lock unlock];
}

// 添加数据源
- (void)addItems:(NSArray<NSObject *> *)items {
    NSMutableArray *validItems = [NSMutableArray array];
    for (NSObject* item in items) {
        if ([self isValid:item]) {
            [validItems addObject:item];
        }
    }
    
    [_lock lock];
    [_itemList addObjectsFromArray:validItems];
    [_lock unlock];
}

#pragma mark - Control

// 移动到指定位置
- (void)moveTo:(NSInteger)position {
    // 超出范围则返回
    if (position < 0 || position >= _itemList.count) {
        return;
    }
    
    // 未变化直接返回
    if (_currentPosition == position) {
        return;
    }
    
    NSArray<NSObject *> *currentWindow = [self getWindowIndicesForPosition:position];
    NSArray<NSObject *> *previousWindow = [self getWindowIndicesForPosition:_currentPosition];
    
    NSMutableArray<NSObject *> *toLoad = [NSMutableArray arrayWithArray:currentWindow];
    if (_currentPosition >= 0) {
        [toLoad removeObjectsInArray:previousWindow];
    }
    
    NSMutableArray<NSObject *> *toCancel = [NSMutableArray arrayWithArray:previousWindow];
    [toCancel removeObjectsInArray:currentWindow];
    
    [self cancelItems:toCancel];
    [self executeItems:toLoad];
    
    _currentPosition = position;
}

// 获取当前窗口的索引
- (NSArray<NSObject *> *)getWindowIndicesForPosition:(NSInteger)position {
    NSMutableArray<NSObject *> *windowIndices = [NSMutableArray array];
    [_lock lock];
    
    for (NSNumber *offset in _windowItems) {
        NSInteger index = position + offset.integerValue;
        if (index >= 0 && index < _itemList.count) {
            [windowIndices addObject:_itemList[index]];
        }
    }
    
    [_lock unlock];
    return [windowIndices copy];
}

// 取消指定数据集合
- (void)cancelItems:(NSArray<NSObject *> *)items {
    NSMutableArray *toCancel = [NSMutableArray array];
    for (NSObject* item in items) {
        if (item && [_executedItemSets containsObject:item]) {
            [_executedItemSets removeObject:item];
            [toCancel addObject:item];
        }
    }
    
    if (toCancel.count <= 0) {
        return;
    }
    
    for (NSObject *item in toCancel) {
        if (_delegate && [_delegate respondsToSelector:@selector(cancel:from:)]) {
            [_delegate cancel:item from:self];
        }
    }
}

// 取消单个数据
- (void)cancelItem:(NSObject *)item {
    if (item && [_executedItemSets containsObject:item]) {
        [_executedItemSets removeObject:item];
        if (_delegate && [_delegate respondsToSelector:@selector(cancel:from:)]) {
            [_delegate cancel:item from:self];
        }
    }
}

// 执行指定数据集合
- (void)executeItems:(NSArray<NSObject *> *)items {
    NSMutableArray *toExecute = [NSMutableArray array];
    for (NSObject* item in items) {
        if (item && ![_executedItemSets containsObject:item]) {
            [_executedItemSets addObject:item];
            [toExecute addObject:item];
        }
    }
    
    if (toExecute.count <= 0) {
        return;
    }
    
    for (NSObject *item in toExecute) {
        if (_delegate && [_delegate respondsToSelector:@selector(execute:from:)]) {
            [_delegate execute:item from:self];
        }
    }
}

// 执行单个数据
- (void)executeItem:(NSObject *)item {
    if (item && ![_executedItemSets containsObject:item]) {
        [_executedItemSets addObject:item];
        if (_delegate && [_delegate respondsToSelector:@selector(execute:from:)]) {
            [_delegate execute:item from:self];
        }
    }
}

// 取消所有数据
- (void)cancelAll {
    [_lock lock];
    [_itemList removeAllObjects];
    [_lock unlock];
    
    [self cancelItems:[_executedItemSets allObjects]];
    
    NSAssert(_executedItemSets.count == 0, @"Executed item set should be empty after cancel. Current count: %lu",
             (unsigned long)_executedItemSets.count);
}

// 验证数据的有效性
- (BOOL)isValid:(NSObject *)item {
    if (_delegate && [_delegate respondsToSelector:@selector(isValid:from:)]) {
        return [_delegate isValid:item from:self];
    }
    return YES;
}

// 刷新当前窗口的 execute 和 cancel 回调
- (void)refresh {
    // 获取当前窗口的所有项
    NSArray<NSObject *> *currentWindow = [self getWindowIndicesForPosition:_currentPosition];
    
    // 如果窗口为空，则无需刷新
    if (currentWindow.count == 0) {
        return;
    }
    
    // 取消当前窗口的所有项
    [self cancelItems:currentWindow];
    
    // 重新执行当前窗口的所有项
    [self executeItems:currentWindow];
}

@end
