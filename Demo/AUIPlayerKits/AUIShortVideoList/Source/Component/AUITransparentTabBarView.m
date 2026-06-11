//
//  AUITransparentTabBarView.m
//  AUIPlayer
//
//  Created by keria on 2024/11/8.
//

#import "AUITransparentTabBarView.h"

@interface AUITransparentTabBarView ()

// 代理协议
@property (nonatomic, weak) id<AUITransparentTabBarViewDelegate> delegate;

// 选项卡标题数组
@property (nonatomic, strong, readonly) NSArray<NSString *> *titles;

// 按钮数组
@property (nonatomic, strong) NSMutableArray<UIButton *> *buttons;

@end


@implementation AUITransparentTabBarView

#pragma mark - LifeCycle

// 初始化视图，使用选项卡标题数组和代理
- (instancetype)initWithTitles:(NSArray<NSString *> *)titles delegate:(id<AUITransparentTabBarViewDelegate>)delegate {
    self = [super init];
    
    if (self) {
        // 设置顶部导航栏为透明
        self.backgroundColor = [UIColor clearColor];
        
        // 使用不可变的方式存储标题数组
        _titles = [titles copy];
        
        // 保存代理对象，代理用于响应选项卡切换事件。
        _delegate = delegate;
        
        // 初始化用于存放按钮的数组。
        _buttons = [NSMutableArray array];
        [self setupButtons];
    }
    
    return self;
}

#pragma mark - View Layout

// 视图布局设置
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat topInset = 0;
    // 检查iOS版本以确保兼容性
    if (@available(iOS 11.0, *)) {
        // 使用safeAreaInsets来获得状态栏和刘海的高度
        topInset = self.safeAreaInsets.top;
    } else {
        // 使用statusBarFrame来获得状态栏高度，适用于iOS 11以下的版本
        CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
        topInset = statusBarFrame.size.height;
    }
    
    // 根据顶部预留高度调整布局
    CGFloat buttonWidth = self.frame.size.width / self.buttons.count;
    CGFloat buttonHeight = self.frame.size.height - topInset;
    
    // 设置每个按钮的尺寸和位置
    [self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        button.frame = CGRectMake(idx * buttonWidth, topInset, buttonWidth, buttonHeight);
    }];
}


#pragma mark - Setup Methods

// 初始化并设置选项卡按钮
- (void)setupButtons {
    [self.titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [self.buttons addObject:button];
    }];
}

#pragma mark - Button Actions

// 处理按钮点击事件
- (void)buttonTapped:(UIButton *)sender {
    NSInteger index = [self.buttons indexOfObject:sender];
    if (index != NSNotFound) {
        [self setSelectedIndex:index];
        if (self.delegate && [self.delegate respondsToSelector:@selector(selectedIndexUpdated:didSelectIndex:)]) {
            [self.delegate selectedIndexUpdated:self didSelectIndex:index];
        }
    }
}

#pragma mark - API

// 设置选中选项卡的索引
- (void)setSelectedIndex:(NSInteger)index {
    [self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        button.selected = (idx == index);
        button.titleLabel.font = button.selected ? [UIFont boldSystemFontOfSize:16] : [UIFont systemFontOfSize:14];
    }];
}

@end
