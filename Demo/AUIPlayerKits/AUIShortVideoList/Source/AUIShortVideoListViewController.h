//
//  AUIShortVideoListViewController.h
//  AUIShortVideoList
//
//  Created by Bingo on 2023/9/14.
//

#import "AUIFoundation.h"
#import "AUIShortVideoInfo.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - AUIShortVideoDataProviderDelegate

/**
 * @protocol AUIShortVideoDataProviderDelegate
 *
 * @discussion 该协议定义了一个数据请求代理接口，专为需要动态加载数据的场景设计。
 * 实现该协议的对象必须提供请求更多数据的功能。数据请求完成后，应通过调用视图控制器
 * 的相关方法将获取到的数据返回给视图控制器进行更新。
 */
@protocol AUIShortVideoDataProviderDelegate <NSObject>

@required
/**
 * @brief 请求额外数据的方法。
 *
 * 此方法由代理实现者提供，用于在视图控制器需要加载更多数据时发起请求。通常用于类似
 * 无限滚动或按需加载的情境下。当数据成功获取后，代理应通知视图控制器对界面进行更新，
 * 以便呈现新数据。
 *
 * @param controller 发起数据请求的视图控制器实例。
 *                   此参数用来提供具体上下文，以便在获取数据后调用视图控制器的相应方法。
 *                   如果上下文不适用，参数也允许为nil。
 *
 * @note 在实现该方法时，请确保对请求错误和数据为空的情况进行妥善处理，以确保用户体验的
 *       连贯和流畅。
 */
- (void)loadData:(id _Nullable)controller;

@optional
/**
 * @brief 刷新数据的方法。可选
 *
 * 此方法由代理实现者提供，用于在视图控制器需要刷新当前显示的数据时发起请求。主要用于用户
 * 下拉刷新或主动触发数据更新的场景。代理应在数据刷新成功后通知视图控制器更新显示，以便
 * 呈现最新的数据状态。
 *
 * @param controller 发起刷新数据请求的视图控制器实例。
 *                   该参数用于提供具体上下文，使得在成功刷新数据后，能够相应地调用视图控制器的更新机制。
 *                   若上下文不适用，该参数允许为 nil。
 *
 * @note 在实现本方法时，应考虑处理所有可能的错误和特殊情况（如数据无变化），以保证用户体验的
 *       连贯性。此外，应确保在有更新或刷新指示器时，及时停止和隐藏指示器，以避免界面阻塞。
 */
- (void)refreshData:(id _Nullable)controller;

@end


#pragma mark - AUIShortVideoListViewController

/**
 * @brief 短视频列表视图控制器，用于展示和管理短视频的播放列表。
 */
@interface AUIShortVideoListViewController : AVBaseCollectionViewController

/**
 * @brief 初始化方法，通过传入初始视频数据来创建实例。
 *
 * @param data 初始的视频数据列表。
 *
 * @return AUIShortVideoListViewController 实例。
 */
- (instancetype)initWithData:(NSArray<AUIShortVideoInfo *> * _Nullable)data;

/**
 * @brief 初始化方法，通过传入数据请求代理来创建实例。
 *
 * @param dataProviderDelegate 通过代理请求更多数据。
 *
 * @return AUIShortVideoListViewController 实例。
 */
- (instancetype)initWithDataProvider:(id<AUIShortVideoDataProviderDelegate> _Nullable)dataProviderDelegate;

/**
 * @brief 初始化方法，通过传入初始数据和数据请求代理来创建实例。
 *
 * @param data 初始的视频数据列表。
 * @param dataProviderDelegate 通过代理请求更多数据。
 *
 * @return AUIShortVideoListViewController 实例。
 */
- (instancetype)initWithData:(NSArray<AUIShortVideoInfo *> * _Nullable)data
                dataProvider:(id<AUIShortVideoDataProviderDelegate> _Nullable)dataProviderDelegate;

/**
 * @brief 将新的视频数据追加到当前视频列表中。
 *
 * @param videoInfoList 新的视频数据列表，可以为空。
 *                      当提供的数据列表不为空时，这些数据将被追加到现有的视频列表的末尾。
 *                      如果提供为空的数据列表，则不对当前列表进行任何修改。
 */
- (void)appendVideoInfoList:(NSArray<AUIShortVideoInfo *> * _Nullable)videoInfoList;

/**
 * @brief 重置当前的视频列表为指定的新视频数据列表。
 *
 * @param videoInfoList 新的视频数据列表，可以为空。
 *                      将当前的视频列表替换为提供的数据列表。
 *                      如果提供为空的数据列表，将清空当前视频列表。
 */
- (void)resetVideoInfoList:(NSArray<AUIShortVideoInfo *> * _Nullable)videoInfoList;

/**
 *  @brief 控制当前 ViewController 是否支持下拉刷新
 *
 *  @param isRefresh 指定是否启用下拉刷新功能。当设置为 YES 时，允许用户通过下拉操作刷新视频列表数据；
 *                   设置为 NO 则禁用下拉刷新。
 *
 *  @discussion 该方法用于控制视频列表视图的刷新行为，适用于需要动态更新内容的场景。
 *  在启用下拉刷新后，您需实现相应的数据请求逻辑，以便在用户下拉时获取新的数据。
 */
- (void)enableRefresh:(BOOL)isRefresh;

/**
 * @brief 获取当前正在播放的视频信息
 *
 * @return AUIShortVideoInfo 实例。
 */
- (AUIShortVideoInfo *)getCurrentVideoInfo;

@end

NS_ASSUME_NONNULL_END
