//
//  BroadcastSetupViewController.m
//  broadcastSetupUI
//
//  Created by song on 2021/7/6.
//  Copyright © 2021 难说再见了. All rights reserved.
//

#import "BroadcastSetupViewController.h"

@implementation BroadcastSetupViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    NSLog(@"BroadcastSetupViewController");
    self.view.backgroundColor = [UIColor redColor];
    UIButton *btn1 =  [UIButton buttonWithType:UIButtonTypeSystem];
    btn1.frame = CGRectMake(110, 100, 200, 33);
    btn1.backgroundColor = [UIColor redColor];
    [btn1 setTitle:@"点我开始直播" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(systemBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    UIButton *btn2 =  [UIButton buttonWithType:UIButtonTypeSystem];
    btn2.frame = CGRectMake(110, 200, 200, 33);
    btn2.backgroundColor = [UIColor redColor];
    [btn2 setTitle:@"取消直播" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];

}
- (void)systemBtnClick {
    NSLog(@"开始直播");
    [self userDidFinishSetup];
}
- (void)stop {
    [self userDidCancelSetup];
}
// Call this method when the user has finished interacting with the view controller and a broadcast stream can start
- (void)userDidFinishSetup {
    NSLog(@"userDidFinishSetup");
    // URL of the resource where broadcast can be viewed that will be returned to the application
    NSURL *broadcastURL = [NSURL URLWithString:@"http://apple.com/broadcast/com.ask.answer.live.boradcastr"];
    
    // Dictionary with setup information that will be provided to broadcast extension when broadcast is started
    NSDictionary *setupInfo = @{ @"broadcastName" : @"App live" };
    
    // Tell ReplayKit that the extension is finished setting up and can begin broadcasting
    [self.extensionContext completeRequestWithBroadcastURL:broadcastURL setupInfo:setupInfo];
}

- (void)userDidCancelSetup {
    // Tell ReplayKit that the extension was cancelled by the user
    NSLog(@"userDidCancelSetup");
    [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"YourAppDomain" code:-1 userInfo:nil]];
}

@end
