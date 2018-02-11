//
//  YYLaunchPlayerController.h
//  YYLaunchPlayerController
//
//  Created by Arvin on 2018/2/11.
//  Copyright © 2018年 Arvin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^completeBlock)(void);

@interface YYLaunchPlayerController : UIViewController

/**
 @param URL 视频链接或者是本地视频文件
 @param block 按钮点击事件回调
 */
+ (instancetype)playerControllerWithURL:(NSString *)URL complete:(completeBlock)block;

/**
 * 是否隐藏底部按钮, 如果设置, 视频播放完成后则立即进入 block 回调, 默认 NO.
 */
@property (nonatomic, assign, getter=isHiddenFinishButton) BOOL hiddenFinishButton;

/**
 * 是否显示'跳过'按钮, 默认 NO, 不显示.
 */
@property (nonatomic, assign, getter=isShowSkipButton) BOOL showSkipButton;

/**
 * 底部按钮, 可以自定义属性
 */
@property (nonatomic, weak, readonly) UIButton *finishButton;

/**
 * 右上角跳过按钮, 可以自定义属性
 */
@property (nonatomic, weak, readonly) UIButton *skipButton;

@end

NS_ASSUME_NONNULL_END
