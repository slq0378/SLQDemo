//
//  SystemScreenRecordController.m
//  SLQDemo
//
//  Created by song on 2021/7/6.
//  Copyright © 2021 难说再见了. All rights reserved.
//

#import "SystemScreenRecordController.h"
#import <ReplayKit/ReplayKit.h>

@interface SystemScreenRecordController ()<RPBroadcastActivityViewControllerDelegate,RPBroadcastControllerDelegate>
@property (nonatomic,strong) RPSystemBroadcastPickerView *broadPickerView;
@end

@implementation SystemScreenRecordController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor greenColor];
    UIButton *btn1 =  [UIButton buttonWithType:UIButtonTypeSystem];
    btn1.frame = CGRectMake(110, 100, 100, 33);
    btn1.backgroundColor = [UIColor redColor];
    [btn1 setTitle:@"点我啊" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(systemBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    if (@available(iOS 12.0, *)) {
        self.broadPickerView = [[RPSystemBroadcastPickerView alloc] initWithFrame:CGRectMake(110, 400, 100, 100)];
                self.broadPickerView.preferredExtension = nil;// nil的话列出所有可录屏的App
                [self.view addSubview:self.broadPickerView];
    } else {

    }

}
- (void)systemBtnClick {
    [self setupUI];
}

- (void)setupUI {
    if (@available(iOS 11.0, *)) {
        [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithPreferredExtension:@"com.ask.answer.live.boradcastrSetupUI" handler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error) {
            if (error) {
                NSLog(@"loadBroadcastActivityViewControllerWithHandler:%@",error);
            }else{
                broadcastActivityViewController.delegate = self;
                broadcastActivityViewController.modalPresentationStyle = UIModalPresentationPopover;
                [self presentViewController:broadcastActivityViewController animated:YES completion:nil];
            }
        }];
    }
    else
        if (@available(iOS 10.0, *)) {
        [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithHandler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error) {
            if (error) {
                NSLog(@"loadBroadcastActivityViewControllerWithHandler:%@",error);
            }else{
                broadcastActivityViewController.delegate = self;
                broadcastActivityViewController.modalPresentationStyle = UIModalPresentationPopover;
                [self presentViewController:broadcastActivityViewController animated:YES completion:nil];
            }
        }];
    
    } else {
        NSLog(@"不支持录制系统屏幕");
    }
 
}
#pragma mark - broadcastActivityViewController
- (void)broadcastActivityViewController:(RPBroadcastActivityViewController *)broadcastActivityViewController didFinishWithBroadcastController:(RPBroadcastController *)broadcastController error:(NSError *)error{
    NSLog(@"broadcastActivityViewController: didFinishWithBroadcastController:");
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [broadcastActivityViewController dismissViewControllerAnimated:YES completion:nil];
    });
    
    NSLog(@"Boundle id :%@",broadcastController);
    
    if (error) {
        NSLog(@"BAC: %@ didFinishWBC: %@, err: %@",
                   broadcastActivityViewController,
                   broadcastController,
                   error);
             return;
    }
    [broadcastController startBroadcastWithHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"startBroadcastWithHandler:%@",error);
        }else{
            NSLog(@"startBroadcast success");
        }
    }];
}

- (void)broadcastController:(RPBroadcastController *)broadcastController didUpdateServiceInfo:(NSDictionary<NSString *,NSObject<NSCoding> *> *)serviceInfo{
    NSLog(@"didUpdateServiceInfo:%@",serviceInfo);
}

@end
