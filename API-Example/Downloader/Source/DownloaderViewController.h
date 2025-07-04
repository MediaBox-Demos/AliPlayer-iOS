//
//  DownloaderViewController.h
//  Downloader
//
//  Created by 叶俊辉 on 2025/6/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class DownloaderViewController
 * @brief 视频安全下载功能演示 - 阿里云播放器 SDK 最佳实践
 *
 * 本示例展示了如何使用阿里云播放器 SDK 实现视频安全下载功能
 * 参考文档：https://help.aliyun.com/zh/vod/developer-reference/advanced-features-1
 *
 * ==================== 下载器 API 调用步骤 ====================
 * Step 1: 初始化组件
 * - 初始化私有服务和UI组件
 * - 获取应用目录
 *
 * Step 2: 网络请求
 * - 创建网络请求工具类实例
 * - 调用fetchPlayAuthWithVideoId方法请求playAuth
 *
 * Step 3: 设置播放器
 * - 使用 [[AliPlayer alloc] init] 创建播放器
 * - 设置播放器渲染视图 playerView
 * - 配置播放器代理和基本参数
 *
 * Step 4: 设置下载器
 * - 使用 [[AliMediaDownloader alloc] init] 创建下载器
 * - 配置下载保存路径
 * - 设置下载器各种监听器
 *
 * Step 5: 获取下载源
 * - 通过网络请求获取播放授权
 * - 准备下载源并获取可下载轨道列表
 * - 展示下载选项供用户选择（根据获取到的数据，展示为一个列表显示）
 *
 * Step 6: 轨道选择和下载控制
 * - 用户选择下载轨道
 * - 调用 selectTrack: 选择轨道
 * - 调用 start 开始下载
 *
 * Step 7: 下载进度监听
 * - 设置 delegate 监听下载状态
 * - 实现 AMDDelegate 中的下载相关回调方法
 * - 显示下载进度和状态
 *
 * Step 8: 下载完成处理
 * - 处理下载完成事件
 * - 更新UI状态显示
 *
 * Step 9：视频播放
 * - 本模块只提供了下载API 示例，您可以参考文档自行实现播放功能
 * - // 通过点播UrlSource方式设置本地视频地址进行播放
 * - AVPUrlSource *urlSource = [[AVPUrlSource alloc] urlWithString:url];
 * - [self.player setUrlSource:urlSource];
 * - 开始播放
 * - [self.player start];
 * - 参考文档：https://help.aliyun.com/zh/vod/developer-reference/basic-features-2
 *
 * Step 10: 资源清理
 * - 停止并释放播放器实例
 * - 停止并释放下载器实例
 * - 清空相关引用，避免内存泄漏
 */
@interface DownloaderViewController : UIViewController

// 下载保存路径
@property (nonatomic, strong, readonly) NSString *downloadPath;
// 当前选中的轨道索引
@property (nonatomic, assign, readonly) NSInteger selectedTrackIndex;

@end

NS_ASSUME_NONNULL_END
