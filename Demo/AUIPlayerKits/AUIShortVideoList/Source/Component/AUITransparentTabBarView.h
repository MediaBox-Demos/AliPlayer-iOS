//
//  AUITransparentTabBarView.h
//  AUIPlayer
//
//  Created by keria on 2024/11/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AUITransparentTabBarView;

/**
 * @class AUITransparentTabBarViewDelegate
 *
 * @brief AUITransparentTabBarView 的代理协议，用于响应选项卡选择事件
 */
@protocol AUITransparentTabBarViewDelegate <NSObject>

/**
 * @brief 当选项卡被选中时调用此方法。
 *
 * @param tabBar 触发事件的 AUITransparentTabBarView 实例
 * @param index 被选中的选项卡索引
 */
- (void)selectedIndexUpdated:(AUITransparentTabBarView *)tabBar didSelectIndex:(NSInteger)index;

@end

/**
 * @class AUITransparentTabBarView
 *
 * @brief 自定义透明选项卡栏视图，用于实现顶部分页导航
 */
@interface AUITransparentTabBarView : UIView

/**
 * @brief 初始化视图，使用选项卡标题数组和代理
 *
 * @param titles 选项卡标题数组
 * @param delegate AUITransparentTabBarViewDelegate 代理
 *
 * @return AUITransparentTabBarView 实例
 */
- (instancetype)initWithTitles:(NSArray<NSString *> *)titles delegate:(id<AUITransparentTabBarViewDelegate>)delegate;

/**
 * @brief 设置选中的选项卡索引
 *
 * @param index 选中的选项卡索引
 */
- (void)setSelectedIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
