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
NSString *const kSchemaExternalSubtitleVttStream = @"demo://advanced/externalSubtitleVtt";
NSString *const kSchemaPreloadStream = @"demo://advanced/preload";
NSString *const kSchemaDownloader = @"demo://advanced/downloader";
NSString *const kSchemaPipDefault = @"demo://advanced/pipDefault";
NSString *const kSchemaPipDisplayLayer = @"demo://advanced/pipDisplayLayer";
NSString *const kSchemaFloatWindow = @"demo://advanced/floatWindow";
NSString *const kSchemaMultiResolution = @"demo://advanced/multiResolution";

#pragma mark - Module Info Keys

// Module info keys
NSString *const kModuleInfoKeyTitle = @"title";
NSString *const kModuleInfoKeySchema = @"schema";
NSString *const kModuleInfoKeyDescription = @"description";
NSString *const kModuleInfoKeyCategory = @"category";

#pragma mark - Data Source Constants

NSString *const kSampleVideoId = @"004fc90fd71d71f0bf184531958c0402";
// 客户端播放器 SDK 版本要求：使用 本地签名播放凭证（JWTPlayAuth） 进行播放时，客户端播放器 SDK 版本需要 ≥ 7.10.0，否则无法完成播放鉴权
NSString *const kSampleVideoAuth = @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6ImFwcC0xMDAwMDAwIiwidmlkZW9JZCI6IjAwNGZjOTBmZDcxZDcxZjBiZjE4NDUzMTk1OGMwNDAyIiwiY3VycmVudFRpbWVTdGFtcCI6MTc2NjEzMTE5MTYxMywiZXhwaXJlVGltZVN0YW1wIjoxOTIzODExMTkxNjEzLCJyZWdpb25JZCI6ImNuLXNoYW5naGFpIiwicGxheUNvbnRlbnRJbmZvIjp7ImZvcm1hdHMiOiJtM3U4Iiwic3RyZWFtVHlwZSI6InZpZGVvIiwiYXV0aFRpbWVvdXQiOjE4MDB9fQ.CjqZA-6okJb2PxOZr0Jjai9gWwvaNdG-bk3LWBMzhdc";

// URL of the sample video file
NSString *const kSampleVideoURL = @"https://alivc-demo-vod.aliyuncs.com/6b357371ef3c45f4a06e2536fd534380/53733986bce75cfc367d7554a47638c0-fd.mp4";
// URL of the sample subtitle vtt video file
NSString *const kSampleVttSubtitleVideoURL = @"https://alivc-demo-cms.alicdn.com/versionProduct/resources/API-Example/vtt/1406ff70-199609dae70.mp4";
// URL of the sample livestream video file
// FIXME: Need to fill in the live stream, otherwise it will affect the basic live module
NSString *const kSampleLiveStreamVideoURL = @"";
// URL of the sample switch livestream video file
// FIXME: Need to fill in the live stream, otherwise it will affect the basic live module
NSString *const kSampleSwitchLiveStreamVideoURL = @"";
// URL of the RTS Live-stream
// FIXME: Need to fill in the artc live stream, otherwise it will affect the rts module
NSString *const kRTSLiveStreamURL = @"";
// URL of the sample thumbnail
NSString *const kSampleVideoThumbnailURL = @"https://alivc-demo-vod.aliyuncs.com/sv/5f2e5b7f-191dbfe2558/5f2e5b7f-191dbfe2558.mp4";
// URL of the sample thumbnail
NSString *const kSampleThumbnailURL = @"https://llk-beijng.oss-cn-beijing.aliyuncs.com/vod-e3ddeb/005d826e483171f0bfb316b5feac0102/snapshots/webvtt/15483839-19768706593-1833-2022-301-08227.vtt";

// URL of the sample video external subtitle
NSString *const kSampleVideoExternalSubtitleURL = @"https://alivc-demo-vod.aliyuncs.com/6b357371ef3c45f4a06e2536fd534380/53733986bce75cfc367d7554a47638c0-fd.mp4";
// URL of the sample external subtitle
NSString *const kSampleExternalSubtitleURL = @"https://alivc-player.oss-cn-shanghai.aliyuncs.com/API-Example-File/long-video.srt";
// URL of the sample subtitle vtt file
NSString *const kSampleExternalSubtitleVttURL = @"https://alivc-demo-cms.alicdn.com/versionProduct/resources/API-Example/vtt/E19467B22A4F4286B462C0540F57CF46-3-3.vtt";

// URL of the sample video PreloadUrl
NSString *const kSampleVideoPreloadURL = @"https://alivc-demo-vod.aliyuncs.com/sv/5f2e5b7f-191dbfe2558/5f2e5b7f-191dbfe2558.mp4";

// URL of the sample request Vid
NSString *const kSampleRequestVid = @"6609a2f737cb43e1a79ec2bc6aee781b";
// Vid of the sample request Url
NSString *const kSampleRequestUrl = @"https://alivc-demo.aliyuncs.com/player/getVideoPlayAuth?videoId=";

// Example video VID and PlayAuth (configuration required when playing VID)
// FIXME: Vid needs to be filled in, otherwise it will affect the preloading of the VID module
NSString *const kSampleVid = @"";
// FIXME: PlayAuth needs to be filled in, otherwise it will affect the preloading of the VID module
NSString *const kSamplePlayAuth = @"";

@end
