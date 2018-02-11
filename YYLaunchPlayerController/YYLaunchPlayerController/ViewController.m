//
//  ViewController.m
//  YYLaunchPlayerController
//
//  Created by Arvin on 2018/2/11.
//  Copyright © 2018年 Arvin. All rights reserved.
//

#import "ViewController.h"
#import "YYLaunchPlayerController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self presentViewController:({
        NSString *url = [[NSBundle mainBundle] pathForResource:@"didi" ofType:@"mp4"];
        YYLaunchPlayerController *player = [YYLaunchPlayerController playerControllerWithURL:url complete:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
//        // 自定义底部按钮的属性
//        [player.finishButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//        [player.finishButton setTitle:@"自定义标题" forState:UIControlStateNormal];
//        [player.finishButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
        // 隐藏底部的 finishButton
        [player setHiddenFinishButton:YES];
        // 显示右上角跳过按钮
        [player setShowSkipButton:YES];
        player;
    }) animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
