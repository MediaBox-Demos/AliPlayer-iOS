//
//  AUIShortDramaDetailView.h
//  AUIPlayer
//
//  Created by keria on 2024/11/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 定义一个 block 类型，用来处理视图点击事件
typedef void (^AUIShortDramaDetailViewTapHandler)(void);

/**
 * @class AUIShortDramaDetailView
 *
 * @brief 该类用于短剧剧场场景-推荐页，显示短剧详情的自定义底部栏
 *
 * AUIShortDramaDetailView 是一个自定义 UIView，用于展示短剧的图标、标题以及继续观看的引导提示。
 */
@interface AUIShortDramaDetailView : UIView

/**
 * @brief 初始化视图，并设置点击事件回调。
 *
 * @param frame 视图的初始大小和位置。
 * @param tapHandler 点击事件发生时执行的回调 block。可以为 nil，此时不执行任何操作。
 *
 * @return AUIShortDramaDetailView 实例。
 *
 * 此初始化方法允许在实例化 AUIShortDramaDetailView 时，提供一个回调
 * block 用于处理视图上的点击事件。回调 block 在视图接收到点击手势时被触发。
 */
- (instancetype)initWithFrame:(CGRect)frame tapHandler:(_Nullable AUIShortDramaDetailViewTapHandler)tapHandler;

@end

NS_ASSUME_NONNULL_END
