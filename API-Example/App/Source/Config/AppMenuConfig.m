//
//  AppMenuConfig.m
//  App
//
//  Created by keria on 2025/6/3.
//

#import "AppMenuConfig.h"
#import "AppMenuItem.h"
#import <Common/CommonConstants.h>
#import <Common/CommonLocalizedStrings.h>

@implementation AppMenuConfig

// 获取应用程序的配置菜单项
+ (NSArray<AppMenuItem *> *)getMenuItems {
    NSMutableArray<AppMenuItem *> *menuItems = [NSMutableArray array];
    
    // 添加基础功能分类header
    AppMenuItem *basicHeader = [AppMenuItem createHeaderWithTitle:AppGetString(@"app.menu.basic_features")];
    [menuItems addObject:basicHeader];
    
    // 添加基础播放项
    AppMenuItem *basicPlayback = [AppMenuItem createItemWithTitle:AppGetString(@"app.basic.playback.title")
                                                           schema:kSchemaBasicPlayback
                                                      description:AppGetString(@"app.basic.playback.description")];
    [menuItems addObject:basicPlayback];
    
    // 创建直播流展开项，包含基础直播和RTS直播
    AppMenuItem *basicLiveStream = [AppMenuItem createItemWithTitle:AppGetString(@"app.basic.livestream.title")
                                                             schema:kSchemaBasicLiveStream
                                                        description:AppGetString(@"app.basic.livestream.description")];
    
    AppMenuItem *rtsLiveStream = [AppMenuItem createItemWithTitle:AppGetString(@"app.basic.rts.title")
                                                           schema:kSchemaRtsLiveStream
                                                      description:AppGetString(@"app.basic.rts.description")];
    
    NSArray<AppMenuItem *> *liveStreamSubItems = @[basicLiveStream, rtsLiveStream];
    AppMenuItem *liveStreamExpandable = [AppMenuItem createExpandableItemWithTitle:AppGetString(@"app.menu.expand.liveStream.title")
                                                                       description:AppGetString(@"app.menu.expand.liveStream.description")
                                                                          subItems:liveStreamSubItems];
    [menuItems addObject:liveStreamExpandable];
    
    // 添加进阶功能分类header
    AppMenuItem *advancedHeader = [AppMenuItem createHeaderWithTitle:AppGetString(@"app.menu.advanced_features")];
    [menuItems addObject:advancedHeader];
    
    // 添加画中画（基于系统默认方案）
    AppMenuItem *pipDefault = [AppMenuItem createItemWithTitle:AppGetString(@"app.advanced.pipdefault.title")
                                                             schema:kSchemaPipDefault
                                                        description:AppGetString(@"app.advanced.pipdefault.description")];
    
    
    // 添加画中画（基于 SampleBufferDisplayLayer 渲染方案）
    AppMenuItem *pipDisplayLayer = [AppMenuItem createItemWithTitle:AppGetString(@"app.advanced.pipdisplaylayer.title")
                                                             schema:kSchemaPipDisplayLayer
                                                      description:AppGetString(@"app.advanced.pipdisplaylayer.description")];
    
    NSArray<AppMenuItem *> *pipSubItems = @[pipDefault, pipDisplayLayer];
    AppMenuItem *pipExpandable = [AppMenuItem createExpandableItemWithTitle:AppGetString(@"app.menu.expand.pip.title")
                                                                       description:AppGetString(@"app.menu.expand.pip.description")
                                                                          subItems:pipSubItems];
    [menuItems addObject:pipExpandable];
    
    // 添加悬浮窗项
    AppMenuItem *floatWindow = [AppMenuItem createItemWithTitle:AppGetString(@"app.advanced.floatWindow.title")
                                                         schema:kSchemaFloatWindow
                                                    description:AppGetString(@"app.advanced.floatWindow.description")];
    [menuItems addObject:floatWindow];
    
    // 添加缩略图项
    AppMenuItem *thumbnail = [AppMenuItem createItemWithTitle:AppGetString(@"app.advanced.thumbnail.title")
                                                       schema:kSchemaThumbnailStream
                                                  description:AppGetString(@"app.advanced.thumbnail.description")];
    [menuItems addObject:thumbnail];
    
    // 创建外挂字幕展开项，包含外挂字幕（推荐）和外挂字幕（SubtitleView）
    AppMenuItem *vttSubtitle = [AppMenuItem createItemWithTitle:AppGetString(@"app.advanced.externalSubtitleVtt.title")
                                                           schema:kSchemaExternalSubtitleVttStream
                                                      description:AppGetString(@"app.advanced.externalSubtitleVtt.description")];
    
    AppMenuItem *externalSubtitle = [AppMenuItem createItemWithTitle:AppGetString(@"app.advanced.externalSubtitle.title")
                                                             schema:kSchemaExternalSubtitleStream
                                                        description:AppGetString(@"app.advanced.externalSubtitle.description")];
    
    NSArray<AppMenuItem *> *subtitleSubItems = @[vttSubtitle, externalSubtitle];
    AppMenuItem *subtitleExpandable = [AppMenuItem createExpandableItemWithTitle:AppGetString(@"app.menu.expand.externalSubtitle.title")
                                                                       description:AppGetString(@"app.menu.expand.externalSubtitle.description")
                                                                          subItems:subtitleSubItems];
    [menuItems addObject:subtitleExpandable];
        
    // 添加预加载项
    AppMenuItem *preload = [AppMenuItem createItemWithTitle:AppGetString(@"app.advanced.preload.title")
                                                     schema:kSchemaPreloadStream
                                                description:AppGetString(@"app.advanced.preload.description")];
    [menuItems addObject:preload];
    
    // 添加安全下载项
    AppMenuItem *downloader = [AppMenuItem createItemWithTitle:AppGetString(@"app.advanced.downloader.title")
                                                        schema:kSchemaDownloader
                                                   description:AppGetString(@"app.advanced.downloader.description")];
    [menuItems addObject:downloader];
    
    // 添加多清晰度切换项
    AppMenuItem *multiResolution = [AppMenuItem createItemWithTitle:AppGetString(@"app.advanced.multi.title")
                                                             schema:kSchemaMultiResolution
                                                        description:AppGetString(@"app.advanced.multi.description")];
    [menuItems addObject:multiResolution];
    
    return [menuItems copy];
}

@end
