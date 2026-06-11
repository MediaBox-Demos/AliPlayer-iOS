//
//  AUIShortVideoListUtils.m
//  AUIPlayer
//
//  Created by keria on 2024/11/4.
//

#import "AUIShortVideoListUtils.h"

static NSString * const kTimeProfileLogTag = @"TimeProfile";

#pragma mark - UI

// 定义透明图像
UIImage *TransparentImage(void) {
    static UIImage *transparentImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 0.0);
        [[UIColor clearColor] setFill];
        UIRectFill(CGRectMake(0, 0, 1, 1));
        transparentImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return transparentImage;
}

@implementation AUIShortVideoListUtils

// 根据设备的安全区域动态获取顶部Tab Bar需要预留的额外高度。
+ (CGFloat)additionalTopPaddingForTabBar {
    return [AUIShortVideoListUtils additionalTopPaddingForTabBar:0];
}

// 返回选项卡栏的额外顶部填充
+ (CGFloat)additionalTopPaddingForTabBar:(CGFloat)offset {
    CGFloat additionalPadding = 20 + offset;
    
    if (@available(iOS 11.0, *)) {
        additionalPadding += 24;
    }
    
    return additionalPadding;
}


#pragma mark - TimeProfile

// 打印函数耗时及线程情况
+ (void)timeProfile:(NSString *)method startTime:(long)timeMills {
    NSString *threadName = [NSThread isMainThread] ? @"MAIN" : @"SUB"; // 获取当前线程信息
    NSLog(@"[T][%@][%@][%@][%ldms]", kShortVideoListLogTag, method, threadName, [AUIShortVideoListUtils currentTimeMillis] - timeMills);
}

// 获取当前时间戳（毫秒级）
+ (long)currentTimeMillis {
    return [[NSDate date] timeIntervalSince1970] * 1000; // 获取当前时间（毫秒）
}


#pragma mark - DataConverter

// 将 NSArray 打印为一行字符串
+ (NSString *)printArray:(NSArray *)array {
    if (!array) {
        return @"nil";
    }
    
    NSMutableArray<NSString *> *stringArray = [NSMutableArray array];
    
    // 遍历数组，将每个元素转为字符串
    for (NSObject *obj in array) {
        [stringArray addObject:[obj description]];
    }
    
    // 使用逗号加空格连接每个元素
    return [stringArray componentsJoinedByString:@", "];
}

// 将一个 C 风格的整型数组转换为不可变的 NSArray<NSNumber *>
+ (NSArray<NSNumber *> *)convertToNSArray:(const int [])windows withLength:(NSUInteger)length {
    // 创建一个可变数组来存储 NSNumber 对象
    NSMutableArray<NSNumber *> *mutableArray = [NSMutableArray arrayWithCapacity:length];
    
    // 遍历静态数组并将每个元素转换为 NSNumber 并添加到可变数组中
    for (NSUInteger i = 0; i < length; i++) {
        [mutableArray addObject:@(windows[i])];
    }
    
    // 返回不可变数组
    return [mutableArray copy];
}

#pragma mark - FileUtility

// 确保指定路径下的目录存在。如果目录不存在，则尝试创建此目录并创建所有必需的中间目录。
+ (BOOL)ensureDirectoryExistsAtPath:(NSString *)path error:(NSError **)error {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:path]) {
        return [fileManager createDirectoryAtPath:path
                       withIntermediateDirectories:YES
                                        attributes:nil
                                             error:error];
    }
    
    return YES; // Directory already exists
}

#pragma mark - Others

// 检查给定的字符串是否是有效的 URL
+ (BOOL)isValidURLString:(NSString *)urlString {
    // 检查字符串是否为空
    if (urlString == nil || urlString.length == 0) {
        return NO;
    }

    // 创建 NSURL 对象
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 检查 NSURL 是否有效
    return url != nil && url.scheme != nil && url.host != nil;
}

@end
