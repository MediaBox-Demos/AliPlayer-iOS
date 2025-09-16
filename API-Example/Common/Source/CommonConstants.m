//
//  CommonConstants.m
//  Common
//
//  Created by keria on 2025/6/4.
//

#import "CommonConstants.h"

@implementation CommonConstants

#pragma mark - Schema Constants

// Complete schema URLs
NSString *const kSchemaBasicPlayback = @"demo://basic/playback";
NSString *const kSchemaBasicLiveStream = @"demo://basic/livestream";
NSString *const kSchemaRtsLiveStream = @"demo://basic/rtsLiveStream";

NSString *const kSchemaThumbnailStream = @"demo://advanced/thumbnail";
NSString *const kSchemaExternalSubtitleStream = @"demo://advanced/externalSubtitle";
NSString *const kSchemaPreloadStream = @"demo://advanced/preload";
NSString *const kSchemaDownloader = @"demo://advanced/downloader";
NSString *const kSchemaPipDemo = @"demo://advanced/pipDemo";
NSString *const kSchemaFloatWindow = @"demo://advanced/floatWindow";
NSString *const kSchemaMultiResolution = @"demo://advanced/multiResolution";
#pragma mark - Module Category Constants

// Module categories
NSString *const kModuleCategoryBasic = @"basic";
NSString *const kModuleCategoryAdvanced = @"advanced";

#pragma mark - Module Info Keys

// Module info keys
NSString *const kModuleInfoKeyTitle = @"title";
NSString *const kModuleInfoKeySchema = @"schema";
NSString *const kModuleInfoKeyDescription = @"description";
NSString *const kModuleInfoKeyCategory = @"category";

#pragma mark - Data Source Constants

// URL of the sample video file
NSString *const kSampleVideoURL = @"https://alivc-demo-vod.aliyuncs.com/6b357371ef3c45f4a06e2536fd534380/53733986bce75cfc367d7554a47638c0-fd.mp4";
// URL of the sample livestream video file
// FIXME: Need to fill in the live stream, otherwise it will affect the basic live module
NSString *const kSampleLiveStreamVideoURL = @"";
// URL of the sample switch livestream video file
// FIXME: Need to fill in the live stream, otherwise it will affect the basic live module
NSString *const kSampleSwitchLiveStreamVideoURL = @"";
// URL of the RTS Live-stream
// FIXME: Need to fill in the artc live stream, otherwise it will affect the rts module
NSString *const kRTSLiveStreamURL = @"";
// URL of the MultiResolution
NSString *const kMultiResolutionURL = @"https://alivc-demo-vod.aliyuncs.com/d055a20270a671ef9d064531858c0102/cb2edb31f9674fb880462d8068b4cfd5.m3u8";
// URL of the sample thumbnail
NSString *const kSampleVideoThumbnailURL = @"https://alivc-demo-vod.aliyuncs.com/sv/5f2e5b7f-191dbfe2558/5f2e5b7f-191dbfe2558.mp4";
// URL of the sample thumbnail
NSString *const kSampleThumbnailURL = @"https://llk-beijng.oss-cn-beijing.aliyuncs.com/vod-e3ddeb/005d826e483171f0bfb316b5feac0102/snapshots/webvtt/15483839-19768706593-1833-2022-301-08227.vtt";

// URL of the sample video external subtitle
NSString *const kSampleVideoExternalSubtitleURL = @"https://alivc-demo-vod.aliyuncs.com/6b357371ef3c45f4a06e2536fd534380/53733986bce75cfc367d7554a47638c0-fd.mp4";
// URL of the sample external subtitle
NSString *const kSampleExternalSubtitleURL = @"https://alivc-player.oss-cn-shanghai.aliyuncs.com/API-Example-File/long-video.srt";

// URL of the sample video PreloadUrl
NSString *const kSampleVideoPreloadURL = @"https://alivc-demo-vod.aliyuncs.com/sv/5f2e5b7f-191dbfe2558/5f2e5b7f-191dbfe2558.mp4";

// URL of the sample request Vid
NSString *const kSampleRequestVid = @"6609a2f737cb43e1a79ec2bc6aee781b";
// Vid of the sample request Url
NSString *const kSampleRequestUrl = @"https://alivc-demo.aliyuncs.com/player/getVideoPlayAuth?videoId=";

// Example video VID and PlayAuth (configuration required when playing VOD)
// FIXME: Vid needs to be filled in, otherwise it will affect the preloading of the VOD module
NSString *const kSampleVid = @"";
// FIXME: PlayAuth needs to be filled in, otherwise it will affect the preloading of the VOD module
NSString *const kSamplePlayAuth = @"";

@end
