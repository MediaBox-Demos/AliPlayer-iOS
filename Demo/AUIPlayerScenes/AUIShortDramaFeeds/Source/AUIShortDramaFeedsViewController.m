//
//  AUIShortDramaFeedsViewController.m
//  AUIPlayer
//
//  Created by keria on 2024/11/7.
//

#import "AUIShortDramaFeedsViewController.h"
#import "AUIShortVideoListViewController.h"
#import "AUIShortVideoListDataManager.h"
#import "AUIShortVideoListConstants.h"
#import "AUIShortVideoListUtils.h"
#import "AUITransparentTabBarView.h"

// 顶部导航栏高度
static const CGFloat kTopBarHeight = 30;

// 定义分段控制器的标题数组为静态变量
static NSArray *kSegmentedControlItems;

@interface AUIShortDramaFeedsViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate, AUITransparentTabBarViewDelegate, AUIShortVideoDataProviderDelegate>

// 顶部TAB导航栏切换控制器，用于顶部标签切换
@property (strong, nonatomic) AUITransparentTabBarView *transparentTabBarView;

// 滚动视图，用于装载并管理子视图控制器
@property (strong, nonatomic) UIScrollView *scrollView;

// 子视图控制器数组，存放视图控制器
@property (strong, nonatomic) NSArray<UIViewController *> *viewControllers;

// 保留当前显示的子视图控制器
@property (strong, nonatomic) UIViewController *currentVC;

// 当前显示的子视图控制器 Index
@property (assign, nonatomic) NSInteger currentVCIndex;

@end

@implementation AUIShortDramaFeedsViewController

#pragma mark - LifeCycle

// 类的首次加载
+ (void)initialize {
    if (self == [AUIShortDramaFeedsViewController class]) {
        // 在类第一次加载时初始化静态数组
        kSegmentedControlItems = @[AVGetString(@"Recommend", @"AUIShortDramaFeeds"), AVGetString(@"Follow", @"AUIShortDramaFeeds")];
    }
}

// 初始化方法
- (instancetype)init {
    self = [super init];
    
    if (self) {
        // 初始化代码
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
    
    // 确保导航控制器的侧滑返回手势可用
    if (self.navigationController) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    // 初始化顶部TAB导航栏切换控制器
    [self setupTransparentTabBarView];
    
    // 初始化滚动视图
    [self setupScrollView];
    
    // 设置顶栏处于最前
    [self.view bringSubviewToFront:self.transparentTabBarView];
    
    // 初始化子视图控制器
    [self setupViewControllers];
    
    // 设置初始子视图控制器索引
    self.currentVCIndex = -1;

    // 显示初始子视图控制器
    [self updateSelectionToIndex:0];
}

#pragma mark - Setup Methods

// 初始化顶部TAB导航栏切换控制器
- (void)setupTransparentTabBarView {
    self.transparentTabBarView = [[AUITransparentTabBarView alloc] initWithTitles:kSegmentedControlItems delegate:self];
    CGFloat realTopBarHeight = [AUIShortVideoListUtils additionalTopPaddingForTabBar:kTopBarHeight];
    self.transparentTabBarView.frame = CGRectMake(0, 0, self.view.bounds.size.width, realTopBarHeight);
    [self.view addSubview:self.transparentTabBarView];
}

// 初始化滚动视图
- (void)setupScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    
    // 设置滚动视图的内容大小，仅允许水平方向滚动
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * kSegmentedControlItems.count, self.scrollView.bounds.size.height);
    
    // 启用分页效果，确保滚动时按页停留
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = NO; // 禁止弹簧效果，避免空白区域
    self.scrollView.showsHorizontalScrollIndicator = NO; // 隐藏水平滚动条
    self.scrollView.showsVerticalScrollIndicator = NO; // 隐藏垂直滚动条
    self.scrollView.scrollEnabled = YES; // 允许滚动
    self.scrollView.delegate = self; // 设置代理为当前控制器
    
    [self.view addSubview:self.scrollView];
}

// 初始化子视图控制器
- (void)setupViewControllers {
    // 创建子控制器实例
    NSMutableArray<UIViewController *> *viewControllers = [NSMutableArray array];
    for (NSString *item in kSegmentedControlItems) {
        UIViewController *viewController = [self viewControllerForItem:item];
        if (viewController) {
            [viewControllers addObject:viewController];
        }
    }
    
    // 存储在数组中便于管理
    self.viewControllers = [viewControllers copy];
    
    // 初始显示第一个视图控制器
    if (self.viewControllers.count > 0) {
        [self updateSelectionToIndex:0];
    }
}

// 创建子控制器实例
- (UIViewController *)viewControllerForItem:(NSString *)item {
    AUIShortVideoListViewController *videoListVC = [[AUIShortVideoListViewController alloc] initWithDataProvider:self];
    return videoListVC;
}

#pragma mark - VC Management

// 统一更新导航栏中按钮的选中状态以及对应视图控制器
- (void)updateSelectionToIndex:(NSInteger)index {
    // 确保索引在子视图控制器数组范围内
    if (index < 0 || index >= self.viewControllers.count) {
        return;
    }
    
    // 如果当前已选中该索引，不作任何操作
    if (index == self.currentVCIndex) {
        return;
    }
    
    // 更新导航栏中按钮的选中状态以匹配当前索引
    [self.transparentTabBarView setSelectedIndex:index];

    // 显示对应的视图控制器
    UIViewController *selectedVC = self.viewControllers[index];
    [self displayContentController:selectedVC atIndex:index];
}

// 显示指定索引的子视图控制器并管理其视图生命周期
- (void)displayContentController:(UIViewController *)vc atIndex:(NSInteger)index {
    // 移除当前已显示的视图控制器（如果有）
    if (self.currentVC) {
        // 通知当前视图控制器即将移出父视图控制器
        [self.currentVC willMoveToParentViewController:nil];
        // 从当前视图层次结构中移除其视图
        [self.currentVC.view removeFromSuperview];
        // 移除与父视图控制器的关联
        [self.currentVC removeFromParentViewController];
    }
    
    // 将新的视图控制器添加为子视图控制器
    [self addChildViewController:vc];
    // 设置新视图控制器视图的布局，占满整个滚动视图的可见区域
    vc.view.frame = CGRectMake(index * self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    
    // 将新视图控制器的视图添加至滚动视图中
    [self.scrollView addSubview:vc.view];
    
    // 更新 scrollView 的 contentOffset 以显示新添加的视图控制器视图
    [self.scrollView setContentOffset:CGPointMake(index * self.view.bounds.size.width, 0) animated:NO];
    
    // 通知新视图控制器已添加到父视图控制器
    [vc didMoveToParentViewController:self];
    
    // 更新对当前可见视图控制器的引用
    self.currentVC = vc;
    
    // 更新当前子视图控制器索引
    self.currentVCIndex = index;
}

#pragma mark - AUIShortVideoDataProviderDelegate

// 请求额外数据的方法
- (void)loadData:(id)controller {
    AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:self.view animated:YES];
    loading.labelText = AVGetString(@"Loading...", @"AUIShortDramaFeeds");
    
    // 创建弱引用，以避免循环引用
    __weak typeof(self) weakSelf = self;  // 弱引用 self
    [AUIShortVideoListDataManager requestVideoInfoList:AUIShortVideoListConstants.defaultVideoInfoListURL completed:^(NSArray<AUIShortVideoInfo *> * _Nullable data, NSError * _Nullable error) {
        // 获取强引用以避免过早释放 self
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [loading hideAnimated:YES];
        
        if (error) {
            NSString *msg = [NSString stringWithFormat:@"%@, error: %@", AVGetString(@"Unable to retrieve data", @"AUIShortDramaFeeds"), error.localizedDescription];
            [AVToastView show:msg
                         view:strongSelf.view
                     position:AVToastViewPositionMid];
            return;
        }
        
        // 确认新数据非空且有内容
        if (!data || data.count == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 在主线程显示错误提示
                [AVToastView show:AVGetString(@"Failed to load data, data is empty!", @"AUIShortDramaFeeds")
                             view:strongSelf.view
                         position:AVToastViewPositionBottom];
            });
            return;
        }
        
        // 调用相应子视图控制器的 appendVideoInfoList: 方法
        if (controller && [controller respondsToSelector:@selector(appendVideoInfoList:)]) {
            [controller appendVideoInfoList:[data copy]];
        }
    }];
}

#pragma mark - UIScrollViewDelegate

// 滚动视图减速停止时，更新分段控制器的选中状态
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = round(scrollView.contentOffset.x / self.view.bounds.size.width);
    [self updateSelectionToIndex:index];
}

// 禁用垂直滚动：在滚动视图滚动时，始终将 y 轴的偏移量设置为0
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 强制 y 轴偏移为0，禁用垂直滚动
    if (scrollView.contentOffset.y != 0) {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
    }
}

#pragma mark - UIGestureRecognizerDelegate

// 允许同时识别手势，确保不与系统的侧滑手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // 只允许侧滑返回手势在根视图控制器中同时识别
    return gestureRecognizer == self.navigationController.interactivePopGestureRecognizer;
}

#pragma mark - AUITransparentTabBarViewDelegate

// 当选项卡被选中时调用此方法
- (void)selectedIndexUpdated:(AUITransparentTabBarView *)tabBar didSelectIndex:(NSInteger)index {
    [self updateSelectionToIndex:index];
}

@end
