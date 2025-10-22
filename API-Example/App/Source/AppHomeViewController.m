//
//  AppHomeViewController.m
//  App
//
//  Created by keria on 2025/6/2.
//

#import "AppHomeViewController.h"
#import "AppMenuConfig.h"
#import "AppMenuItem.h"
#import "AppSchemaRouter.h"

#define kTableViewHeaderCellIdentifier @"HeaderCell"
#define kTableViewItemCellIdentifier @"ItemCell"
#define kTableViewExpandableItemCellIdentifier @"ExpandableItemCell"

@interface AppHomeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<AppMenuItem *> *menuItems;

@end

@implementation AppHomeViewController

#pragma mark - View Layout

// 视图加载完毕后的初始化设置
- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"API Example";
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }

    [self setupTableView];
    [self loadMenuData];
}

// 设置表格视图的基本配置
- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.estimatedRowHeight = 70;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    if (@available(iOS 13.0, *)) {
        self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    } else {
        self.tableView.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.0];
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}

#pragma mark - Data Source

// 从配置中加载菜单数据
- (void)loadMenuData {
    self.menuItems = [[NSMutableArray alloc] initWithArray:[AppMenuConfig getMenuItems]];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AppMenuItem *item = self.menuItems[indexPath.row];

    if (item.type == AppMenuItemTypeHeader) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewHeaderCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTableViewHeaderCellIdentifier];
        }
        [self configureHeaderCell:cell withItem:item];
        return cell;
    } else if (item.type == AppMenuItemTypeExpandable) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewExpandableItemCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kTableViewExpandableItemCellIdentifier];
        }
        [self configureExpandableItemCell:cell withItem:item];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewItemCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kTableViewItemCellIdentifier];
        }
        [self configureItemCell:cell withItem:item];
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    AppMenuItem *item = self.menuItems[indexPath.row];
    
    if (item.type == AppMenuItemTypeExpandable) {
        // 切换展开状态
        [self toggleExpansionForItem:item atIndex:indexPath.row];
    } else if (item.type == AppMenuItemTypeItem && item.schema) {
        [AppSchemaRouter navigateFromViewController:self withSchema:item.schema];
    }
}

#pragma mark - Expansion Logic

- (void)toggleExpansionForItem:(AppMenuItem *)item atIndex:(NSInteger)index {
    // 更新展开状态
    item.expanded = !item.expanded;
    
    if (item.expanded) {
        // 展开：在当前位置后插入子项
        NSUInteger insertIndex = index + 1;
        for (AppMenuItem *subItem in item.subItems) {
            [self.menuItems insertObject:subItem atIndex:insertIndex];
            insertIndex++;
        }
        // 刷新表格
        [self.tableView beginUpdates];
        NSMutableArray<NSIndexPath *> *insertIndexPaths = [NSMutableArray array];
        for (int i = 0; i < item.subItems.count; i++) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:index + 1 + i inSection:0];
            [insertIndexPaths addObject:path];
        }
        [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    } else {
        // 收起：移除子项
        NSUInteger removeCount = item.subItems.count;
        for (int i = 0; i < removeCount; i++) {
            [self.menuItems removeObjectAtIndex:index + 1];
        }
        // 刷新表格
        [self.tableView beginUpdates];
        NSMutableArray<NSIndexPath *> *removeIndexPaths = [NSMutableArray array];
        for (int i = 0; i < removeCount; i++) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:index + 1 + i inSection:0];
            [removeIndexPaths addObject:path];
        }
        [self.tableView deleteRowsAtIndexPaths:removeIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
    
    // 更新箭头动画
    [self updateArrowAnimationForExpandableItemAtIndex:index];
}

// 更新箭头动画
- (void)updateArrowAnimationForExpandableItemAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIImageView *arrowView = (UIImageView *)[cell viewWithTag:1001];
    
    if (arrowView) {
        AppMenuItem *item = self.menuItems[index];
        CGAffineTransform transform = item.expanded ? CGAffineTransformMakeRotation(M_PI_2) : CGAffineTransformIdentity;
        [UIView animateWithDuration:0.3 animations:^{
            arrowView.transform = transform;
        }];
    }
}

#pragma mark - Cell Configuration

// 配置头部单元格布局
- (void)configureHeaderCell:(UITableViewCell *)cell withItem:(AppMenuItem *)item {
    // 创建容器视图
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    UIView *containerView = [[UIView alloc] init];
    if (@available(iOS 13.0, *)) {
        containerView.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    } else {
        containerView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    }
    containerView.layer.cornerRadius = 8;
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:containerView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = item.title;
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    if (@available(iOS 13.0, *)) {
        titleLabel.textColor = [UIColor labelColor];
    } else {
        titleLabel.textColor = [UIColor darkGrayColor];
    }
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:titleLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [containerView.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:8],
        [containerView.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:15],
        [containerView.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-15],
        [containerView.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-8],
        
        [titleLabel.topAnchor constraintEqualToAnchor:containerView.topAnchor constant:12],
        [titleLabel.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:15],
        [titleLabel.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor constant:-15],
        [titleLabel.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor constant:-12]
    ]];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

// 配置普通项目单元格布局
- (void)configureItemCell:(UITableViewCell *)cell withItem:(AppMenuItem *)item {
    // 创建容器视图
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    UIView *containerView = [[UIView alloc] init];
    if (@available(iOS 13.0, *)) {
        containerView.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        containerView.backgroundColor = [UIColor whiteColor];
    }
    containerView.layer.cornerRadius = 8;
    containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    containerView.layer.shadowOffset = CGSizeMake(0, 1);
    containerView.layer.shadowOpacity = 0.1;
    containerView.layer.shadowRadius = 2;
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:containerView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = item.title;
    titleLabel.font = [UIFont systemFontOfSize:16];
    if (@available(iOS 13.0, *)) {
        titleLabel.textColor = [UIColor labelColor];
    } else {
        titleLabel.textColor = [UIColor blackColor];
    }
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:titleLabel];
    
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.text = item.itemDescription;
    descLabel.font = [UIFont systemFontOfSize:14];
    if (@available(iOS 13.0, *)) {
        descLabel.textColor = [UIColor secondaryLabelColor];
    } else {
        descLabel.textColor = [UIColor grayColor];
    }
    descLabel.numberOfLines = 0;
    descLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:descLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [containerView.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:8],
        [containerView.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:15],
        [containerView.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-15],
        [containerView.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-8],
        
        [titleLabel.topAnchor constraintEqualToAnchor:containerView.topAnchor constant:15],
        [titleLabel.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:15],
        [titleLabel.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor constant:-15],
        
        [descLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:5],
        [descLabel.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:15],
        [descLabel.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor constant:-15],
        [descLabel.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor constant:-15]
    ]];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

// 配置可展开项目单元格布局
- (void)configureExpandableItemCell:(UITableViewCell *)cell withItem:(AppMenuItem *)item {
    // 创建容器视图
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    UIView *containerView = [[UIView alloc] init];
    if (@available(iOS 13.0, *)) {
        containerView.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        containerView.backgroundColor = [UIColor whiteColor];
    }
    containerView.layer.cornerRadius = 8;
    containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    containerView.layer.shadowOffset = CGSizeMake(0, 1);
    containerView.layer.shadowOpacity = 0.1;
    containerView.layer.shadowRadius = 2;
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:containerView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = item.title;
    titleLabel.font = [UIFont systemFontOfSize:16];
    if (@available(iOS 13.0, *)) {
        titleLabel.textColor = [UIColor labelColor];
    } else {
        titleLabel.textColor = [UIColor blackColor];
    }
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:titleLabel];
    
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.text = item.itemDescription;
    descLabel.font = [UIFont systemFontOfSize:14];
    if (@available(iOS 13.0, *)) {
        descLabel.textColor = [UIColor secondaryLabelColor];
    } else {
        descLabel.textColor = [UIColor grayColor];
    }
    descLabel.numberOfLines = 0;
    descLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:descLabel];
    
    // 添加箭头指示器
    UIImageView *arrowImageView = [[UIImageView alloc] init];
    arrowImageView.tag = 1001;
    arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
    arrowImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:arrowImageView];
    
    // 设置箭头图片（使用系统图标）
    if (@available(iOS 13.0, *)) {
        arrowImageView.image = [UIImage systemImageNamed:@"chevron.right"];
    } else {
        // iOS 13以下版本使用箭头图片
        arrowImageView.image = [UIImage imageNamed:@"arrow_right"];
    }
    
    // 根据展开状态旋转箭头
    CGAffineTransform transform = item.expanded ? CGAffineTransformMakeRotation(M_PI_2) : CGAffineTransformIdentity;
    arrowImageView.transform = transform;
    
    [NSLayoutConstraint activateConstraints:@[
        [containerView.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:8],
        [containerView.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:15],
        [containerView.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-15],
        [containerView.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-8],
        
        [titleLabel.topAnchor constraintEqualToAnchor:containerView.topAnchor constant:15],
        [titleLabel.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:15],
        [titleLabel.trailingAnchor constraintEqualToAnchor:arrowImageView.leadingAnchor constant:-10],
        
        [descLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:5],
        [descLabel.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:15],
        [descLabel.trailingAnchor constraintEqualToAnchor:arrowImageView.leadingAnchor constant:-10],
        [descLabel.bottomAnchor constraintEqualToAnchor:containerView.bottomAnchor constant:-15],
        
        [arrowImageView.centerYAnchor constraintEqualToAnchor:containerView.centerYAnchor],
        [arrowImageView.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor constant:-15],
        [arrowImageView.widthAnchor constraintEqualToConstant:16],
        [arrowImageView.heightAnchor constraintEqualToConstant:16]
    ]];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
