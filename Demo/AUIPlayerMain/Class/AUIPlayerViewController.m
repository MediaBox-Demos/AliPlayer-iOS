//
//  AUIPlayerViewController.m
//  AlivcPlayerDemo
//
//  Created by zzy on 2022/5/26.
//

#import "AUIPlayerViewController.h"
#import "AUIVideoFlowModule.h"
#import "AUIVideoFullScreenModule.h"
#import "AUIBackstageViewController.h"

@interface AUIPlayerViewController () <AUIShortVideoDataProviderDelegate>

@end

@implementation AUIPlayerViewController

- (instancetype)init {
    AVCommonListItem *flowFeedItem = [AVCommonListItem new];
    flowFeedItem.title = AlivcPlayerString(@"信息流播放");
    flowFeedItem.info = AlivcPlayerString(@"适用于新闻资讯、社区互动等短视频场景");
    flowFeedItem.icon = AlivcPlayerImage(@"bofangqi_ic_xinxi");
    
    AVCommonListItem *shortDramaListItem = [AVCommonListItem new];
    shortDramaListItem.title = AlivcPlayerString(@"短剧剧场");
    shortDramaListItem.info = AlivcPlayerString(@"适用于短剧剧场场景");
    shortDramaListItem.icon = AlivcPlayerImage(@"bofangqi_ic_chenjin");
    
    AVCommonListItem *shortDramaFeedsItem = [AVCommonListItem new];
    shortDramaFeedsItem.title = AlivcPlayerString(@"短剧Feeds流");
    shortDramaFeedsItem.info = AlivcPlayerString(@"适用于短剧Feeds流场景");
    shortDramaFeedsItem.icon = AlivcPlayerImage(@"bofangqi_ic_quanping");

    AVCommonListItem *shortVideoListItem = [AVCommonListItem new];
    shortVideoListItem.title = AlivcPlayerString(@"沉浸式播放");
    shortVideoListItem.info = AlivcPlayerString(@"竖屏短视频场景，全屏秒开最佳实践");
    shortVideoListItem.icon = AlivcPlayerImage(@"bofangqi_ic_zidingyi");

    AVCommonListItem *fullScreenItem = [AVCommonListItem new];
    fullScreenItem.title = AlivcPlayerString(@"全屏播放");
    fullScreenItem.info = AlivcPlayerString(@"适用于版权视频等长视频场景");
    fullScreenItem.icon = AlivcPlayerImage(@"bofangqi_ic_zidingyi");
    
    NSArray *list = @[
        flowFeedItem,
        shortDramaListItem,
        shortDramaFeedsItem,
        shortVideoListItem,
        fullScreenItem,
    ];

    self = [super initWithItemList:list];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    self.hiddenMenuButton = NO;
    self.menuButton.av_left = self.headerView.av_width - 20 - 80;
    self.menuButton.av_width = 80;
    [self.menuButton setImage:nil forState:UIControlStateNormal];
    [self.menuButton setTitle:AlivcPlayerString(@"设置") forState:UIControlStateNormal];

   self.titleView.text = AlivcPlayerString(@"播放器");
}

- (void)onMenuClicked:(UIButton *)sender {
    [self openBackstage];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.item) {
        case 0:
        {
            [self openVideoFlow];
        }
            break;
        case 1:
        {
            [self openShortDramaList];
        }
            break;
        case 2:
        {
            [self openShortDramaFeeds];
        }
            break;
        case 3:
        {
            [self openShortVideoList];
        }
            break;
        case 4:
        {
            [self openVideoFullScreen];
        }
            break;
        default:
            break;
    }
}

- (void)openVideoFlow {
    AUIVideoFlowModule *module = [[AUIVideoFlowModule alloc] initWithSourceViewController:self];
    [module open];
}

- (void)openShortVideoList {
    AUIShortVideoListViewController *vc = [[AUIShortVideoListViewController alloc] initWithDataProvider:self];
    [vc enableRefresh:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)openShortDramaList {
    AUIShortDramaListViewController *vc = [[AUIShortDramaListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)openShortDramaFeeds {
    AUIShortDramaFeedsViewController *vc = [[AUIShortDramaFeedsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)openVideoFullScreen {
    AUIVideoFullScreenModule *module = [[AUIVideoFullScreenModule alloc] initWithSourceViewController:self];
    [module open];
}

- (void)openBackstage {
    AUIBackstageViewController *vc = [[AUIBackstageViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - AUIShortVideoDataProviderDelegate

// 请求额外数据的方法
- (void)loadData:(id)controller {
    __weak typeof(self) weakSelf = self;  // 弱引用 self
    [AUIShortVideoListDataManager requestVideoInfoList:AUIShortVideoListConstants.defaultVideoInfoListURL completed:^(NSArray<AUIShortVideoInfo *> * _Nullable data, NSError * _Nullable error) {
        if (error) {
            __strong typeof(weakSelf) strongSelf = weakSelf; // 强引用 self
            [AVToastView show:[NSString stringWithFormat:@"Unable to retrieve short video list, error: %@", error.localizedDescription]
                         view:strongSelf.view
                     position:AVToastViewPositionMid];
            return;
        }
        
        // 调用相应子视图控制器的 appendVideoInfoList: 方法
        if (controller && [controller respondsToSelector:@selector(appendVideoInfoList:)]) {
            [controller appendVideoInfoList:data];
        }
    }];
}

- (void)refreshData:(id)controller{
    __weak typeof(self) weakSelf = self;  // 弱引用 self
    [AUIShortVideoListDataManager requestVideoInfoList:AUIShortVideoListConstants.defaultVideoInfoListURL completed:^(NSArray<AUIShortVideoInfo *> * _Nullable data, NSError * _Nullable error) {
        if (error) {
            __strong typeof(weakSelf) strongSelf = weakSelf; // 强引用 self
            [AVToastView show:[NSString stringWithFormat:@"Unable to retrieve short video list, error: %@", error.localizedDescription]
                         view:strongSelf.view
                     position:AVToastViewPositionMid];
            return;
        }
        
        // 调用相应子视图控制器的 appendVideoInfoList: 方法
        if (controller && [controller respondsToSelector:@selector(resetVideoInfoList:)]) {
            [controller resetVideoInfoList:data];
        }
    }];
}

@end
