//
//  CommonConstants.h
//  Common
//
//  Created by keria on 2025/6/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class CommonConstants
 *
 * @brief Application constants and configuration values
 * @note 应用常量和配置值
 */
@interface CommonConstants : NSObject

#pragma mark - Schema Constants
/**
 * @brief Schema related constants
 * @note Schema相关常量
 */

// Complete schema URLs
extern NSString *const kSchemaBasicPlayback;
extern NSString *const kSchemaBasicLiveStream;
extern NSString *const kSchemaRtsLiveStream;

extern NSString *const kSchemaThumbnailStream;
extern NSString *const kSchemaExternalSubtitleStream;
extern NSString *const kSchemaPreloadStream;
extern NSString *const kSchemaDownloader;
// URL of the picture in picture Demo
extern NSString *const kSchemaPipDemo;
// URL of the float-window Demo
extern NSString *const kSchemaFloatWindow;
extern NSString *const kSchemaMultiResolution;
#pragma mark - Module Category Constants
/**
 * @brief Module category constants for global consistency
 * @note 模块分类常量，用于全局统一
 */

// Module categories
extern NSString *const kModuleCategoryBasic;
extern NSString *const kModuleCategoryAdvanced;

#pragma mark - Module Info Keys
/**
 * @brief Module info dictionary keys for consistency
 * @note 模块信息字典键值，用于保持一致性
 */

// Module info keys
extern NSString *const kModuleInfoKeyTitle;
extern NSString *const kModuleInfoKeySchema;
extern NSString *const kModuleInfoKeyDescription;
extern NSString *const kModuleInfoKeyCategory;

#pragma mark - Data Source Constants

/**
 * @brief Data source related constants
 * @note 数据源相关常量
 */

// URL of the sample video file
extern NSString *const kSampleVideoURL;
// URL of the sample livestream video file
extern NSString *const kSampleLiveStreamVideoURL;
// URL of the sample switch livestream video file
extern NSString *const kSampleSwitchLiveStreamVideoURL;
// URL of the RTS video file
extern NSString *const kRTSLiveStreamURL;
// URL of the MultiResolution
extern NSString *const kMultiResolutionURL;
// URL of the sample thumbnail
extern NSString *const kSampleThumbnailURL;
// URL of the sample video thumbnail
extern NSString *const kSampleVideoThumbnailURL;
// URL of the sample video external subtitle
extern NSString *const kSampleVideoExternalSubtitleURL;
// URL of the sample external subtitle
extern NSString *const kSampleExternalSubtitleURL;
// URL of the sample video preloadUrl
extern NSString *const kSampleVideoPreloadURL;
// URL of the sample request playAuth
extern NSString *const kSampleRequestUrl;
// Vid of the sample request playAuth
extern NSString *const kSampleRequestVid;

@end

NS_ASSUME_NONNULL_END
