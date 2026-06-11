//
//  AliSlidingWindow.h
//  AUIShortVideoList
//
//  Created by keria on 2024/10/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @enum ExtraType
 * @brief 额外类型枚举，用于区分不同的资源类型
 *
 * 该枚举用于指示多媒体资源的类型，包括视频和封面信息。
 */
typedef NS_ENUM(NSUInteger, ExtraType) {
    /**
     * @brief 媒体类型
     *
     * 表示普通视频内容。
     */
    ExtraTypeMedia = 0,
    
    /**
     * @brief 封面类型
     *
     * 表示视频的封面图像。
     */
    ExtraTypeCover,
};

/**
 * @class AliSlidingWindowDelegate
 *
 * @brief 协议，定义了执行、取消和验证滑动窗口中数据项操作的方法，以便在 AliSlidingWindow 类中实现自定义处理逻辑。
 */
@protocol AliSlidingWindowDelegate <NSObject>

/**
 * @brief 执行指定的操作。
 *
 * @param item 要执行的操作所需的项。
 * @param slidingWindow 当前的 AliSlidingWindow 实例，指示哪个实例调用此方法。
 *
 * @discussion 在实现此方法时，可以根据具体逻辑处理 item 。
 */
- (void)execute:(id)item from:(id)slidingWindow;

// 可选的方法
@optional

/**
 * @brief 取消指定的操作。
 *
 * @param item 要取消的项。
 * @param slidingWindow 当前的 AliSlidingWindow 实例，指示哪个实例调用此方法。
 *
 * @discussion 实现此方法以支持取消可能正在执行的操作。
 */
- (void)cancel:(id)item from:(id)slidingWindow;

/**
 * @brief 验证指定的项是否有效。
 *
 * @param item 要验证的项。
 * @param slidingWindow 当前的 AliSlidingWindow 实例，指示哪个实例调用此方法。
 *
 * @return 返回 YES 如果项有效，否则返回 NO。
 *
 * @discussion 通过实现此方法，可以在进行操作前检查项的有效性。
 */
- (BOOL)isValid:(id)item from:(id)slidingWindow;

@end

/**
 * @class AliSlidingWindow
 *
 * @brief 实现一个滑动窗口的功能，用于管理和处理待执行的数据操作。
 *
 * @note 它通常在视频播放器和数据流处理中用于管理一组有限的数据项（如视频片段、音频流、图像等），
 * @note 其关键功能包括执行、取消和验证操作。这种滑动窗口模式可以帮助应用程序高效地处理数据，避免不必要的内存占用和资源浪费
 */
@interface AliSlidingWindow : NSObject

#pragma mark - LifeCycle

/**
 * @brief 初始化 AliSlidingWindow 实例。
 *
 * @param leftWindowSize 左窗口的大小，表示在执行操作时允许的最大数据个数。
 * @param rightWindowSize 右窗口的大小，表示在执行操作时允许的后续数据个数。
 * @param delegate 事件观察者，负责回调操作。
 * @param extraType 附加参数，用于标识预加载器类型。
 *
 * @return 初始化后的 AliSlidingWindow 实例。
 *
 * @discussion 使用此初始化方法可以定义左侧和右侧窗口的大小以调整窗口的操作范围。
 */
- (instancetype)initWithLeftWindowSize:(NSInteger)leftWindowSize
                       rightWindowSize:(NSInteger)rightWindowSize
                         eventObserver:(id<AliSlidingWindowDelegate>)delegate
                             extraType:(ExtraType)extraType;

/**
 * @brief 使用给定的数据源初始化 AliSlidingWindow 实例。
 *
 * @param items 初始化时的数据源，数组中的类型为 NSNumber。
 * @param delegate 事件观察者，负责回调操作。
 * @param extraType 附加参数，用于标识预加载器类型。
 *
 * @return 初始化后的 AliSlidingWindow 实例。
 *
 * @discussion 使用此初始化方法可以快速建立一个包含特定数据源的滑动窗口。
 */
- (instancetype)initWithItems:(NSArray<NSNumber *> *)items
                eventObserver:(id<AliSlidingWindowDelegate>)delegate
                    extraType:(ExtraType)extraType;

/**
 * @brief 销毁实例并释放资源。
 *
 * @discussion 当不再使用该实例时，应调用此方法以确保资源的正确释放，避免内存泄漏。
 */
- (void)destroy;

#pragma mark - DataSource

/**
 * @brief 设置替换数据源。
 *
 * @param items 要替换的数据源数组，数组中的对象类型为 NSObject。
 *
 * @discussion 此方法会将当前数据源替换为新的数据源。需要注意的是，替换后之前的数据将不再可访问。
 */
- (void)setItems:(NSArray<NSObject *> *)items;

/**
 * @brief 添加数据源。
 *
 * @param items 要添加的数据源数组，数组中的对象类型为 NSObject。
 *
 * @discussion 此方法会将给定的数据源附加到现有数据源中，适用于增量数据更新。
 */
- (void)addItems:(NSArray<NSObject *> *)items;

#pragma mark - Control

/**
 * @brief 移动到指定位置。
 *
 * @param position 要移动到的目标位置的索引。
 *
 * @discussion 此方法使滑动窗口移动到指定位置，并执行必要的操作；如果目标位置超出数据范围，则不会进行任何操作。
 */
- (void)moveTo:(NSInteger)position;

/**
 * @brief 刷新当前窗口的 execute 和 cancel 回调。
 *
 * @discussion 该方法会取消当前窗口的所有项，然后重新执行这些项。
 */
- (void)refresh;

@end

NS_ASSUME_NONNULL_END
