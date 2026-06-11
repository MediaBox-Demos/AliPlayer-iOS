//
//  AUIShortVideoInteractiveView.h
//  AUIPlayer
//
//  Created by keria on 2024/11/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 定义一个无参数无返回值的 Block，用于处理按钮点击事件。
 *
 * 这个 Block 类型用于表示一个按钮的点击事件处理逻辑。当按钮被点击时，
 * 关联的 Block 将会被执行。在 Block 中定义你希望在按钮点击时执行的操作。
 */
typedef void(^ButtonActionBlock)(void);

/**
 * @class AUIShortVideoInteractiveView
 *
 * @brief 一个自定义视图类，用于在短视频应用中提供常见的交互按钮。
 *
 * @discussion AUIShortVideoInteractiveView 提供了点赞、评论和分享三个功能按钮，允许开发者轻松集成到短视频应用中。
 * 每个按钮都可以通过提供的 Block 接口定制点击事件的响应行为，提升了组件的灵活性。
 * 这种设计使得该视图可以与不同的业务逻辑集成，适应多样化的需求。
 *
 * 以下是使用的示例：
 * @code
 * AUIShortVideoInteractiveView *interactiveView = [[AUIShortVideoInteractiveView alloc] initWithFrame:someFrame];
 * [interactiveView configureWithLikeAction:^{
 *     // Handle like button click
 * } commentAction:^{
 *     // Handle comment button click
   } shareAction:^{
 *     // Handle share button click
 * }];
 * [self.view addSubview:interactiveView];
 * @endcode
 *
 * @note 确保在视图实例中配置点击事件的 Block，以确保交互功能正常运作。
 */
@interface AUIShortVideoInteractiveView : UIView

/**
 * @brief 点赞按钮的点击事件处理 Block。
 */
@property (nonatomic, copy) ButtonActionBlock likeButtonAction;

/**
 * @brief 评论按钮的点击事件处理 Block。
 */
@property (nonatomic, copy) ButtonActionBlock commentButtonAction;

/**
 * @brief 分享按钮的点击事件处理 Block。
 */
@property (nonatomic, copy) ButtonActionBlock shareButtonAction;

/**
 * @brief 配置互动视图中的按钮点击事件。
 *
 * 该方法允许调用方为点赞、评论、和分享按钮分别指定点击事件。
 * 可以通过传入相应的 block 来定义每个按钮的点击行为。
 *
 * @param likeAction    点赞按钮被点击时执行的 block。在该 block 中定义你希望在用户点击点赞按钮时进行的操作。
 * @param commentAction 评论按钮被点击时执行的 block。在该 block 中定义你希望在用户点击评论按钮时进行的操作。
 * @param shareAction   分享按钮被点击时执行的 block。在该 block 中定义你希望在用户点击分享按钮时进行的操作。
 *
 * @discussion 此方法设计用于增强组件灵活性，使调用者可以根据需要为每个按钮自定义响应。当按钮被点击时，相关联的 block 将被执行。确保在调用该方法之前准备好对应的 block，避免调用未定义的 block 导致程序崩溃。
 */
- (void)configureWithLikeAction:(ButtonActionBlock)likeAction
                  commentAction:(ButtonActionBlock)commentAction
                   shareAction:(ButtonActionBlock)shareAction;

@end

NS_ASSUME_NONNULL_END
