//
//  AliLinkedHashMap.m
//  AUIShortVideoList
//
//  Created by keria on 2024/10/22.
//

#import "AliLinkedHashMap.h"

@interface AliLinkedHashMap ()

// 存储键值对的字典
@property (nonatomic, strong) NSMutableDictionary *dict;
// 用于维护键的插入顺序的数组
@property (nonatomic, strong) NSMutableArray *keys;

@end

@implementation AliLinkedHashMap

#pragma mark - LifeCycle

// 初始化 AliLinkedHashMap 实例并设置内部结构
- (instancetype)init {
    if (self = [super init]) {
        _dict = [[NSMutableDictionary alloc] init];
        _keys = [[NSMutableArray alloc] init];
        
        NSLog(@"[init] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
    }
    return self;
}

// 释放 AliLinkedHashMap 实例并清空所有存储的对象
- (void)dealloc {
    [self removeAllObjects];
    
    NSLog(@"[dealloc] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
}

#pragma mark - Control

// 使用指定的键将对象添加到映射中；若键已存在，则更新对应的对象
- (void)enqueue:(id)object forKey:(id<NSCopying>)key {
    @synchronized (self) {
        NSAssert(key != nil, @"Key cannot be nil");
        NSAssert(object != nil, @"Object cannot be nil");
        
        // 如果键不在键数组中，则添加该键
        if (![self.dict objectForKey:key]) {
            [self.keys addObject:key];
        }
        // 在字典中添加或更新对象
        [self.dict setObject:object forKey:key];
    }
}

// 检索并移除映射中的第一个对象（FIFO）
- (id)poll {
    @synchronized (self) {
        if (self.keys.count == 0) {
            return nil;
        }
        
        id firstKey = self.keys.firstObject;
        id firstValue = [self.dict objectForKey:firstKey];
        
        [self removeObjectForKey:firstKey];
        return firstValue;
    }
}

// 检索并移除映射中的最后一个对象（LIFO）
- (id)pop {
    @synchronized (self) {
        if (self.keys.count == 0) {
            return nil;
        }
        
        id lastKey = self.keys.lastObject;
        id lastValue = [self.dict objectForKey:lastKey];
        
        [self removeObjectForKey:lastKey];
        return lastValue;
    }
}

// 根据对象的值从映射中移除该对象
- (void)removeObject:(id)object {
    @synchronized (self) {
        // 查找与对象对应的键的索引
        NSUInteger index = [self.keys indexOfObjectPassingTest:^BOOL(id key, NSUInteger idx, BOOL *stop) {
            return [[self.dict objectForKey:key] isEqual:object];
        }];
        
        // 如果找到了对应的键，移除该键及其关联的值
        if (index != NSNotFound) {
            id keyToRemove = self.keys[index];
            [self.keys removeObjectAtIndex:index];
            [self.dict removeObjectForKey:keyToRemove];
        }
    }
}

// 移除与指定键关联的对象
- (void)removeObjectForKey:(id<NSCopying>)key {
    @synchronized (self) {
        // 检查指定键是否存在
        if ([self.dict objectForKey:key]) {
            [self.keys removeObject:key];
            [self.dict removeObjectForKey:key];
        }
    }
}

// 移除映射中的所有对象
- (void)removeAllObjects {
    @synchronized (self) {
        [self.dict removeAllObjects];
        [self.keys removeAllObjects];
    }
}

#pragma mark - Traverse

// 获取与指定键关联的对象
- (id)objectForKey:(id<NSCopying>)key {
    @synchronized (self) {
        return [self.dict objectForKey:key];
    }
}

// 查找与指定对象对应的键
- (id)keyForObject:(id)object {
    @synchronized (self) {
        NSUInteger index = [self.keys indexOfObjectPassingTest:^BOOL(id key, NSUInteger idx, BOOL *stop) {
            return [[self.dict objectForKey:key] isEqual:object];
        }];
        
        // 如果存在，返回对应的键；否则返回 nil
        return (index != NSNotFound) ? self.keys[index] : nil;
    }
}

// 返回映射中的所有键的数组
- (NSArray *)allKeys {
    @synchronized (self) {
        return [self.keys copy];
    }
}

// 返回映射中的所有值的数组
- (NSArray *)allValues {
    @synchronized (self) {
        NSMutableArray *values = [NSMutableArray arrayWithCapacity:self.keys.count];
        for (id key in self.keys) {
            [values addObject:[self.dict objectForKey:key]];
        }
        return [values copy];
    }
}

// 返回映射中键值对的数量
- (NSUInteger)count {
    @synchronized (self) {
        return self.dict.count;
    }
}

@end
