//
//  AUIDramaInfo.h
//  AUIPlayer
//
//  Created by keria on 2024/11/7.
//

#import <Foundation/Foundation.h>
#import "AUIShortVideoInfo.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @class AUIShortDramaInfo
 *
 * @brief 该类用于存储和管理有关剧集的信息。这包括剧集的唯一标识符、标题、封面、首集信息及剧集列表等详细信息。
 *
 * AUIShortDramaInfo 类提供了与剧集相关的各种属性，以便在应用程序中创建和使用剧集对象。
 */
@interface AUIShortDramaInfo : NSObject

/**
 * @brief 剧集 ID。
 *
 * 用于唯一标识每个剧集，便于查找和管理该剧集。
 */
@property (nonatomic, assign) NSInteger dramaId;

/**
 * @brief 剧集标题。
 *
 * 用于描述剧集内容的简短标题信息。
 */
@property (nonatomic, copy) NSString *title;

/**
 * @brief 剧集封面。
 *
 * 用于显示剧集的封面图像，通常是一个 URL，指向图像资源。
 */
@property (nonatomic, copy) NSString *cover;

/**
 * @brief 剧集首集。
 *
 * `AUIShortVideoInfo` 类型的对象，表示该剧集的第一集信息。
 */
@property (nonatomic, strong) AUIShortVideoInfo *firstDrama;

/**
 * @brief 剧集列表。
 *
 * 包含 `AUIShortVideoInfo` 对象的可变数组，表示剧集内所有视频信息。
 */
@property (nonatomic, strong) NSMutableArray<AUIShortVideoInfo *> *dramas;

/**
 * @brief 初始化方法，用给定的字典来设置对象的属性。
 *
 * 该方法通过解析传入的字典来设置剧集信息的各个属性，字典中的键名应与属性名相对应。确保在字典中提供有效的数据。
 *
 * @param dict 包含剧集信息的字典，其中的键名应对应于属性名。
 *
 * @return 返回初始化后的 AUIShortDramaInfo 对象。
 */
- (instancetype)initWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
