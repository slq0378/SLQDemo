//
//  SLQVideoPushViewController.m
//  SLQVideoLive
//
//  Created by song on 2021/6/7.
//  Copyright © 2021 难说再见了. All rights reserved.
//

#import "SLQVideoPushViewController.h"
#import "SLQPrecompile.h"

#import <TXLiteAVSDK_Smart/TXLiteAVSDK.h>
@interface SLQVideoPushViewController ()<V2TXLivePusherObserver>
@property (nonatomic,strong) V2TXLivePusher *pusher;
@property (nonatomic,strong) UIView *localView;
@property (nonatomic, assign) BOOL isLandscape;
@end

@implementation SLQVideoPushViewController

-(void)dealloc{

    [self.pusher stopCamera];
    [self.pusher stopPush];
    
    NSLog(@"%s",__FUNCTION__);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc ] initWithTitle:@"直播" style:UIBarButtonItemStylePlain target:self action:@selector(startPush)];
    self.navigationItem.rightBarButtonItem = leftBar;
    
    // Do any additional setup after loading the view.
    // 2  初始化摄像头组件
    V2TXLivePusher *pusher = [[V2TXLivePusher alloc] initWithLiveMode:V2TXLiveMode_RTMP];
    UIView *localView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT-kNavBarHeight)];
    localView.backgroundColor = [UIColor redColor];
    [self.view addSubview:localView];
    self.localView = localView;
    [pusher setRenderView:localView];

    self.pusher = pusher;
    
    // 3 开启视频预览
    [pusher startCamera:YES];
    // 3 直接开启纯音频推流
//    [pusher startMicrophone];
//    NSString *pushUrl = @"rtmp://142576.livepush.myqcloud.com/iOSLiveTest/video?txSecret=dcf2296fe7ab4523e9c5a895f290616d&txTime=60C2D765";
//    [self.pusher startPush:pushUrl];
    [self.pusher setObserver:self];
}

-(void)startPush{

    // 4 开启视频推流
    NSString *pushUrl = @"rtmp://142576.livepush.myqcloud.com/iOSLiveTest/video?txSecret=dcf2296fe7ab4523e9c5a895f290616d&txTime=60C2D765";
    [self.pusher startPush:pushUrl];
    [self.pusher startCamera:YES];
    
    TXBeautyManager *manger = self.pusher.getBeautyManager;
    [manger setBeautyStyle:TXBeautyStyleNature];
    [manger setBeautyLevel:5]; //美颜
    [manger setWhitenessLevel:2]; //美白
    [manger setRuddyLevel:2];//红润
    
//   TXDeviceManager *device =  self.pusher.getDeviceManager;
    
    
}
// 监听设备旋转
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            //home健在下 1
            self.isLandscape = NO;
            self.localView.frame = CGRectMake(0, kNavBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT-kNavBarHeight);
            [self.pusher setRenderView:self.localView];
            [self.pusher setVideoQuality:V2TXLiveVideoResolution960x540 resolutionMode:V2TXLiveVideoResolutionModePortrait];
                     [self.pusher setRenderRotation:V2TXLiveRotation0];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            //home健在上 不变
            self.isLandscape = NO;
            self.localView.frame = CGRectMake(0, kNavBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT-kNavBarHeight);
            [self.pusher setRenderView:self.localView];
//            [self.pusher setVideoQuality:V2TXLiveVideoResolution960x540 resolutionMode:V2TXLiveVideoResolutionModePortrait];
            break;
        case UIInterfaceOrientationLandscapeLeft:
            //home健在左 3
            self.isLandscape = YES;
            
            self.localView.frame = CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT-44);
            [self.pusher setRenderView:self.localView];
            [self.pusher setVideoQuality:V2TXLiveVideoResolution960x540 resolutionMode:V2TXLiveVideoResolutionModeLandscape];
            [self.pusher setRenderRotation:V2TXLiveRotation90];
            break;
        case UIInterfaceOrientationLandscapeRight:
            //home健在右 4
            self.isLandscape = YES;
            self.localView.frame = CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT-44);
            [self.pusher setRenderView:self.localView];
            [self.pusher setVideoQuality:V2TXLiveVideoResolution960x540 resolutionMode:V2TXLiveVideoResolutionModeLandscape];
            [self.pusher setRenderRotation:V2TXLiveRotation270];
            break;
        default:
            break;
    }
}


#pragma mark - V2TXLivePusherObserver
- (void)onError:(V2TXLiveCode)code message:(NSString *)msg extraInfo:(NSDictionary *)extraInfo
{
    NSLog(@"error:%@;%@",msg,extraInfo);
}

@end
