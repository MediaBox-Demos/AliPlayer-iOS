//
//  RtsLiveStreamViewController.h
//  RtsLiveStream
//
//  Created by aqi on 2025/6/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * @class RtsLiveStreamViewController
 * @brief RTS 低延迟直播功能演示 - 阿里云播放器 SDK 最佳实践
 *
 * 本示例展示了如何使用阿里云播放器 SDK 实现RTS 低延迟直播播放功能
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
 * ==================== RTS 集成文档 ====================
 * 想要了解更多集成文档信息，可以访问文档地址 [https://help.aliyun.com/zh/live/pull-streams-over-rts-on-ios]
 * - 1、打开终端窗口
 * - 2、进入项目所在路径，创建Podfile 文件
 * @code
 *  pod init
 * @endcode
 * - 3、编辑 Podfile 文件，添加播放器依赖
 * @code
 *  player_sdk_version = 'x.x.x' # 建议使用最新版本，详情请参考：https://help.aliyun.com/zh/vod/developer-reference/sdk-overview-and-download
 *  rts_sdk_version = '7.3.0' # 独立版本号，目前最新版本
 *
 *  # 播放器SDK
 *  pod 'AliPlayerSDK_iOS' , player_sdk_version
 *  # 播放器与Rts低延时直播组件的桥接层（AlivcArtc），版本号需要与播放器一致，需要和 Rts低延时直播组件 一起集成
 *  pod 'AliPlayerSDK_iOS_ARTC' , player_sdk_version
 *  # Rts低延时直播组件
 *  pod 'RtsSDK' , rts_sdk_version
 * @endcode
 * - 4、下载依赖
 * @code
 *  // 下载依赖
 *  pod install
 *  // 更新repo 并下载依赖
 *  pod install --repo--update
 *  // 更新repo
 *  pod repo update
 *  // 清除pod 缓存
 *  pod cache clean --all
 * @endcode
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
 * // 3. 播放器播放视频
 * [self.player start];
 *
 * // 4. 资源清理
 * [self.player stop];
 * [self.player destroy];
 * self.player = nil;
 * @endcode
 */
@interface RtsLiveStreamViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
