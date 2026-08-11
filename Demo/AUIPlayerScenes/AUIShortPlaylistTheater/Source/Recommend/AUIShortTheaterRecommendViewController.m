//
//  AUIShortTheaterRecommendViewController.m
//  AUIPlayer
//
//  Created by keria on 2024/11/6.
//

#import "AUIShortTheaterRecommendViewController.h"
#import "AUIShortTheaterDetailView.h"
#import "AUIShortVideoListViewController.h"
#import "AUIShortTheaterDataManager.h"

@interface AUIShortTheaterRecommendViewController ()

// 数据请求代理
@property (nonatomic, weak) id<AUIShortVideoDataProviderDelegate> dataProviderDelegate;

@property (nonatomic, strong) AUIShortTheaterDetailView *detailsView;
@property (nonatomic, strong) AUIShortVideoListViewController *videoListVC;

// 存储所有短剧剧集列表
@property (nonatomic, strong) NSMutableArray<AUIShortPlaylistInfo *> *playlistInfoList;
// 存储当前显示的所有短剧剧集首集的视频信息列表
@property (nonatomic, strong) NSMutableArray<AUIShortVideoInfo *> *videoInfoList;

@end

@implementation AUIShortTheaterRecommendViewController

#pragma mark - LifeCycle

// 初始化方法
- (instancetype)init {
    return [self initWithData:nil];
}

// 初始化方法，通过传入初始短剧剧集数据来创建实例。
- (instancetype)initWithData:(NSArray<AUIShortPlaylistInfo *> *)data {
    return [self initWithData:data dataProvider:nil];
}

// 初始化方法，通过传入数据请求代理来创建实例。
- (instancetype)initWithDataProvider:(id<AUIShortVideoDataProviderDelegate>)dataProviderDelegate {
    return [self initWithData:nil dataProvider:dataProviderDelegate];
}

// 初始化方法，通过传入初始数据和数据请求代理来创建实例。
- (instancetype)initWithData:(NSArray<AUIShortPlaylistInfo *> *)data dataProvider:(id<AUIShortVideoDataProviderDelegate>)dataProviderDelegate {
    self = [super init];
    
    if (self) {
        // 设置初始数据
        self.playlistInfoList = [NSMutableArray array];
        self.videoInfoList = [NSMutableArray array];
        if (data && data.count > 0) {
            [self.playlistInfoList addObjectsFromArray:data];
            NSMutableArray<AUIShortVideoInfo *> *videoInfoList = [AUIShortTheaterDataManager getFirstVideoFromPlayListInfos:data];
            if (videoInfoList) {
                [self.videoInfoList addObjectsFromArray:videoInfoList];
            }
        }
        
        // 设置数据请求代理
        self.dataProviderDelegate = dataProviderDelegate;
        
        NSLog(@"[init] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
    }
    
    return self;
}

// 释放资源
- (void)dealloc {
    NSLog(@"[dealloc] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
}


#pragma mark - View Layout

// 视图加载完毕后的初始化设置
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置视图的背景颜色
    self.view.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22"];
    
    // 添加沉浸式短视频组件
    [self setupShortVideoListVC];
    
    // 添加详情视图
    [self setupPlaylistDetailView];
    
    // 如果当前无数据，请求更多数据
    if (self.playlistInfoList.count == 0 && self.dataProviderDelegate && [self.dataProviderDelegate respondsToSelector:@selector(loadData:)]) {
        [self.dataProviderDelegate loadData:self];
    }
}

// 添加沉浸式短视频组件
- (void)setupShortVideoListVC {
    // 初始化AUIShortVideoListViewController
    self.videoListVC = [[AUIShortVideoListViewController alloc] initWithData:[self.videoInfoList copy]];
    
    // 添加为子视图控制器
    [self addChildViewController:self.videoListVC];
    
    // 设置子视图控制器的视图大小为全屏
    self.videoListVC.view.frame = self.view.bounds;
    self.videoListVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // 将子视图添加到父视图中
    [self.view addSubview:self.videoListVC.view];
    
    // 通知子视图控制器已经移动到父视图控制器
    [self.videoListVC didMoveToParentViewController:self];
}

// 设置短剧剧场推荐页
- (void)setupPlaylistDetailView {
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = self.view.bounds.size.height;
    
    // 初始化并配置AUIShortTheaterDetailView
    CGFloat detailsViewHorizontalPadding = 48; // 横向/水平填充
    CGRect detailsViewRect = CGRectMake(detailsViewHorizontalPadding, viewHeight - 100, viewWidth - detailsViewHorizontalPadding * 2 , 40);
    __weak typeof(self) weakSelf = self;  // 弱引用 self
    self.detailsView = [[AUIShortTheaterDetailView alloc] initWithFrame:detailsViewRect tapHandler:^{
        __strong typeof(weakSelf) strongSelf = weakSelf; // 强引用 self
        
        // 添加跳转逻辑处理
        AUIShortVideoInfo *videoInfo = [strongSelf.videoListVC getCurrentVideoInfo];
        if (!videoInfo) {
            [AVToastView show:AVGetString(@"Failed to load data, data is empty!", @"AUIShortPlaylistList")
                         view:self.view
                     position:AVToastViewPositionBottom];
            return;
        }
        
        NSLog(@"playlistId : %@",videoInfo.playlistId);
        
        [AUIShortTheaterDataManager getPlayListDetail:videoInfo completed:^(AUIShortPlaylistInfo * _Nullable data, NSError * _Nullable error) {
            if (error){
                
            }
            
            
            if (!data || !data.playlistVideos || data.playlistVideos.count ==0) {
                [AVToastView show:AVGetString(@"Failed to load data, data is empty!", @"AUIShortPlaylistList")
                             view:self.view
                         position:AVToastViewPositionBottom];
                return;
            }
            
            AUIShortVideoListViewController *videoListVC = [[AUIShortVideoListViewController alloc] initWithData:data.playlistVideos];
            [strongSelf.navigationController pushViewController:videoListVC animated:YES];
        }];
      
    }];
    
   
    
    [self.view addSubview:self.detailsView];
}


#pragma mark - Data Provider

// 追加新的短剧剧集数据到当前列表中
- (void)appendPlaylistInfoList:(NSArray<AUIShortPlaylistInfo *> *)playlistInfoList {
    // 确认新数据非空且有内容
    if (!playlistInfoList || playlistInfoList.count == 0) {
        return;
    }
    
    // 将新的视频数据追加到现有列表中
    [self.playlistInfoList addObjectsFromArray:playlistInfoList];
    NSMutableArray<AUIShortVideoInfo *> *videoInfoList = [AUIShortTheaterDataManager getFirstVideoFromPlayListInfos:playlistInfoList];
    if (videoInfoList) {
        [self.videoInfoList addObjectsFromArray:videoInfoList];
    }
    
    // 在主线程上更新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.videoListVC) {
            [self.videoListVC appendVideoInfoList:videoInfoList];
        }
    });
}

@end
