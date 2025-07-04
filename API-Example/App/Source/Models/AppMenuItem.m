//
//  AppMenuItem.m
//  App
//
//  Created by keria on 2025/6/3.
//

#import "AppMenuItem.h"

@implementation AppMenuItem

// 初始化菜单项
- (instancetype)initWithType:(AppMenuItemType)type
                       title:(NSString *)title
                      schema:(nullable NSString *)schema
                 description:(nullable NSString *)description {
    self = [super init];
    if (self) {
        _type = type;
        _title = [title copy];
        _schema = [schema copy];
        _itemDescription = [description copy];
    }
    return self;
}

// 创建标题类型的菜单项
+ (instancetype)createHeaderWithTitle:(NSString *)title {
    return [[self alloc] initWithType:AppMenuItemTypeHeader
                                title:title
                               schema:nil
                          description:nil];
}

// 创建项目类型的菜单项
+ (instancetype)createItemWithTitle:(NSString *)title
                             schema:(NSString *)schema
                        description:(NSString *)description {
    return [[self alloc] initWithType:AppMenuItemTypeItem
                                title:title
                               schema:schema
                          description:description];
}

@end
