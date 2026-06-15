//
//  CustomStyleExternalSubtitleViewController.m
//  CustomStyledSubtitle
//
//  Created by 叶俊辉 on 2026/1/15.
//

#import "CustomStyleExternalSubtitleViewController.h"
#import "AliyunPlayer/AVPDelegate.h"
#import "AliyunPlayer/AliVttSubtitleView.h"
#import <CoreText/CTFontManager.h>
#import <Common/Common.h>

// 可选(非必需):播放起始位置(单位:毫秒)
static const NSInteger kVideoStartTimeMills = 17 * 1000;

#pragma mark - 自定义字幕渲染实现

/**
 * @class CustomFontVttRenderImpl
 * @brief 自定义字幕渲染实现类
 * @discussion 继承自 AliVttRenderImpl，实现自定义字幕样式渲染
 *             支持以下功能：
 *             1. 从 Bundle 或文件路径加载自定义字体
 *             2. 根据字幕内容自动选择合适的字体(支持阿拉伯语、CJK等)
 *             3. 应用字体样式(粗体、斜体)
 *             4. 自定义字体颜色和大小
 *             5. 字体缓存管理
 */
@interface CustomFontVttRenderImpl : AliVttRenderImpl

/// 自定义字体缓存字典，key为字体ID，value为UIFont对象
@property (nonatomic, strong) NSMutableDictionary<NSString *, UIFont *> *customFonts;

/// 默认字体名称
@property (nonatomic, strong) NSString *defaultFontName;

@end

@implementation CustomFontVttRenderImpl

#pragma mark - 初始化方法

/**
 * 初始化方法
 * @return CustomFontVttRenderImpl 实例
 */
- (instancetype)init {
    self = [super init];
    if (self) {
        _customFonts = [NSMutableDictionary dictionary];
        [self initializeFonts];
    }
    return self;
}

/**
 * 初始化字体
 * @discussion 预加载常用字体，包括默认字体、粗体、阿拉伯语字体、CJK字体
 */
- (void)initializeFonts {
    // 预加载常用字体
    [self loadFontFromBundle:@"default" fontFileName:@"LongCang-Regular.ttf" fontSize:20];
    [self loadFontFromBundle:@"bold" fontFileName:@"NotoSans-Bold.ttf" fontSize:20];
    [self loadFontFromBundle:@"arabic" fontFileName:@"NotoSansArabic-Regular.ttf" fontSize:20];
    [self loadFontFromBundle:@"cjk" fontFileName:@"NotoSansCJK-Regular.ttf" fontSize:20];
    
    self.defaultFontName = @"default";
}

#pragma mark - 字体加载方法

/**
 * 从 Bundle 加载字体
 * @param fontId 字体标识符，用于后续引用
 * @param fileName 字体文件名(包含扩展名)
 * @param size 字体大小
 */
- (void)loadFontFromBundle:(NSString *)fontId
              fontFileName:(NSString *)fileName
                  fontSize:(CGFloat)size {
    NSString *fontPath = [[NSBundle mainBundle] pathForResource:fileName.stringByDeletingPathExtension
                                                         ofType:fileName.pathExtension];
    if (fontPath) {
        NSURL *fontURL = [NSURL fileURLWithPath:fontPath];
        CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)fontURL);
        CGFontRef cgFont = CGFontCreateWithDataProvider(fontDataProvider);
        
        if (cgFont) {
            CFErrorRef error = NULL;
            if (CTFontManagerRegisterGraphicsFont(cgFont, &error)) {
                NSString *fontName = (__bridge_transfer NSString *)CGFontCopyPostScriptName(cgFont);
                UIFont *font = [UIFont fontWithName:fontName size:size];
                if (font) {
                    self.customFonts[fontId] = font;
                    NSLog(@"字体加载成功: %@ (%@)", fontId, fontName);
                }
            } else {
                // 注册失败：处理并释放 error
                if (error) {
                    NSLog(@"字体注册失败: %@, 错误: %@", fileName, (__bridge NSError *)error);
                    CFRelease(error); // 释放 CFErrorRef，避免内存泄漏
                } else {
                    NSLog(@"字体注册失败: %@", fileName);
                }
            }
            CGFontRelease(cgFont);
        }

        CGDataProviderRelease(fontDataProvider);
    } else {
        NSLog(@"字体文件未找到: %@", fileName);
    }
}

/**
 * 从文件路径加载字体
 * @param fontId 字体标识符，用于后续引用
 * @param filePath 字体文件的完整路径
 * @param size 字体大小
 */
- (void)loadFontFromFile:(NSString *)fontId
                filePath:(NSString *)filePath
                fontSize:(CGFloat)size {
    NSURL *fontURL = [NSURL fileURLWithPath:filePath];
    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)fontURL);
    CGFontRef cgFont = CGFontCreateWithDataProvider(fontDataProvider);
    
    if (cgFont) {
        CFErrorRef error = NULL;
        if (CTFontManagerRegisterGraphicsFont(cgFont, &error)) {
            NSString *fontName = (__bridge_transfer NSString *)CGFontCopyPostScriptName(cgFont);
            UIFont *font = [UIFont fontWithName:fontName size:size];
            if (font) {
                self.customFonts[fontId] = font;
                NSLog(@"外部字体加载成功: %@ from %@", fontId, filePath);
            }
        } else {
            // 注册失败：释放 error
            if (error) {
                NSLog(@"字体注册失败: %@, 错误: %@", filePath, (__bridge NSError *)error);
                CFRelease(error); // 释放 CFErrorRef，避免内存泄漏
            } else {
                NSLog(@"字体注册失败: %@", filePath);
            }
        }
        CGFontRelease(cgFont);
    }
    CGDataProviderRelease(fontDataProvider);
}

#pragma mark - 字体自定义方法

/**
 * 自定义字体
 * @param originalFont 原始字体
 * @param contentAttribute 字幕内容属性
 * @param text 字幕文本内容
 * @return 自定义后的字体，如果没有匹配的自定义字体则返回原始字体
 */
- (UIFont *)customizeFont:(UIFont *)originalFont
         contentAttribute:(VttContentAttribute *)contentAttribute
              contentText:(NSString *)text {
    
    // 根据内容属性选择合适的自定义字体
    NSString *fontId = [self selectFontId:contentAttribute contentText:text];
    
    UIFont *customFont = self.customFonts[fontId];
    if (customFont) {
        // 调整字体大小以匹配原始字体
        CGFloat targetSize = originalFont.pointSize;
        UIFont *resizedFont = [customFont fontWithSize:targetSize];
        
        // 应用粗体和斜体
        if (contentAttribute.mBold || contentAttribute.mItalic) {
            resizedFont = [self applyFontTraits:resizedFont
                                         isBold:contentAttribute.mBold
                                       isItalic:contentAttribute.mItalic];
        }
        
        NSLog(@"应用自定义字体: %@ (大小: %.1f)", fontId, targetSize);
        return resizedFont;
    }
    
    // 回退到原始字体
    return originalFont;
}

/**
 * 选择字体ID
 * @param contentAttribute 字幕内容属性
 * @param text 字幕文本内容
 * @return 字体ID
 * @discussion 根据以下优先级选择字体：
 *             1. 字体名称匹配
 *             2. 文本内容特征(阿拉伯语、CJK等)
 *             3. 字体样式(粗体)
 *             4. 默认字体
 */
- (NSString *)selectFontId:(VttContentAttribute *)contentAttribute
               contentText:(NSString *)text {
    
    // 根据字体名称选择
    if (contentAttribute.fontName) {
        NSString *fontName = contentAttribute.fontName.lowercaseString;
        
        if ([fontName containsString:@"arabic"] && self.customFonts[@"arabic"]) {
            return @"arabic";
        }
        
        if (([fontName containsString:@"cjk"] ||
             [fontName containsString:@"chinese"] ||
             [fontName containsString:@"noto"]) && self.customFonts[@"cjk"]) {
            return @"cjk";
        }
        
        // 直接匹配字体ID
        if (self.customFonts[fontName]) {
            return fontName;
        }
    }
    
    // 根据文本内容选择
    if ([self containsArabicCharacters:text] && self.customFonts[@"arabic"]) {
        return @"arabic";
    }
    
    if ([self containsCJKCharacters:text] && self.customFonts[@"cjk"]) {
        return @"cjk";
    }
    
    // 粗体字体
    if (contentAttribute.mBold && self.customFonts[@"bold"]) {
        return @"bold";
    }
    
    // 默认字体
    return self.defaultFontName ?: @"default";
}

/**
 * 应用字体特征(粗体、斜体)
 * @param font 原始字体
 * @param isBold 是否粗体
 * @param isItalic 是否斜体
 * @return 应用特征后的字体
 */
- (UIFont *)applyFontTraits:(UIFont *)font isBold:(BOOL)isBold isItalic:(BOOL)isItalic {
    UIFontDescriptor *descriptor = font.fontDescriptor;
    UIFontDescriptorSymbolicTraits traits = 0;
    
    if (isBold) {
        traits |= UIFontDescriptorTraitBold;
    }
    if (isItalic) {
        traits |= UIFontDescriptorTraitItalic;
    }
    
    if (traits != 0) {
        descriptor = [descriptor fontDescriptorWithSymbolicTraits:traits];
        UIFont *styledFont = [UIFont fontWithDescriptor:descriptor size:font.pointSize];
        return styledFont ?: font;
    }
    
    return font;
}

#pragma mark - 字符检测辅助方法

/**
 * 检测文本是否包含阿拉伯语字符
 * @param text 待检测文本
 * @return YES表示包含阿拉伯语字符，NO表示不包含
 */
- (BOOL)containsArabicCharacters:(NSString *)text {
    for (NSUInteger i = 0; i < text.length; i++) {
        unichar character = [text characterAtIndex:i];
        // 阿拉伯语 Unicode 范围
        if ((character >= 0x0600 && character <= 0x06FF) ||
            (character >= 0x0750 && character <= 0x077F) ||
            (character >= 0x08A0 && character <= 0x08FF)) {
            return YES;
        }
    }
    return NO;
}

/**
 * 检测文本是否包含CJK字符(中日韩文字)
 * @param text 待检测文本
 * @return YES表示包含CJK字符，NO表示不包含
 */
- (BOOL)containsCJKCharacters:(NSString *)text {
    for (NSUInteger i = 0; i < text.length; i++) {
        unichar character = [text characterAtIndex:i];
        // CJK Unicode 范围
        if ((character >= 0x4E00 && character <= 0x9FFF) ||   // 中文
            (character >= 0x3040 && character <= 0x309F) ||   // 日文平假名
            (character >= 0x30A0 && character <= 0x30FF) ||   // 日文片假名
            (character >= 0xAC00 && character <= 0xD7AF)) {   // 韩文
            return YES;
        }
    }
    return NO;
}

#pragma mark - 字体管理方法

/**
 * 获取可用字体列表
 * @return 字体ID数组
 */
- (NSArray<NSString *> *)getAvailableFonts {
    return self.customFonts.allKeys;
}

/**
 * 清除字体缓存
 */
- (void)clearFontCache {
    [self.customFonts removeAllObjects];
    NSLog(@"字体缓存已清除");
}

#pragma mark - 重写父类渲染方法

/**
 * 应用颜色样式
 * @param attrs 属性字典，用于存储颜色样式
 * @param contentAttribute 字幕内容属性
 */
- (void)applyColorStyle:(NSMutableDictionary *)attrs
       contentAttribute:(VttContentAttribute *)contentAttribute {
    
    // 强制字体颜色变为红色
    UIColor *redColor = [UIColor redColor];
    attrs[NSForegroundColorAttributeName] = redColor;
}

/**
 * 应用字体样式
 * @param attrs 属性字典，用于存储字体样式
 * @param contentAttribute 字幕内容属性
 * @param context 渲染上下文
 */
- (void)applyFontStyle:(NSMutableDictionary *)attrs
      contentAttribute:(VttContentAttribute *)contentAttribute
               context:(RenderContext *)context {
    
    NSString *fontName = contentAttribute.fontName;
    // 强制字体大小为原来的两倍
    CGFloat fontSize = (contentAttribute.fontSizePx / context.contentsScale) * 2.0;
    
    UIFont *styledFont = [self generateFontWithName:fontName
                                           fontSize:fontSize
                                             isBold:contentAttribute.mBold
                                           isItalic:contentAttribute.mItalic];
    
    UIFont *customizedFont = [self customizeFont:styledFont
                                contentAttribute:contentAttribute
                                     contentText:contentAttribute.text];
    
    attrs[NSFontAttributeName] = customizedFont;
}

@end

#pragma mark - 主视图控制器

@interface CustomStyleExternalSubtitleViewController () <AVPDelegate>

#pragma mark - 播放器相关属性
/// 播放器实例
@property (nonatomic, strong) AliPlayer *player;

/// 播放器视图容器
@property (nonatomic, strong) UIView *playerView;

#pragma mark - 字幕相关属性
/// 自定义字幕视图
@property (nonatomic, strong) AliVttSubtitleView *subtitleView;

#pragma mark - 状态控制属性
/// 当前字幕轨道索引
@property (nonatomic, assign) int currentSubtitleTrackIndex;

/// 字幕是否已添加
@property (nonatomic, assign) BOOL subtitleAdded;

@end

@implementation CustomStyleExternalSubtitleViewController

#pragma mark - 生命周期方法

- (void)viewDidLoad {
    [super viewDidLoad];
    [AliPrivateService initLicenseService];
    
    // 设置页面基本属性
    self.title = @"自定义字幕样式";
    self.view.backgroundColor = [UIColor blackColor];
    
    // 初始化字幕相关状态
    self.currentSubtitleTrackIndex = -1;
    self.subtitleAdded = NO;
        
    // Step 1: 创建播放器实例
    [self setupPlayer];
    
    // Step 2: 创建自定义字幕视图
    [self setupCustomSubtitleView];

    // Step 3: 初始化UI视图
    [self setupUserInterface];

    // Step 4 & Step 5: 设置播放源并播放
    [self startPlayback];
}

- (void)dealloc {
    [self cleanupPlayer];
}

#pragma mark - Step 1: 播放器初始化

/**
 * Step 1: 创建播放器实例
 */
- (void)setupPlayer {
    // 1.1 创建播放器实例
    self.player = [[AliPlayer alloc] init];

    if (_player) {
        // 1.2 设置播放器代理
        _player.delegate = self;
        
        // 1.3 设置播放场景
        [self.player setPlayerScene:SceneLong];

        NSLog(@"[Step 1] 播放器实例创建成功");
    }
    
    // 可选:推荐使用`播放器单点追查`功能，当使用阿里云播放器 SDK 播放视频发生异常时，可借助单点追查功能针对具体某个用户或某次播放会话的异常播放行为进行全链路追踪，以便您能快速诊断问题原因，可有效改善播放体验治理效率。
    // traceId 值由您自行定义，需为您的用户或用户设备的唯一标识符，例如传入您业务的 userid 或者 IMEI、IDFA 等您业务用户的设备 ID。
    // 传入 traceId 后，埋点日志上报功能开启，后续可以使用播放质量监控、单点追查和视频播放统计功能。
    // 文档:https://help.aliyun.com/zh/vod/developer-reference/single-point-tracing
    //[self.player setTraceID:traceId];

    NSLog(@"[Step 1] 播放器创建完成: %@", self.player);
}

#pragma mark - Step 2: 自定义字幕视图初始化

/**
 * Step 2: 创建自定义字幕视图
 */
- (void)setupCustomSubtitleView {
    // 2.1 创建字幕视图实例
    self.subtitleView = [[AliVttSubtitleView alloc] init];
    
    // 2.2 设置自定义渲染工厂
    [self.subtitleView setRenderImplFactory:^AliVttRenderImpl*() {
        CustomFontVttRenderImpl *impl = [[CustomFontVttRenderImpl alloc] init];
        
        // 可选：加载额外的外部字体
        // [impl loadFontFromFile:@"custom_bold"
        //               filePath:@"../Example/LongCang-Regular.ttf"
        //               fontSize:20];
        
        return impl;
    }];
    
    // 2.3 将字幕视图关联到播放器
    [self.player setExternalSubtitleView:self.subtitleView];
    
    NSLog(@"[Step 2] 自定义字幕视图创建完成");
}

#pragma mark - Step 3: UI界面初始化

/**
 * Step 3: 初始化UI视图
 */
- (void)setupUserInterface {
    // 3.1 创建播放器视图容器
    [self setupPlayerView];

    NSLog(@"[Step 3] UI界面初始化完成");
}

/**
 * 3.1 创建用于承载播放画面的视图容器，并设置播放器渲染视图
 */
- (void)setupPlayerView {
    self.playerView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.playerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.playerView];

    // 设置播放器渲染视图
    self.player.playerView = self.playerView;
}

#pragma mark - Step 4 & Step 5: 播放源设置和播放准备

/**
 * Step 4: 设置播放源 & Step 5: 开始播放
 */
- (void)startPlayback {
    // Step 4: 创建播放源对象并设置播放地址
    AVPUrlSource *urlSource = [[AVPUrlSource alloc] urlWithString:kSampleVttSubtitleVideoURL];
    [self.player setUrlSource:urlSource];

    // 可选(非必需):设置视频播放起始位置
    // AVP_SEEKMODE_ACCURATE 表示精准 seek 到指定时间戳的位置播放，AVP_SEEKMODE_INACCURATE 表示 seek 到离指定时间戳最近的关键帧位置播放
    [self.player setStartTime:kVideoStartTimeMills seekMode:AVP_SEEKMODE_INACCURATE];
    
    // Step 5: 准备播放
    [self.player prepare];
    // prepare 以后可以同步调用 start 操作，onPrepared 回调完成后会自动起播
    [self.player start];

    NSLog(@"[Step 4&5] 开始播放视频: %@", kSampleVttSubtitleVideoURL);
}

#pragma mark - Step 6 & Step 7: 播放器事件处理和字幕设置

/**
 * Step 6: 播放器事件处理
 */
- (void)onPlayerEvent:(AliPlayer *)player eventType:(AVPEventType)eventType {
    switch (eventType) {
        case AVPEventPrepareDone:
            // Step 7: 设置播放器准备完成后的处理
            [self handlePlayerPrepared:player];
            break;

        case AVPEventCompletion:
            NSLog(@"播放完成");
            break;

        case AVPEventLoadingStart:
            NSLog(@"开始加载");
            break;

        case AVPEventLoadingEnd:
            NSLog(@"加载结束");
            break;

        default:
            break;
    }
}

/**
 * 处理播放器准备完成事件
 */
- (void)handlePlayerPrepared:(AliPlayer *)player {
    // Step 7: 字幕设置(需要在准备完成后进行设置)
    if (kSampleExternalSubtitleVttURL != nil && kSampleExternalSubtitleVttURL.length > 0) {
        [self.player addExtSubtitle:kSampleExternalSubtitleVttURL];
        NSLog(@"[Step 7] 添加外挂字幕: %@", kSampleExternalSubtitleVttURL);
    }
}

/**
 * 播放器错误回调
 */
- (void)onError:(AliPlayer *)player errorModel:(AVPErrorModel *)errorModel {
    NSLog(@"播放器错误: %@", errorModel.message);
}

#pragma mark - Step 8: 字幕监听回调方法

/**
 * Step 8: 设置字幕监听
 */

/**
 * 外挂字幕被添加
 * @param player 播放器player指针
 * @param trackIndex 字幕显示的索引号
 * @param URL 字幕url
 */
- (void)onSubtitleExtAdded:(AliPlayer *)player trackIndex:(int)trackIndex URL:(NSString *)URL {
    NSLog(@"外挂字幕添加成功 - trackIndex: %d, URL: %@", trackIndex, URL);
    
    // 记录字幕轨道索引
    self.currentSubtitleTrackIndex = trackIndex;
    self.subtitleAdded = YES;
    
    // 选择并启用字幕轨道
    [self.player selectExtSubtitle:trackIndex enable:YES];
}

/**
 * 字幕头信息回调
 * @param player 播放器player指针
 * @param trackIndex 字幕显示的索引号
 * @param header 字幕头信息
 */
- (void)onSubtitleHeader:(AliPlayer *)player trackIndex:(int)trackIndex Header:(NSString *)header {
    NSLog(@"字幕头信息 - trackIndex: %d, header: %@", trackIndex, header);
    
    if (self.subtitleView) {
        [self.subtitleView setVttHeader:player trackIndex:trackIndex Header:header];
    }
}

/**
 * 字幕显示回调
 * @param player 播放器player指针
 * @param trackIndex 字幕显示的索引号
 * @param subtitleID 字幕ID
 * @param subtitle 字幕内容
 */
- (void)onSubtitleShow:(AliPlayer *)player trackIndex:(int)trackIndex subtitleID:(long)subtitleID subtitle:(NSString *)subtitle {
    NSLog(@"显示字幕 - trackIndex: %d, subtitleID: %ld, subtitle: %@", trackIndex, subtitleID, subtitle);
    
    if (self.subtitleView) {
        [self.subtitleView show:player trackIndex:trackIndex subtitleID:subtitleID subtitle:subtitle];
    }
}

/**
 * 字幕隐藏回调
 * @param player 播放器player指针
 * @param trackIndex 字幕显示的索引号
 * @param subtitleID 字幕ID
 */
- (void)onSubtitleHide:(AliPlayer *)player trackIndex:(int)trackIndex subtitleID:(long)subtitleID {
    NSLog(@"隐藏字幕 - trackIndex: %d, subtitleID: %ld", trackIndex, subtitleID);
    
    if (self.subtitleView) {
        [self.subtitleView hide:player trackIndex:trackIndex subtitleID:subtitleID];
    }
}

#pragma mark - Step 9: 资源清理

/**
 * Step 9: 清理播放器资源
 */
- (void)cleanupPlayer {
    if (self.player) {
        // 解绑播放器视图
        self.player.playerView = nil;
        // 9.1 停止播放
        [self.player stop];

        // 9.2 销毁播放器实例
        [self.player destroy];

        // 9.3 清空引用，避免内存泄漏
        self.player = nil;
        self.subtitleView = nil;

        NSLog(@"[Step 9] 播放器资源清理完成");
    }
}

@end
