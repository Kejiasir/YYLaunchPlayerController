//
//  YYLaunchPlayerController.m
//  YYLaunchPlayerController
//
//  Created by Arvin on 2018/2/11.
//  Copyright © 2018年 Arvin. All rights reserved.
//

#import "YYLaunchPlayerController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YYLaunchPlayerController ()

@property (nonatomic, strong) MPMoviePlayerController *mvPlayer;
@property (nonatomic, weak) AVPlayerViewController *avPlayer;
@property (nonatomic, weak) AVPlayerItem *playerItem;
@property (nonatomic, weak) AVPlayer *player;
@property (nonatomic, copy) void (^complete)(void);
@property (nonatomic, weak) UIButton *finishButton;
@property (nonatomic, weak) UIButton *skipButton;

@end

NS_ASSUME_NONNULL_END

@implementation YYLaunchPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

+ (instancetype)playerControllerWithURL:(NSString *)URL complete:(completeBlock)block {
    YYLaunchPlayerController *player = [[YYLaunchPlayerController alloc] init];
    [player initialPlayerWithConfig:URL];
    player.complete = block;
    return player;
}

- (void)initialPlayerWithConfig:(NSString *)URL {
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    if (@available(iOS 9.0, *)) {
        AVPlayerItem *playerItem;
        if ([URL hasPrefix:@"https"] || [URL hasPrefix:@"http"]) {
            NSURL *url = [NSURL URLWithString:URL];
            playerItem = [AVPlayerItem playerItemWithURL:url];
        } else {
            NSURL *url = [NSURL fileURLWithPath:URL];
            AVAsset *asset = [AVAsset assetWithURL:url];
            playerItem = [AVPlayerItem playerItemWithAsset:asset];
        }
        AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
        [playerItem addObserver:self forKeyPath:@"status"
                        options:NSKeyValueObservingOptionNew context:nil];
        [center addObserver:self selector:@selector(playerFinish:)
                       name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        
        AVPlayerViewController *avPlayer = [[AVPlayerViewController alloc] init];
        avPlayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        avPlayer.view.frame = self.view.bounds;
        avPlayer.showsPlaybackControls = NO;
        avPlayer.player = player;
        [self.view addSubview:avPlayer.view];
        self.playerItem = playerItem;
        self.player = player;
        
    } else {
        
        self.mvPlayer = [[MPMoviePlayerController alloc] init];
        if ([URL hasPrefix:@"https"] || [URL hasPrefix:@"http"]) {
            self.mvPlayer.contentURL = [NSURL URLWithString:URL];
        } else {
            self.mvPlayer.contentURL = [NSURL fileURLWithPath:URL];
        }
        self.mvPlayer.scalingMode = MPMovieScalingModeAspectFill;
        self.mvPlayer.movieSourceType = MPMovieSourceTypeFile;
        self.mvPlayer.controlStyle = MPMovieControlStyleNone;
        self.mvPlayer.repeatMode = MPMovieRepeatModeNone;
        self.mvPlayer.view.frame = self.view.bounds;
        [self.view addSubview:self.mvPlayer.view];
        [self.mvPlayer prepareToPlay];
        
        [center addObserver:self selector:@selector(playerPrepare:)
                       name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
        [center addObserver:self selector:@selector(playerFinish:)
                       name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    }
    
    [self.view addSubview:({
        
        CGFloat width = size.width * 0.45, height = 44;
        CGFloat x = (size.width * 0.5) - (width * 0.5);
        CGFloat y = size.height * 0.85;
        
        UIButton *finishButton = [[UIButton alloc] init];
        [finishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [finishButton setTitle:@"马上体验" forState:UIControlStateNormal];
        [finishButton.titleLabel setFont:[UIFont systemFontOfSize:20]];
        [finishButton setFrame:CGRectMake(x, y, width, height)];
        
        [finishButton.layer setBorderColor:[UIColor whiteColor].CGColor];
        [finishButton.layer setBorderWidth:1.0f];
        [finishButton.layer setCornerRadius:height * 0.5];
        [finishButton.layer setMasksToBounds:YES];
        [finishButton addTarget:self action:@selector(finish:)
               forControlEvents:UIControlEventTouchUpInside];
        self.finishButton = finishButton;
        finishButton;
    })];
    
    [self.view addSubview:({
        
        CGFloat width = 70, height = 30;
        CGFloat x = size.width - (width + 15);
        CGFloat y = size.height * 0.05;
        
        UIButton *skipButton = [[UIButton alloc] init];
        [skipButton setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
        [skipButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [skipButton setTitle:@"跳 过" forState:UIControlStateNormal];
        [skipButton setFrame:CGRectMake(x, y, width, height)];
        
        [skipButton.layer setCornerRadius:3.0f];
        [skipButton.layer setMasksToBounds:YES];
        [skipButton setHidden:YES];
        
        [skipButton addTarget:self action:@selector(skip:)
             forControlEvents:UIControlEventTouchUpInside];
        self.skipButton = skipButton;
        skipButton;
    })];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    AVPlayerItem *item = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if (item.status == AVPlayerStatusReadyToPlay) {
            [self.player play];
        } else if (item.status == AVPlayerStatusFailed) {
            NSLog(@"播放失败:%@", item.errorLog);
        } else {
            NSLog(@"未知错误");
        }
    }
}

#pragma mark -
- (void)playerPrepare:(NSNotification *)notify {
    MPMoviePlaybackState state = [self.mvPlayer playbackState];
    if (state == MPMoviePlaybackStateStopped ||
        state == MPMoviePlaybackStatePaused ) {
        [self.mvPlayer play];
    }
}

- (void)playerFinish:(NSNotification *)notify {
    if (!self.isHiddenFinishButton) {
        if (@available(iOS 9.0, *)) {
            [self.player seekToTime:kCMTimeZero];
            [self.player play];
        } else {
            [self.mvPlayer setInitialPlaybackTime:0];
            [self.mvPlayer play];
        }
    } else {
        [self finish:nil];
    }
}

- (void)finish:(UIButton *)button {
    !self.complete ?: self.complete();
}

- (void)skip:(UIButton *)button {
    [self finish:nil];
}

#pragma mark -
- (void)setHiddenFinishButton:(BOOL)hiddenFinishButton {
    _hiddenFinishButton = hiddenFinishButton;
    [self.finishButton setHidden:hiddenFinishButton];
}

- (void)setShowSkipButton:(BOOL)showSkipButton {
    _showSkipButton = showSkipButton;
    [self.skipButton setHidden:!showSkipButton];
}

#pragma mark -
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (@available(iOS 9.0, *)) {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
