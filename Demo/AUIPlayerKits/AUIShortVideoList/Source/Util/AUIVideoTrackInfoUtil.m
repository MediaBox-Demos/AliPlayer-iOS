//
//  AUIVideoTrackInfoUtil.m
//  AUIPlayer
//
//  Created by keria on 2024/11/20.
//

#import "AUIVideoTrackInfoUtil.h"

@implementation AUIVideoTrackInfoUtil

// 定义分辨率与对应宽高的映射
static NSDictionary<NSString *, NSArray<NSNumber *> *> *trackInfoResolutions;

// 类的首次加载
+ (void)initialize {
    if (self == [AUIVideoTrackInfoUtil self]) {
        // 在类第一次加载时初始化静态数组
        trackInfoResolutions = @{
            @"144P" : @[@144, @256],
            @"240P" : @[@240, @426],
            @"360P" : @[@360, @640],
            @"480P" : @[@480, @854],
            @"540P" : @[@540, @960],
            @"720P" : @[@720, @1280],
            @"1080P" : @[@1080, @1920],
            @"1440P" : @[@1440, @2560],
            @"2160P" : @[@2160, @3840],
            @"4320P" : @[@4320, @7680]
        };
    }
}

// 获取工具类的单例实例
+ (instancetype)sharedInstance {
    static AUIVideoTrackInfoUtil *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AUIVideoTrackInfoUtil alloc] init];
    });
    return sharedInstance;
}

// 过滤并返回仅包含视频清晰度轨的列表
+ (NSArray<AVPTrackInfo *> *)filterVideoTrackInfoList:(NSArray<AVPTrackInfo *> *)trackInfoList {
    NSMutableArray<AVPTrackInfo *> *videoTrackInfoList = [NSMutableArray arrayWithCapacity:4];
    if (trackInfoList == nil || trackInfoList.count == 0) {
        return videoTrackInfoList;
    }
    
    for (AVPTrackInfo *trackInfo in trackInfoList) {
        int width = trackInfo.videoWidth;
        int height = trackInfo.videoHeight;
        
        // 检查是否是视频轨道类型，并且宽高都大于0
        if (trackInfo && trackInfo.trackType == AVPTRACK_TYPE_VIDEO && width > 0 && height > 0) {
            [videoTrackInfoList addObject:trackInfo];
        }
    }

    return [videoTrackInfoList copy];
}

// 获取视频轨的质量描述
+ (NSString *)getQuality:(AVPTrackInfo *)trackInfo {
    return trackInfo ? [self findResolution:trackInfo] : @"AUTO";
}

// 遍历并找到最接近的视频清晰度
+ (NSString *)findResolution:(AVPTrackInfo *)trackInfo {
    // 默认的分辨率描述，如果找不到合适的
    NSString *nearestResolution = @"unknown";
    
    // 如果 trackInfo 无效或不是视频轨道，返回默认描述
    if (trackInfo == nil || trackInfo.trackType != AVPTRACK_TYPE_VIDEO) {
        return nearestResolution;
    }
    
    int width = trackInfo.videoWidth;
    int height = trackInfo.videoHeight;
    
    // 如果宽度或高度无效，返回默认描述
    if (width <= 0 || height <= 0) {
        return nearestResolution;
    }
    
    // 初始化最小差异值为最大整数值
    NSInteger minDifference = NSIntegerMax;
    
    // 遍历预定义的分辨率映射，找到差异最小的分辨率
    for (NSString *resolutionKey in trackInfoResolutions) {
        NSArray<NSNumber *> *resolutionValues = trackInfoResolutions[resolutionKey];
        int resWidth = [resolutionValues[0] intValue];
        int resHeight = [resolutionValues[1] intValue];
        
        int difference = abs(resWidth - width) + abs(resHeight - height);
        
        if (difference < minDifference) {
            minDifference = difference;
            nearestResolution = resolutionKey;
        }
    }
    
    return nearestResolution;
}

@end
