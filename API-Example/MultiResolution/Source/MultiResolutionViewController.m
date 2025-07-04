//
//  MultiResolutionViewController.m
//  MultiResolution
//
//  Created by aqi on 2025/6/25.
//

#import "MultiResolutionViewController.h"
#import "Common/Common.h"
#import "MultiResolutionCell.h"
#import <AliyunPlayer/AliyunPlayer.h>

@interface MultiResolutionViewController () <AVPDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

// 播放器
@property (nonatomic, strong) AliPlayer *player;
// 播放器视图
@property (nonatomic, strong) UIView *playerView;
// 清晰度列表视图
@property (strong, nonatomic) UICollectionView *resolutionCollectionView;
// 清晰度数据
@property (strong, nonatomic) NSMutableArray<AVPTrackInfo *> *data;

@property (nonatomic, assign) int selectPosition;

@end

@implementation MultiResolutionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initView];

    [self setupPlayer];
    [self startupPlayer];
}

/**
 * brief  Step 1: 初始化视图
 */
- (void)initView {
    self.view.backgroundColor = UIColor.blackColor;

    // 初始化播放器视图
    self.playerView = [[UIView alloc] initWithFrame:self.view.bounds];
    // 添加播放器视图 到显示视图
    [self.view addSubview:self.playerView];

    // Create a flow layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;

    // Create collection view
    self.resolutionCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 180, 80, 180) collectionViewLayout:layout];
    self.resolutionCollectionView.backgroundColor = [UIColor clearColor]; // Change to your desired background color
    self.resolutionCollectionView.dataSource = self;
    self.resolutionCollectionView.delegate = self;

    // Register the custom cell
    [self.resolutionCollectionView registerClass:[MultiResolutionCell class] forCellWithReuseIdentifier:@"HorizontalCell"];

    self.resolutionCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.resolutionCollectionView.showsHorizontalScrollIndicator = NO;
    self.resolutionCollectionView.showsVerticalScrollIndicator = NO;

    self.resolutionCollectionView.showsHorizontalScrollIndicator = NO;

    self.resolutionCollectionView.hidden = YES;

    // Add collection view to main view
    [self.view addSubview:self.resolutionCollectionView];

    self.selectPosition = 0;
}

/**
 * @brief Step 2: 初始化播放器&&设置播放器代理
 */
- (void)setupPlayer {
    // 创建播放器
    self.player = [[AliPlayer alloc] init];
    // 设置代理 AVPDelegate
    [self.player setDelegate:self];
    // 设置播放器视图
    [self.player setPlayerView:self.playerView];
    // 设置循环播放
    [self.player setLoop:true];
    // 设置快切模式
    AVPConfig *config = [self.player getConfig];

    config.selectTrackBufferMode = 1;

    [self.player setConfig:config];
}

/**
 * @brief Step 3: 设置数据源&&加载播放器
 */
- (void)startupPlayer {
    if (self.player) {
        AVPUrlSource *urlSource = [[AVPUrlSource alloc] urlWithString:kMultiResolutionURL];
        // 设置数据源
        [self.player setUrlSource:urlSource];
        // 准备播放
        [self.player prepare];
        // prepare 以后可以同步调用 start 操作，onPrepared 回调完成后会自动起播
        [self.player start];
    }
}

/**
 * Step x: 销毁播放器
 */
- (void)cleanupPlayer {
    if (self.player) {
        // 停止继续播放
        [self.player stop];
        // 销毁播放器
        [self.player destroy];
        // 清除引用
        self.player = nil;
        // 清除引用
        self.playerView = nil;
    }
}

#pragma mark - AliPlayer AVPDelegate

/**
 *  Step 5: 加载清晰度数据
 */
- (void)onTrackReady:(AliPlayer *)player info:(NSArray<AVPTrackInfo *> *)info {
    if (self.data == nil) {
        self.data = [[NSMutableArray alloc] init];
    }

    if (info != nil && info.count > 0) {
        NSMutableArray *result = [[NSMutableArray alloc] init];
        for (AVPTrackInfo *item in info) {
            if (item.trackType == AVPTRACK_TYPE_VIDEO) {
                [result addObject:item];
            }
        }
        self.data = result;
        NSLog(@"TrackInfoList %ld", self.data.count);
        if (self.resolutionCollectionView) {
            self.resolutionCollectionView.hidden = NO;
            [self.resolutionCollectionView reloadData];
        }
    }
}

- (void)onTrackChanged:(AliPlayer *)player info:(AVPTrackInfo *)info {
    if (info.trackType == AVPTRACK_TYPE_VIDEO) {
        NSLog(@"切换清晰度:%dp", info.videoWidth);
    }
}

#pragma mark - UICollectionView Data Source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.data) {
        return self.data.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MultiResolutionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HorizontalCell" forIndexPath:indexPath];

    AVPTrackInfo *info = self.data[indexPath.item];

    NSString *labelText = [NSString stringWithFormat:@"%dp", info.videoWidth];

    cell.label.text = labelText;

    if (indexPath.item == self.selectPosition) {
        cell.label.backgroundColor = [UIColor greenColor];
    } else {
        cell.label.backgroundColor = [UIColor lightGrayColor];
    }

    return cell;
}

/**
 * 切换清晰度
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"MultiResolution->didSelectItemAtIndexPath %ld", indexPath.item);

    int lastIndex = self.selectPosition;
    self.selectPosition = (int)indexPath.item;

    [self.player selectTrack:self.data[indexPath.item].trackIndex];

    [self.resolutionCollectionView reloadItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:lastIndex inSection:0] ]];
    [self.resolutionCollectionView reloadItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:indexPath.item inSection:0] ]];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.frame.size.width, 45);
}

/**
 * @brief 视图销毁
 */
- (void)dealloc {
    [self cleanupPlayer];
}

@end
