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

@interface AppHomeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<AppMenuItem *> *menuItems;

@end

@implementation AppHomeViewController

#pragma mark - View Layout

// 视图加载完毕后的初始化设置
- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"API Example";
    self.view.backgroundColor = [UIColor whiteColor];

    [self setupTableView];
    [self loadMenuData];
}

// 设置表格视图的基本配置
- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self.view addSubview:self.tableView];
}

#pragma mark - Data Source

// 从配置中加载菜单数据
- (void)loadMenuData {
    self.menuItems = [AppMenuConfig getMenuItems];
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
    if (item.type == AppMenuItemTypeItem && item.schema) {
        [AppSchemaRouter navigateFromViewController:self withSchema:item.schema];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AppMenuItem *item = self.menuItems[indexPath.row];
    return item.type == AppMenuItemTypeHeader ? 50 : 70;
}

#pragma mark - Cell Configuration

// 配置头部单元格布局
- (void)configureHeaderCell:(UITableViewCell *)cell withItem:(AppMenuItem *)item {
    cell.textLabel.text = item.title;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

// 配置普通项目单元格布局
- (void)configureItemCell:(UITableViewCell *)cell withItem:(AppMenuItem *)item {
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = item.itemDescription;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
}

@end
