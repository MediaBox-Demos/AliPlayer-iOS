//
//  CustomStyleExternalSubtitleViewController.h
//  CustomStyledSubtitle
//
//  Created by 叶俊辉 on 2026/1/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class CustomStyleExternalSubtitleViewController
 * @brief 播放器自定义字幕样式功能演示 - 阿里云播放器 SDK 最佳实践
 *
 * 本示例展示了如何使用阿里云播放器 SDK 实现自定义字幕样式功能，
 * 包括自定义字体加载、字体样式应用、颜色渲染等高级特性
 *
 * ==================== 播放器 API 调用步骤 ====================
 * Step 1: 创建播放器实例
 * - 使用 [[AliPlayer alloc] init] 创建播放器
 * - 设置播放器代理 delegate
 * - 配置播放器基本参数
 * - 配置播放器场景
 *
 * Step 2: 创建自定义字幕视图
 * - 创建 AliVttSubtitleView 实例
 * - 设置自定义渲染工厂 setRenderImplFactory
 * - 在工厂方法中创建 CustomFontVttRenderImpl 实例
 * - 加载自定义字体文件
 * - 调用 setExternalSubtitleView 关联字幕视图到播放器
 *
 * Step 3: 初始化UI视图
 * - 创建播放器视图容器
 * - 设置播放器渲染视图 playerView
 * - 配置视图布局
 *
 * Step 4: 设置播放源
 * - 创建 AVPUrlSource 播放源对象
 * - 调用 setUrlSource: 设置播放地址
 * - 可选(非必需)调用 setStartTime:seekMode: 方法设置起播位置
 *
 * Step 5: 开始播放
 * - 调用 prepare 方法准备播放
 * - 调用 start 方法开始播放
 *
 * Step 6: 播放器状态监听
 * - 实现 AVPDelegate 协议
 * - 实现 onPlayerEvent:eventType: 方法监听播放器事件
 *
 * Step 7: 字幕设置
 * - 在 AVPEventPrepareDone 事件中调用 addExtSubtitle: 方法添加字幕
 * - 在 onSubtitleExtAdded 回调中调用 selectExtSubtitle:enable: 启用字幕
 *
 * Step 8: 设置字幕监听
 * - 实现 onSubtitleExtAdded:trackIndex:URL: 字幕添加回调
 * - 实现 onSubtitleHeader:trackIndex:Header: 字幕头信息回调
 * - 实现 onSubtitleShow:trackIndex:subtitleID:subtitle: 字幕显示回调
 * - 实现 onSubtitleHide:trackIndex:subtitleID: 字幕隐藏回调
 * - 在回调中调用 AliVttSubtitleView 的相应方法进行渲染
 *
 * Step 9: 清理资源
 * - 调用 stop 停止播放
 * - 调用 destroy 销毁播放器实例
 * - 清空对象引用，避免内存泄漏
 *
 * ==================== 自定义字幕渲染特性 ====================
 * - 支持从 Bundle 加载自定义字体文件
 * - 支持从文件路径加载外部字体
 * - 支持根据字幕内容自动选择合适字体(阿拉伯语、CJK等)
 * - 支持字体样式应用(粗体、斜体)
 * - 支持自定义字体颜色渲染
 * - 支持字体大小动态调整
 */
@interface CustomStyleExternalSubtitleViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
