//
//  FloatWindowView.h
//  FloatWindow
//
//  Created by aqi on 2025/6/24.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * @class FloatWindowView
 * @brief 悬浮窗功能演示 - 阿里云播放器 SDK 最佳实践
 *
 * 本示例展示了如何使用阿里云播放器 SDK 实现悬浮窗的功能
 *
 * ==================== 前提条件 ====================
 * 1. 配置 License：确保已在 AppDelegate 中配置有效的播放器 License
 * 2. 网络权限：确保应用具有网络访问权限
 * 3. SDK 集成：确保已正确集成阿里云播放器 SDK
 * 4. 播放源：确保视频 URL 可访问且格式支持
 *
 * ==================== 播放器 API 调用步骤 ====================
 * Step 1: 创建播放器实例
 *         - 使用 [[AliPlayer alloc] init] 创建播放器
 *         - 设置播放器渲染视图 playerView
 *         - 配置播放器基本参数
 *
 * Step 2: 设置播放源
 *         - 创建 AVPUrlSource 播放源对象
 *         - 调用 setUrlSource: 设置播放地址
 *
 * Step 3: 开始播放
 *         - 调用 prepare 方法准备播放
 *         - 调用 start 方法开始播放
 *
 * Step 4: 资源清理
 *         - 调用 stop 停止播放
 *         - 调用 destroy 销毁播放器实例
 *         - 清空相关引用，避免内存泄漏
 *
 * ==================== 注意事项 ====================
 * - 播放器实例必须在主线程中创建和操作
 * - 务必在 dealloc 中正确清理播放器资源
 * - 播放器视图需要正确设置 frame 或约束
 * - 建议监听播放器状态变化和错误事件
 *
 * ==================== 使用示例 ====================
 * @code
 * // 1. 创建播放器实例
 * self.player = [[AliPlayer alloc] init];
 * self.player.playerView = self.playerView;
 *
 * // 2. 设置播放源&&准备播放
 * AVPUrlSource *urlSource = [[AVPUrlSource alloc] urlWithString:videoURL];
 * [self.player setUrlSource:urlSource];
 * [self.player prepare];
 *
 * // 3. 将视图添加到 UIWindow ,播放器开始播放
 * self.keyWindow = [UIApplication sharedApplication].keyWindow;
 * self.keyWindow.windowLevel = UIWindowLevelAlert + 1;
 * if (@available(iOS 13.0, *)) {
 *     UIWindowScene *windowScene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
 *     self.keyWindow.windowScene = windowScene;
 * }
 * if (![self.keyWindow.subviews containsObject:self]) {
 *    [self.keyWindow addSubview:self];
 * }
 *
 * [self.player start];
 *
 * // 4、移除视图&&暂停播放
 * [self.player pause];
 * [self removeFromSuperview];
 *
 *
 * // 5. 资源清理
 * [self.player stop];
 * [self.player destroy];
 * self.player = nil;
 * @endcode
 */
@interface FloatWindowView : UIView

// 初始化悬浮窗
- (instancetype)initWithFrame:(CGRect)frame;
// 显示悬浮窗
- (void)show;
// 隐藏悬浮窗
- (void)hide;
// 销毁悬浮窗
- (void)destroy;

@end

NS_ASSUME_NONNULL_END
