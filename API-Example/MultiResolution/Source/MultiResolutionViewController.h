//
//  MultiResolutionViewController.h
//  MultiResolution
//
//  Created by aqi on 2025/6/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * @class MultiResolutionViewController
 * @brief 多清晰度视频切换功能演示 - 阿里云播放器 SDK 最佳实践
 *
 * 本示例展示了如何使用阿里云播放器 SDK 实现多清晰度切换的功能
 *
 * ==================== 前提条件 ====================
 * 1. 配置 License：确保已在 AppDelegate 中配置有效的播放器 License
 * 2. 网络权限：确保应用具有网络访问权限
 * 3. SDK 集成：确保已正确集成阿里云播放器 SDK
 * 4. 播放源：确保视频 URL 可访问且格式支持
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
 * [self.player setDelegate:self];
 *
 * // 2. 设置播放源
 * AVPUrlSource *urlSource = [[AVPUrlSource alloc] urlWithString:videoURL];
 * [self.player setUrlSource:urlSource];
 *
 * // 3. 开始播放
 * [self.player prepare];
 * [self.player start];
 *
 * // 4、切换清晰度
 * [self.player selectTrack:trackInfo.trackIndex];
 *
 * // 5. 资源清理
 * [self.player stop];
 * [self.player destroy];
 * self.player = nil;
 *
 * // 代理配置 AVPDelegate
 * // 获取视频流媒体数据
 *  - (void)onTrackReady:(AliPlayer *)player info:(NSArray<AVPTrackInfo *> *)info {
 *     if (info != nil && info.count > 0){
 *         for (AVPTrackInfo* item in info) {
 *             if (item.trackType == AVPTRACK_TYPE_VIDEO){
 *                  // 记录清晰度数据
 *             }
 *         }
 *     }
 *  }
 *
 * // 切换清晰度成功回调
 * - (void)onTrackChanged:(AliPlayer *)player info:(AVPTrackInfo *)info {
 *    if (info.trackType == AVPTRACK_TYPE_VIDEO){
 *       NSLog(@"切换清晰度:%dp",info.videoWidth);
 *    }
 * }
 *
 * @endcode
 */
@interface MultiResolutionViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
