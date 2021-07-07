//
//  SLQVideoPlayViewController.m
//  SLQVideoLive
//
//  Created by song on 2021/6/7.
//  Copyright © 2021 难说再见了. All rights reserved.
//

#import "SLQVideoPlayViewController.h"
#import "SLQPrecompile.h"

#import <TXLiteAVSDK_Smart/TXLiteAVSDK.h>
@interface SLQVideoPlayViewController ()<V2TXLivePlayerObserver>
@property (nonatomic,strong) V2TXLivePlayer *player;
@property (nonatomic,strong) UIView *localView;
@end

@implementation SLQVideoPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *localView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT-kNavBarHeight)];
    localView.backgroundColor = [UIColor redColor];
    [self.view addSubview:localView];
    self.localView = localView;

    // 2 初始化拉流组件
    V2TXLivePlayer *player = [[V2TXLivePlayer alloc] init];
    [player setRenderView:localView];
    
    // 3 播放流
    // 没有域名，暂时无法测试
    NSString *url = @"https://142576.liveplay.myqcloud.com/live/video.flv";
    [player startPlay:url];
    [player showDebugView:YES];
    [player setObserver:self];
    self.player = player;
}


#pragma mark - V2TXLivePusherObserver
- (void)onError:(V2TXLiveCode)code message:(NSString *)msg extraInfo:(NSDictionary *)extraInfo
{
    NSLog(@"error:%@;%@",msg,extraInfo);
}
@end
