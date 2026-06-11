//
//  AUIShortVideoPlayCell.h
//  AUIPlayer
//
//  Created by keria on 2024/11/14.
//

#import <UIKit/UIKit.h>
#import "AUIShortVideoInfo.h"
#import "AliVideoView.h"

#import <SDWebImage/UIImageView+WebCache.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @class AUIShortVideoPlayCell
 * @brief 短视频播放单元格类
 *
 * @discussion 该类继承自 UICollectionViewCell，用于展示和控制短视频播放。
 */
@interface AUIShortVideoPlayCell : UICollectionViewCell

/**
 * @brief 视频播放完成回调块
 *
 * @discussion 当视频播放完毕后会调用此回调块。回调参数是当前单元格实例。
 */
@property (nonatomic, copy) void(^onCompletionBlock)(AUIShortVideoPlayCell *cell);

/**
 * @brief 视频单元选择时触发的回调块
 *
 * @discussion `onSelectionBlock` 用于处理用户选择某个短视频播放单元 (`AUIShortVideoPlayCell`) 时的事件。
 * 这个回调可以用于在用户点击选择某个视频单元时执行特定的操作，例如更新界面、加载视频信息或直接进行视频播放。
 *
 * @note 使用此属性时，请确保正确设置回调，以便在用户选择动作发生时能得到预期的响应。
 *
 * @param cell 当前被选择的 `AUIShortVideoPlayCell` 实例。
 */
@property (nonatomic, copy) void(^onSelectionBlock)(AUIShortVideoPlayCell *cell);

/**
 * @brief 返回按钮点击时触发的回调块
 *
 * @discussion `onBackBtnClickBlock` 用于处理用户点击返回按钮的事件。
 * 该回调可用于在用户点击返回按钮时执行特定的操作，如关闭当前视图或返回到上一级菜单。
 *
 * @note 请正确设置此回调来定义返回操作。
 *
 * @param cell 当前所在的 `AUIShortVideoPlayCell` 实例。
 */
@property (nonatomic, copy) void(^onBackBtnClickBlock)(AUIShortVideoPlayCell *cell);

/**
 * @brief 设置按钮点击时触发的回调块
 *
 * @discussion `onSettingBlock` 用于处理用户点击视频设置按钮的事件。
 * 该回调可以用于显示设置选项，例如视频质量选择。
 *
 * @note 请正确设置此回调以提供适当的设置界面或操作。
 *
 * @param cell 触发事件的 `AUIShortVideoPlayCell` 实例。
 * @param trackInfo 视频轨道信息数组，包含可用的轨道信息。
 */
@property (nonatomic, copy) void(^onSettingBlock)(AUIShortVideoPlayCell *cell, NSArray<AVPTrackInfo *> *trackInfo);

/**
 @brief 渲染前回调：返回 YES 表示继续渲染当前像素缓冲，NO 表示跳过。
 @param cell        触发回调的播放单元。
 @param pixBuffer   即将渲染的像素缓冲；仅在回调内有效，异步请 Retain/Release。
 */
@property (nonatomic, copy) BOOL(^onPiPEnqueuePixelBuffer)(AUIShortVideoPlayCell *cell, CVPixelBufferRef pixBuffer);

/**
 * @brief 视频轨道改变时触发的回调块
 *
 * @discussion `onTrackChanged` 用于处理用户选择不同视频轨道的事件。
 * 当用户改变视频轨道时，触发此回调来适当更新视频播放。
 *
 * @note 请在此回调中处理轨道改变后的响应行为。
 *
 * @param cell 触发事件的 `AUIShortVideoPlayCell` 实例。
 * @param info 新选择的 `AVPTrackInfo`，包含当前选择的轨道信息。
 */
@property (nonatomic, copy) void(^onTrackChanged)(AUIShortVideoPlayCell *cell, AVPTrackInfo *info);

/**
 * @brief 状态回调
 */
@property (nonatomic, copy) void(^onStatusChanged)(AUIShortVideoPlayCell *cell, AVPStatus status);


/**
 * @brief 进度回调
 * @param cell
 * @param postion 当前进度
 * @param duration 视频时长
 */
@property (nonatomic, copy) void(^onPositionChanged)(AUIShortVideoPlayCell *cell, int64_t position,int64_t duration);


/**
 * @brief 绑定视频信息到单元格。
 *
 * 此方法将指定的视频信息绑定到单元格上，使单元格能够展示并预备视频封面图
 *
 * @param videoInfo 包含视频相关数据的视频信息对象。如视频 URL、标题、缩略图等。
 *
 * @discussion 使用该方法可以在单元格上绑定一个视频的信息，以便在单元格中展示视频内容。
 *             请确保在调用此方法之前，视频信息对象 `videoInfo` 已经正确初始化。
 */
- (void)bindData:(AUIShortVideoInfo *)videoInfo;

/**
 * @brief 将当前视频绑定到单元格。
 *
 * @discussion 此方法将当前视频的信息绑定到单元格上，使单元格能够展示准备好的视频内容。
 *             通常在单元格复用时调用，以确保每次展示时都使用当前视频数据。
 *             请确保在调用 `bind` 方法之前，已经设置好所需的视频信息。
 */
- (void)bind;

/**
 * @brief 解除视频与单元格的绑定。
 *
 * @discussion 此方法解除当前视频与单元格的绑定关系，停止视频播放并释放相关资源。
 *             通常在单元格被复用或不再需要显示视频时调用，以防止内存泄漏或资源浪费。
 *             调用此方法后，单元格将不再与之前的视频信息关联。
 */
- (void)unbind;

/**
 * @brief 开始播放视频
 *
 * @discussion 此方法启动视频播放。调用此方法前需先绑定视频信息。
 */
- (void)start;

/**
 * @brief 暂停视频播放
 *
 * @discussion 此方法暂停当前正在播放的视频，可以通过调用 start 方法恢复播放。
 */
- (void)pause;

/**
 * @brief 设置视频倍速
 *
 * @discussion 此方法 设置视频倍速
 */
- (void)setSpeed:(CGFloat)value;

/**
 * @brief 设置视频码率
 *
 * @discussion 此方法 设置视频码率
 */
- (void)selectTrack:(AVPTrackInfo*)trackInfo;

/**
 * @brief 跳转到指定播放位置
 *
 * @param position 播放位置，单位为毫秒 (ms)。
 *
 * @discussion 根据提供的毫秒时间戳，精确调整视频播放位置。
 *             与 -seek: 不同的是，该方法直接使用绝对时间而非 0.0~1.0 的进度比例。
 */
- (void)seekToPosition:(int64_t)position;

/**
 * @brief 设置带宽值。
 *
 * @param bandwidth 带宽值。如果为 0 或负数，则重置为默认状态。
 */
- (void)setBandwidth:(NSInteger)bandwidth;

/**
 * @brief 显示封面图
 */
- (void)showCoverImage:(BOOL)enable;

/**
 * @brief 显示暂停按钮
 */
- (void)showPauseBtn:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
