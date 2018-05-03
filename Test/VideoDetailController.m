//
//  VideoDetailController.m
//  Test
//
//  Created by 刘少鹏 on 2018/4/20.
//  Copyright © 2018年 刘少鹏. All rights reserved.
//

#import "VideoDetailController.h"
#import <Masonry.h>

#import <AVFoundation/AVFoundation.h>
#define kHeight    [UIScreen mainScreen].bounds.size.height
#define kWidth     [UIScreen mainScreen].bounds.size.width

@interface VideoDetailController ()

@property (nonatomic, strong) UIView *playerView;

//播放器
@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, strong) UIView *otherV;

//总时长
@property (nonatomic, assign) float totalTime;

//当前时长
@property (nonatomic, assign) float currentTime;

@property (nonatomic, strong) UIButton *fullScreenBtn;

@property (nonatomic, assign) BOOL  fullScreen;

@end

@implementation VideoDetailController

#pragma mark - 视图加载完成
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createAllView];
    
    self.fullScreen = NO;
    
}
#pragma mark - 创建播放器
- (void)createAllView {
    
    self.playerView = [[UIView alloc] init];
    self.playerView.backgroundColor = [UIColor blackColor];
    self.playerView.frame = CGRectMake(0, 0, kWidth, 200);
    [self.view addSubview:self.playerView];
    
    self.player = [[AVPlayer alloc] init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"01" ofType:@"mp4"];
    NSLog(@"filePath = %@",filePath);
    self.playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:filePath]];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.playerLayer.frame = self.playerView.bounds;
    [self.playerView.layer insertSublayer:self.playerLayer atIndex:0];
    [self.view.layer addSublayer:self.playerView.layer];
    //开始播放
    [self.player play];
    
    self.fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.fullScreenBtn.frame = CGRectMake(kWidth - 50, 170, 50, 30);
    self.fullScreenBtn.backgroundColor = [UIColor yellowColor];
    [self.fullScreenBtn setTitle:@"全屏" forState:UIControlStateNormal];
    [self.fullScreenBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    //半屏
    self.fullScreen = NO;
    [self.fullScreenBtn addTarget:self action:@selector(fullScreenBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.playerView addSubview:self.fullScreenBtn];
    
    
    self.otherV = [[UIView alloc] initWithFrame:CGRectMake(0, 200, kWidth, kHeight - 200)];
    self.otherV.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.otherV];
    
    //开启和监听设备旋转的通知
    if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleDeviceOrientationChange:)
                                                name:UIDeviceOrientationDidChangeNotification object:nil];
    
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    AVPlayerItem *item = object;
    if ([keyPath isEqualToString:@"status"]) {
        
        if (item.status == AVPlayerItemStatusFailed) {
            NSLog(@"播放失败");
        } else if (item.status == AVPlayerItemStatusUnknown) {
            NSLog(@"出现未知错误");
        } else {
            
            self.totalTime = CMTimeGetSeconds(self.playerItem.duration);
            NSLog(@"self.totalTime = %f",self.totalTime);
            
            //当前时长
            __block typeof(self) weakSelf = self;
            [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                
                weakSelf.currentTime = CMTimeGetSeconds(time);
//                NSLog(@"weakSelf.currentTime = %f",weakSelf.currentTime);
                
            }];
            
        }
    }
    
}
//设备方向改变的处理
- (void)handleDeviceOrientationChange:(NSNotification *)notification{
    //获取设备方向
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationFaceUp:
            NSLog(@"屏幕朝上平躺");
            break;
        case UIDeviceOrientationFaceDown:
            NSLog(@"屏幕朝下平躺");
            break;
        case UIDeviceOrientationUnknown:
            NSLog(@"未知方向");
            break;
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"屏幕向左横置");
            [self UIDeviceOrientationLandscapeLeft];

            break;
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"屏幕向右橫置");
            [self UIDeviceOrientationLandscapeRight];
            break;
        case UIDeviceOrientationPortrait:
            NSLog(@"屏幕直立");
            [self UIDeviceOrientationPortrait];
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"屏幕直立，上下顛倒");
            break;
        default:
            NSLog(@"无法辨识");
            break;
    }
}
#pragma mark - 屏幕向左横置
- (void)UIDeviceOrientationLandscapeLeft {
    [self configureLandscapeView];
}
#pragma mark - 屏幕向右橫置
- (void)UIDeviceOrientationLandscapeRight {
    [self configureLandscapeView];
}
- (void)configureLandscapeView {
    
    [self.fullScreenBtn setTitle:@"半屏" forState:UIControlStateNormal];
    
    self.playerView.frame = CGRectMake(0, 0, kWidth, kHeight);
    self.playerLayer.frame = self.playerView.bounds;
    [self.playerView.layer insertSublayer:self.playerLayer atIndex:0];
    [self.view.layer addSublayer:self.playerView.layer];
    
    self.fullScreenBtn.frame = CGRectMake(kWidth- 50, kHeight - 30, 50, 30);
    [self.fullScreenBtn bringSubviewToFront:self.fullScreenBtn];
    
    self.fullScreen = YES;
    
}

#pragma mark - 屏幕直立
- (void)UIDeviceOrientationPortrait {
    
    [self.fullScreenBtn setTitle:@"全屏 " forState:UIControlStateNormal];
    
    self.playerView.frame = CGRectMake(0, 0, kWidth, 200);
    self.playerLayer.frame = self.playerView.bounds;
    [self.playerView.layer insertSublayer:self.playerLayer atIndex:0];
    [self.view.layer addSublayer:self.playerView.layer];
    
    self.fullScreenBtn.frame = CGRectMake(kWidth - 50, 170, 50, 30);
    [self.fullScreenBtn bringSubviewToFront:self.fullScreenBtn];
    
    self.fullScreen = NO;
}
//最后在dealloc中移除通知 和结束设备旋转的通知
-(void)dealloc {
    [self.playerItem removeObserver:self forKeyPath:@"status" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}
#pragma mark - 全屏按钮点击事件
- (void)fullScreenBtnAction:(UIButton *)sender {
    
    if (self.fullScreen) {
        //进入半屏
        [self manualToPortrait];
        [sender setTitle:@"全屏" forState:UIControlStateNormal];
        
        self.fullScreen = NO;
    } else if (self.fullScreen == NO) {
        //进入全屏
        [self manualToFullScreen];
        [sender setTitle:@"半屏" forState:UIControlStateNormal];

        self.fullScreen = YES;
    }
    
}
#pragma mark - 手动进入全屏
- (void)manualToFullScreen {
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (deviceOrientation == UIDeviceOrientationUnknown || deviceOrientation == UIDeviceOrientationPortrait) {
        //未知方向或者竖屏方向
        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    } else {
        //屏幕向左横置或者向右横置
        NSNumber *orientationTarget = [NSNumber numberWithInt:deviceOrientation];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    }
}
#pragma mark - 手动进入半屏
- (void)manualToPortrait {
    
    NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    
    [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
    
    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
