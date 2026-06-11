//
//  AUIShortVideoListGlobalSetting.h
//  AUIShortVideoList
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class AUIShortVideoListGlobalSetting
 * @brief 此类用于管理应用程序的全局配置和缓存。
 * @details 提供了设置全局配置和清除本地缓存的功能，确保应用程序在初始启动或配置更新时能够载入必要的设置，
 *          并支持用户在需要时清除所有本地缓存数据。
 */
@interface AUIShortVideoListGlobalSetting : NSObject

/**
 * @brief 设置全局配置
 * @details 该方法用于初始化并配置应用程序的全局设置，包括缓存配置、网络请求参数等。
 *          调用此方法可以确保应用在启动时已载入所有必要的全局配置，从而为后续的功能实现提供支持。
 * @note 该方法应在应用启动或配置更新时调用，以确保所有设置均已正确应用。
 */
+ (void)setupConfig;

/**
 * @brief 删除全局本地缓存
 * @details 此方法用于清除应用程序的全局本地缓存。调用此方法后，将删除存储在本地的所有缓存数据，
 *          包括文件缓存、图片缓存、以及其他可能存储的临时数据。
 * @note 该操作无法撤销，调用此方法后，重新下载和缓存数据可能会对应用的性能产生暂时影响。
 */
+ (void)clearCaches;

@end

NS_ASSUME_NONNULL_END
