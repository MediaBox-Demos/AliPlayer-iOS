//
//  AUIShortVideoInfo.h
//  AUIPlayer
//
//  Created by keria on 2024/11/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class AUIShortVideoInfo
 *
 * @brief 该类用于存储和管理有关视频的信息，包括视频的唯一标识符、资源地址、封面图、作者、标题和类型等详细信息。
 *
 * AUIShortVideoInfo 类封装了与视频相关的各种属性信息，使得视频对象在应用程序中易于创建和使用。
 */
@interface AUIShortVideoInfo : NSObject

/**
 * @brief 视频 ID。
 *
 * 用于唯一标识每个视频资源，便于视频的查找和管理。
 */
@property (nonatomic, assign) NSInteger videoId;

/**
 * @brief 视频源地址。
 *
 * 表示视频文件所在的位置或网络地址。通常是一个 URL，用于指向视频文件资源。支持不同视频格式。
 */
@property (nonatomic, copy) NSString *url;

/**
 * @brief 视频封面图。
 *
 * 用于视频的缩略图显示，通常也是一个 URL，指向封面图像资源。
 */
@property (nonatomic, copy) NSString *coverUrl;

/**
 * @brief 视频作者。
 *
 * 表示视频的上传者或创作者的名称。这是一个字符串，用来显示谁创作了这个视频。
 */
@property (nonatomic, copy) NSString *author;

/**
 * @brief 视频标题。
 *
 * 用于描述视频内容的简短文字。
 */
@property (nonatomic, copy) NSString *title;

/**
 * @brief 视频类型。
 *
 * 用于定义视频所属的类别，比如视频、广告等。
 */
@property (nonatomic, copy) NSString *type;

/**
 * @brief 对象的唯一标识符
 * @details 此属性用于存储对象的全局唯一标识符，确保对象在其生命周期内有唯一的标识。
 *          该标识符通常在对象创建时自动生成，用于识别和追踪特定对象实例。
 *
 * @note 这是一个只读属性，通常在初始化时生成并设置。开发者应确保使用正确的生成算法来防止冲突。
 */
@property (nonatomic, copy, readonly) NSString *uniqueKey;

/**
 * @brief 初始化方法，用给定的字典来设置对象的属性。
 *
 * 该初始化方法通过解析传入的字典来设置视频信息的各个属性，字典中的键名应与属性名相对应。
 *
 * @param dict 包含视频信息的字典，其中的键名应对应于属性名。
 *
 * @return 返回初始化后的 AUIShortVideoInfo 对象。
 *
 * @note 确保字典中的键值对正确以确保AUIShortVideoInfo对象的准确初始化。
 */
- (instancetype)initWithDict:(NSDictionary *)dict;

/**
 * @brief 获取精简版的视频信息字符串
 *
 * @discussion 该方法接收一个 `AUIShortVideoInfo` 对象，并返回该对象的精简版字符串描述。
 *             精简版字符串可能包含视频的基本元数据，如视频标题、时长等关键信息。
 *
 * @param videoInfo 一个 `AUIShortVideoInfo` 对象，包含视频的详细信息。
 *
 * @return 返回代表视频信息的精简版字符串。
 *
 * @note 请确保传入的 `AUIShortVideoInfo` 对象非空，否则返回的字符串可能是空或者无效的。
 */
+ (NSString *)getSlimVideoInfo:(AUIShortVideoInfo *)videoInfo;

@end

NS_ASSUME_NONNULL_END
