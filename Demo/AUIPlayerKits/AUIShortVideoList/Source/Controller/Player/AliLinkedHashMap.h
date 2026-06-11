//
//  AliLinkedHashMap.h
//  AUIShortVideoList
//
//  Created by keria on 2024/10/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class AliLinkedHashMap
 *
 * @brief 该类结合了哈希表和链表的特点，支持以插入顺序维护键值对，并实现高效的查找、插入和删除操作。
 */
@interface AliLinkedHashMap : NSObject

#pragma mark - Control

/**
 * @brief 使用指定的键将对象添加到映射中；如果键已存在，则更新其对应的对象
 * @param object 需要添加或更新的对象
 * @param key 唯一标识该对象的键
 */
- (void)enqueue:(id)object forKey:(id<NSCopying>)key;

/**
 * @brief 检索并移除映射中的第一个对象（FIFO）
 * @return 返回并移除映射中的第一个对象；如果映射为空，则返回 nil。
 */
- (id)poll;

/**
 * @brief 检索并移除映射中的最后一个对象（LIFO）
 * @return 返回并移除映射中的最后一个对象；如果映射为空，则返回 nil。
 */
- (id)pop;

/**
 * @brief 从映射中移除指定的对象
 * @param object 需要移除的对象
 */
- (void)removeObject:(id)object;

/**
 * @brief 移除与指定键关联的对象
 * @param key 唯一标识需要移除对象的键
 */
- (void)removeObjectForKey:(id)key;

/**
 * @brief 移除映射中的所有对象
 * @note 调用此方法后映射将被清空。
 */
- (void)removeAllObjects;

#pragma mark - Traverse

/**
 * @brief 检索与指定键关联的对象
 * @param key 唯一标识目标对象的键
 * @return 返回与指定键关联的对象；如果未找到，则返回 nil。
 */
- (id)objectForKey:(id)key;

/**
 * @brief 检索与指定对象关联的键
 * @param object 目标对象
 * @return 返回与指定对象关联的键；如果未找到，则返回 nil。
 */
- (id)keyForObject:(id)object;

/**
 * @brief 返回映射中的所有键的数组
 * @return 返回包含所有键的数组
 */
- (NSArray *)allKeys;

/**
 * @brief 返回映射中的所有值的数组
 * @return 返回包含所有值的数组
 */
- (NSArray *)allValues;

/**
 * @brief 返回映射中键值对的数量
 * @return 返回映射中的键值对总数
 */
- (NSUInteger)count;

@end

NS_ASSUME_NONNULL_END
