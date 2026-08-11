//
//  AUIShortTheaterDetailViewController.m
//  AUIPlayer
//
//  Created by keria on 2024/11/6.
//

#import "AUIShortTheaterDetailViewController.h"
#import "AUIShortTheaterDetailCollectionViewCell.h"
#import "AUIShortTheaterDataManager.h"
#import "AUIShortVideoListViewController.h"
#import "AUIShortVideoListUtils.h"

// 项目间距和边距
static const CGFloat kContentPadding = 10;
// 顶部导航栏高度
static const CGFloat kTopBarHeight = 30;
// 每行显示的项目数
static const NSInteger kItemsPerRow = 3;

@interface AUIShortTheaterDetailViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

// 数据请求代理
@property (nonatomic, weak) id<AUIShortVideoDataProviderDelegate> dataProviderDelegate;

// 存储当前显示的所有短剧剧集列表
@property (nonatomic, strong) NSMutableArray<AUIShortPlaylistInfo *> *playlistInfoList;

// 用于显示短剧剧集信息的集合视图
@property (nonatomic, strong) UICollectionView *collectionView;


@property (nonatomic, strong) NSString* currentPlayListId;

@property (nonatomic, strong) NSMutableArray<AUIShortVideoInfo *> *currentVideoInfoList;


@end

@implementation AUIShortTheaterDetailViewController

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
        if (data && data.count > 0) {
            [self.playlistInfoList addObjectsFromArray:data];
        }
        
        // 设置数据请求代理
        self.dataProviderDelegate = dataProviderDelegate;
        
        NSLog(@"[init] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
    }
    
    return self;
}

// 资源释放
- (void)dealloc {
    NSLog(@"[dealloc] ~~~ <%@: %p>", NSStringFromClass([self class]), self);
}


#pragma mark - View Layout

// 视图加载完毕后的初始化设置
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 设置视图的背景颜色
    self.view.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22"];
    
    // 设置集合视图
    [self setupCollectionView];
    
    // 如果当前无数据，请求更多数据
    if (self.playlistInfoList.count == 0 && self.dataProviderDelegate && [self.dataProviderDelegate respondsToSelector:@selector(loadData:)]) {
        [self.dataProviderDelegate loadData:self];
    }
}

// 初始化集合视图、设置布局和注册集合视图单元
- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    // 设定单元大小
    CGFloat contentWidth = [UIScreen mainScreen].bounds.size.width - kContentPadding * 2;
    CGFloat totalPadding = kContentPadding * (kItemsPerRow - 1);
    CGFloat itemWidth = (contentWidth - totalPadding) / kItemsPerRow;
    layout.itemSize = CGSizeMake(floor(itemWidth), floor(itemWidth / 9 * 16));
    layout.minimumLineSpacing = kContentPadding; // 行间距
    layout.minimumInteritemSpacing = kContentPadding; // 项目间距
    
    CGFloat realTopBarHeight = [AUIShortVideoListUtils additionalTopPaddingForTabBar:kTopBarHeight];
    CGRect rect = CGRectMake(0, realTopBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - realTopBarHeight);
    self.collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    // top, left, bottom, right
    self.collectionView.contentInset = UIEdgeInsetsMake(kContentPadding, kContentPadding, kContentPadding, kContentPadding);
    
    [self.collectionView registerClass:[AUIShortTheaterDetailCollectionViewCell class] forCellWithReuseIdentifier:@"DramaDetailCell"];
    [self.view addSubview:self.collectionView];
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
    
    // 在主线程上更新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];  // 刷新集合视图
    });
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.playlistInfoList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AUIShortTheaterDetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DramaDetailCell" forIndexPath:indexPath];
    if (self.playlistInfoList != nil && self.playlistInfoList.count > 0){
        [cell configureWithPlaylistInfo:self.playlistInfoList[indexPath.item]]; // 配置单元格
    }
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 处理单元格选中事件
    AUIShortPlaylistInfo *playlistInfo = self.playlistInfoList[indexPath.item];
    
    // 添加跳转逻辑处理
    if (playlistInfo && playlistInfo.playlistVideos) {
        if (self.currentPlayListId && [self.currentPlayListId isEqualToString:playlistInfo.playlistId]) {
            AUIShortVideoListViewController* vc =  [[AUIShortVideoListViewController alloc] initWithData:self.currentVideoInfoList];;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            self.currentPlayListId =  playlistInfo.playlistId;
            AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:self.view animated:YES];
            loading.labelText = AVGetString(@"Loading...",@"AUIShortPlaylistTheater");
            loading.backgroundColor = UIColor.blackColor;
            
            [AUIShortVideoListDataManager requestPlayListDetail:playlistInfo.playlistId completed:^(NSArray<AUIShortVideoInfo *> * _Nullable data,
                                                                                           NSError * _Nullable error) {
                [loading hideAnimated:YES];
                
                if (error)
                {
                    SLOGI(@"it is a error to push ViewController");
                    return;
                }
                
                if (data && data.count > 0){
                    self.currentVideoInfoList = [data copy];
                    AUIShortVideoListViewController* vc =  [[AUIShortVideoListViewController alloc] initWithData:self.currentVideoInfoList];;
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }];
        }
    }
    else {
        [AVToastView show:AVGetString(@"Failed to load data, data is empty!",
                                      @"AUIShortPlaylistTheater")
                     view:self.view
                 position:AVToastViewPositionBottom];
    }
}

@end
