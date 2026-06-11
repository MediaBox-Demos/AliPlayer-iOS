//
//  AUIShortVideoListUtils.h
//  AUIPlayer
//
//  Created by keria on 2024/11/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * const kShortVideoListLogTag = @"ShortVideoList";

#pragma mark - UI

/**
 * @brief 定义透明图像
 *
 * @return UIImage 透明图像
 */
UIImage *TransparentImage(void);

/**
 * @class AUIShortVideoListUtils
 *
 * @brief AUIShortVideoListUtils 类提供了一组实用工具函数，用于支持短剧列表的开发与调试。
 *
 * 该类设计为一组类别方法，包含多种实用功能，比如日志输出、时间测量、数据转换和 URL 验证等。
 * 不需要实例化即可直接调用这些工具方法，以简化开发工作，提高代码的可读取性和可维护性。
 *
 * @note 类所有方法均为类方法，无需创建类实例即可使用。
 */
@interface AUIShortVideoListUtils : NSObject

/**
 * @brief 根据设备的安全区域动态获取顶部Tab Bar需要预留的额外高度。
 *
 * 对于iPhone X及以上具有刘海屏的设备，顶部安全区域通常为44点，预留额外的24点(height = 44 - 20)。
 * 对于旧款无刘海屏的设备，顶部安全区域为20点，不需要额外预留高度(height = 0)。
 *
 * @return 返回需要预留的额外顶部高度。
 *         - 如果设备有刘海屏，返回24.0。
 *         - 如果设备无刘海屏，返回0.0。
 */
+ (CGFloat)additionalTopPaddingForTabBar;

/**
 * @brief 返回选项卡栏的额外顶部填充。
 *
 * @param offset 一个浮点值，表示用于计算额外顶部填充的偏移量。
 *
 * @return CGFloat类型的值，表示计算后的用于选项卡栏的额外顶部填充。
 */
+ (CGFloat)additionalTopPaddingForTabBar:(CGFloat)offset;

#pragma mark - CustomLog

/**
 * @brief 格式化日志信息并打印
 * @param fmt 日志信息格式
 * @param ... 日志信息的参数
 */
#define SLOGI(fmt, ...) NSLog((@"[I][%@][%@:%d]" fmt), kShortVideoListLogTag, NSStringFromClass([self class]), __LINE__, ##__VA_ARGS__)
#define SLOGD(fmt, ...) NSLog((@"[D][%@][%@:%d]" fmt), kShortVideoListLogTag, NSStringFromClass([self class]), __LINE__, ##__VA_ARGS__)
#define SLOGW(fmt, ...) NSLog((@"[W][%@][%@:%d]" fmt), kShortVideoListLogTag, NSStringFromClass([self class]), __LINE__, ##__VA_ARGS__)
#define SLOGE(fmt, ...) NSLog((@"[E][%@][%@:%d]" fmt), kShortVideoListLogTag, NSStringFromClass([self class]), __LINE__, ##__VA_ARGS__)


#pragma mark - TimeProfile

/**
 * @def ENABLE_TIME_PROFILE
 *
 * @brief 用于控制调试时间记录功能的开关宏。
 *
 * 此宏用于启用或禁用调试时间记录相关功能。通过设置该宏，
 * 开发者可以灵活地在调试和发布环境之间切换，以控制性能分析代码的执行。
 *
 * @value 1 启用调试时间记录功能。当此宏被定义为 1 时，时间记录功能有效，
 *                针对函数开始和结束时间进行测量和记录。
 *
 * @value 0 禁用调试时间记录功能。当此宏被定义为 0 时，时间记录功能无效，
 *                相关宏 (`SLOGT` 和 `RESET_START_TIME`) 不执行任何操作。
 *
 * @usage 在调试环境中，设置 `ENABLE_TIME_PROFILE` 为 1，以收集时间性能数据。
 *        在生产或发布环境中，设置此宏为 0，以提高性能并减少不必要的日志输出。
 *
 * @example
 * // 在调试环境中启用时间记录
 * #define ENABLE_TIME_PROFILE 1
 *
 * // 在发布环境中禁用时间记录
 * #define ENABLE_TIME_PROFILE 0
 */
#define ENABLE_TIME_PROFILE 1

/**
 * @brief 打印函数耗时及线程情况（宏定义）
 *
 * 使用该宏记录指定方法的耗时及执行线程信息。通常用于性能分析和调试。
 *
 * @param method 需要记录的函数名
 * @param startTimeMills 方法开始执行的时间（以毫秒为单位）
 *
 * @code
 * // 示例代码
 * // XXX... // 执行需要计时的操作
 * @endcode
 */
#if ENABLE_TIME_PROFILE
    #define SLOGT(method, startTimeMills) \
        do { \
            [AUIShortVideoListUtils timeProfile:method startTime:startTimeMills]; \
        } while (0)
#else
    #define SLOGT(method, startTimeMills) do { } while (0)
#endif

/**
 * @brief 重置当前时间（宏定义）
 *
 * 使用该宏重置并获取当前的时间戳（毫秒），用于记录函数开始执行的时间。
 *
 * @param T 将存储当前时间戳的变量
 *
 * @code
 * // 示例代码
 * @endcode
 */
#if ENABLE_TIME_PROFILE
    #define RESET_START_TIME(T) \
        do { \
            T = [AUIShortVideoListUtils currentTimeMillis]; \
        } while (0)
#else
    #define RESET_START_TIME(T) do { } while (0)
#endif

/**
 * @brief 打印函数耗时及线程情况
 */
+ (void)timeProfile:(NSString *)method startTime:(long)timeMills;

/**
 * @brief 获取当前时间戳（毫秒级）
 * @return 返回当前时间戳（毫秒级）
 */
+ (long)currentTimeMillis;


#pragma mark - DataConverter

/**
 * @brief 将 NSArray 打印为一行字符串
 * @param array 要打印的数组
 * @return 返回数组的字符串表示
 */
+ (NSString *)printArray:(NSArray *)array;

/**
 * @brief 将一个 C 风格的整型数组转换为不可变的 NSArray<NSNumber *>。
 * 该方法接收一个整型数组及其长度，将每个整数元素封装为 NSNumber 对象并存储在一个新的NSArray中。
 * @param windows 一个指向 C 风格整型数组的指针，包含要转换的整数值。
 * @param length 整型数组的长度，指明数组中元素的数量。
 * @return 返回一个包含 NSNumber 对象的不可变 NSArray，代表输入的整数数组。
 */
+ (NSArray<NSNumber *> *)convertToNSArray:(const int [_Nonnull])windows withLength:(NSUInteger)length;

#pragma mark - FileUtility

/**
 * 确保指定路径下的目录存在。如果目录不存在，则尝试创建此目录并创建所有必需的中间目录。
 *
 * @param path 要检查或创建的目录路径。该路径必须是文件系统上有效的路径，并且是在其中可以创建目录的路径。
 * @param error 如果创建目录时发生错误，此参数将返回一个NSError对象包含错误信息。如果不需要错误信息，可以传递NULL。
 *
 * @return 如果目录已经存在或成功创建，则返回YES。如果在尝试创建目录时发生错误，则返回NO，此时error参数包含更多的错误信息。
 *
 * @note 此方法会创建指定的完整目录路径，包括任何不存在的中间目录。如果目录已经存在，此方法不会修改它并直接返回YES。
 */
+ (BOOL)ensureDirectoryExistsAtPath:(NSString *)path error:(NSError **)error;

#pragma mark - Others

/**
 * @brief 检查给定的字符串是否是有效的 URL
 * @param urlString 要检查的 URL 字符串
 * @return 如果 URL 字符串有效则返回 YES；否则返回 NO。
 */
+ (BOOL)isValidURLString:(NSString *)urlString;

@end

NS_ASSUME_NONNULL_END
