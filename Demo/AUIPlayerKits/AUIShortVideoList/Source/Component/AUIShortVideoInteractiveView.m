//
//  AUIShortVideoInteractiveView.m
//  AUIPlayer
//
//  Created by keria on 2024/11/19.
//

#import "AUIShortVideoInteractiveView.h"
#import "AUIShortVideoListMacro.h"
#import "AVBaseButton.h"

@interface AUIShortVideoInteractiveView ()

// 点赞按钮
@property (nonatomic, strong) AVBaseButton *likeBtn;

// 评论按钮
@property (nonatomic, strong) AVBaseButton *commentBtn;

// 分享按钮
@property (nonatomic, strong) AVBaseButton *shareBtn;

@end

@implementation AUIShortVideoInteractiveView

#pragma mark - LifeCycle

// 初始化自定义视图
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setupButtons];
    }
    
    return self;
}

#pragma mark - Setup Methods

// 初始化按钮
- (void)setupButtons {
    // 创建弱引用，以避免循环引用
    __weak typeof(self) weakSelf = self;  // 弱引用 self
    
    // 初始化点赞按钮
    self.likeBtn = [[AVBaseButton alloc] initWithType:AVBaseButtonTypeImageText titlePos:AVBaseButtonTitlePosBottom];
    self.likeBtn.image = SVCommonImage(@"ic_like");
    self.likeBtn.selectedImage = SVCommonImage(@"ic_like_selected");
    self.likeBtn.title = @"0";
    self.likeBtn.font = AVGetRegularFont(11);
    self.likeBtn.action = ^(AVBaseButton * _Nonnull btn) {
        // 获取强引用以避免过早释放 self
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.likeButtonAction) {
            strongSelf.likeButtonAction();
        }
    };
    // 添加按钮到视图中
    [self addSubview:self.likeBtn];
    
    // 初始化评论按钮
    self.commentBtn = [[AVBaseButton alloc] initWithType:AVBaseButtonTypeImageText titlePos:AVBaseButtonTitlePosBottom];
    self.commentBtn.image = SVCommonImage(@"ic_comment");
    self.commentBtn.title = @"0";
    self.commentBtn.font = AVGetRegularFont(11);
    self.commentBtn.action = ^(AVBaseButton * _Nonnull btn) {
        // 获取强引用以避免过早释放 self
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.commentButtonAction) {
            strongSelf.commentButtonAction();
        }
    };
    // 添加按钮到视图中
    [self addSubview:self.commentBtn];
    
    // 初始化分享按钮
    self.shareBtn = [[AVBaseButton alloc] initWithType:AVBaseButtonTypeImageText titlePos:AVBaseButtonTitlePosBottom];
    self.shareBtn.image = SVCommonImage(@"ic_share");
    self.shareBtn.title = @"0";
    self.shareBtn.font = AVGetRegularFont(11);
    self.shareBtn.action = ^(AVBaseButton * _Nonnull btn) {
        // 获取强引用以避免过早释放 self
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.shareButtonAction) {
            strongSelf.shareButtonAction();
        }
    };
    // 添加按钮到视图中
    [self addSubview:self.shareBtn];
}

#pragma mark - Block Configuration

// 配置互动视图中的按钮点击事件
- (void)configureWithLikeAction:(ButtonActionBlock)likeAction
                  commentAction:(ButtonActionBlock)commentAction
                   shareAction:(ButtonActionBlock)shareAction {
    self.likeButtonAction = likeAction;
    self.commentButtonAction = commentAction;
    self.shareButtonAction = shareAction;
}

#pragma mark - View Layout

// 布局子视图
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat buttonHeight = 48.0; // 每个按钮的高度
    CGFloat spacing = 12.0; // 按钮之间的间隔
    
    CGFloat y = 0;
    self.likeBtn.frame = CGRectMake(0, y, self.bounds.size.width, buttonHeight);
    
    y += buttonHeight + spacing;
    self.commentBtn.frame = CGRectMake(0, y, self.bounds.size.width, buttonHeight);
    
    y += buttonHeight + spacing;
    self.shareBtn.frame = CGRectMake(0, y, self.bounds.size.width, buttonHeight);
}

@end
