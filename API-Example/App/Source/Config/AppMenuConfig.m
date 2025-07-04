//
//  AppMenuConfig.m
//  App
//
//  Created by keria on 2025/6/3.
//

#import "AppMenuConfig.h"
#import "AppMenuItem.h"
#import "AppModuleManager.h"
#import <Common/CommonConstants.h>
#import <Common/CommonLocalizedStrings.h>

@implementation AppMenuConfig

// 获取应用程序的配置菜单项
+ (NSArray<AppMenuItem *> *)getMenuItems {
    NSArray *moduleInfos = [[AppModuleManager sharedManager] allModuleInfos];
    NSMutableArray<AppMenuItem *> *menuItems = [NSMutableArray array];

    if (moduleInfos.count > 0) {
        // 按分类组织模块
        NSMutableDictionary<NSString *, NSMutableArray *> *categorizedModules = [NSMutableDictionary dictionary];

        for (NSDictionary *moduleInfo in moduleInfos) {
            NSString *category = moduleInfo[kModuleInfoKeyCategory];
            if (category && category.length > 0) {
                if (!categorizedModules[category]) {
                    categorizedModules[category] = [NSMutableArray array];
                }
                [categorizedModules[category] addObject:moduleInfo];
            }
        }

        // 定义分类顺序和对应的header标题
        NSArray *categoryOrder = @[ kModuleCategoryBasic, kModuleCategoryAdvanced ];
        NSDictionary *categoryHeaders = @{
            kModuleCategoryBasic : AppGetString(@"app.menu.basic_features"),
            kModuleCategoryAdvanced : AppGetString(@"app.menu.advanced_features")
        };

        // 按顺序添加各分类的header和items
        for (NSString *category in categoryOrder) {
            NSArray *categoryModules = categorizedModules[category];
            if (categoryModules.count > 0) {
                // 添加分类header
                NSString *headerTitle = categoryHeaders[category];
                AppMenuItem *headerItem = [AppMenuItem createHeaderWithTitle:headerTitle];
                if (headerItem) {
                    [menuItems addObject:headerItem];
                }

                // 添加该分类下的所有模块
                for (NSDictionary *moduleInfo in categoryModules) {
                    NSString *title = moduleInfo[kModuleInfoKeyTitle];
                    NSString *schema = moduleInfo[kModuleInfoKeySchema];
                    NSString *description = moduleInfo[kModuleInfoKeyDescription];

                    // 确保必要信息不为空才创建菜单项
                    if (title && schema && description) {
                        AppMenuItem *menuItem = [AppMenuItem createItemWithTitle:title
                                                                          schema:schema
                                                                     description:description];
                        if (menuItem) {
                            [menuItems addObject:menuItem];
                        }
                    }
                }
            }
        }
    }

    return [menuItems copy];
}

@end
