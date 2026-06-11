//
//  AUIShortVideoListConstants.m
//  AUIPlayer
//
//  Created by keria on 2024/11/4.
//

#import "AUIShortVideoListConstants.h"

@implementation AUIShortVideoListConstants

#pragma mark - VideoInfoListURL

// 示例视频信息列表的 URL - 网络视频源（默认）
static NSString * const kDefaultVideoInfoListURL = @"https://alivc-demo-cms.alicdn.com/versionProduct/resources/shortdrama/video-info-list-default.json";

// 默认视频信息列表 URL
+ (NSString *)defaultVideoInfoListURL {
    return kDefaultVideoInfoListURL; // 返回默认视频信息列表的 URL
}

#pragma mark - PlayerPoolCapacity

// 播放器池容量的默认值
static NSInteger const kDefaultPlayerPoolCapacity = 2;

// 播放器池容量的默认值
static NSInteger _playerPoolCapacity = kDefaultPlayerPoolCapacity;

// 获取播放器池容量
+ (NSInteger)playerPoolCapacity {
    return _playerPoolCapacity; // 返回当前播放器池的容量
}

// 设置播放器池容量
+ (void)setPlayerPoolCapacity:(NSInteger)capacity {
    _playerPoolCapacity = capacity; // 更新播放器池容量
}


#pragma mark - CoverURLStrategy

// 封面 URL 策略状态的默认值
// FIXME: 请在正式发版前确认是否需要启用封面 URL 策略
static BOOL const kEnableCoverURLStrategy = YES;

// 启用封面 URL 策略，默认开启
static BOOL _enableCoverURLStrategy = kEnableCoverURLStrategy;

// 获取是否启用封面 URL 策略
+ (BOOL)enableCoverURLStrategy {
    return _enableCoverURLStrategy; // 返回当前是否启用封面 URL 策略
}

// 设置是否启用封面 URL 策略
+ (void)setEnableCoverURLStrategy:(BOOL)enabled {
    _enableCoverURLStrategy = enabled; // 更新封面 URL 策略的启用状态
}

#pragma mark - Enable Advertisement

// 广告页策略的默认值
static BOOL _enableAdvertisementPage = NO;

// 获取是否启用广告页策略
+ (BOOL)enableAdvertisementPage {
    return _enableAdvertisementPage;
}

// 设置是否启用广告页
+ (void)setEnableAdvertisementPage:(BOOL)enable {
    _enableAdvertisementPage = enable;
}

@end
