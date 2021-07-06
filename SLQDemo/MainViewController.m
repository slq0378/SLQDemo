//
//  ViewController
//
//
//  Created by song on 2021/5/13.
//  Copyright © 2021 song. All rights reserved.

#import "MainViewController.h"
#import <ReplayKit/ReplayKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MainViewController ()<RPScreenRecorderDelegate,RPPreviewViewControllerDelegate>
@end

@implementation MainViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
    [self setupScreen];
}
- (void)setupScreen{
    AVAuthorizationStatus microPhoneStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
      switch (microPhoneStatus) {
          case AVAuthorizationStatusDenied:
          case AVAuthorizationStatusRestricted:
          {
              // 被拒绝
              [self goMicroPhoneSet];
          }
              break;
          case AVAuthorizationStatusNotDetermined:
          {
              // 没弹窗
              [self requestMicroPhoneAuth];
          }
              break;
          case AVAuthorizationStatusAuthorized:
          {
              // 有授权
          }
              break;

          default:
              break;
      }
    
}
-(void) goMicroPhoneSet
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"您还没有允许麦克风权限" message:@"去设置一下吧" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    }];
    UIAlertAction * setAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [UIApplication.sharedApplication openURL:url options:nil completionHandler:^(BOOL success) {

            }];
        });
    }];

    [alert addAction:cancelAction];
    [alert addAction:setAction];

    [self presentViewController:alert animated:YES completion:nil];
}
-(void) requestMicroPhoneAuth
{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {

    }];
}
- (void)setupUI{
    self.title= @"录屏Demo";
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor greenColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:25]}];
    
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc ] initWithTitle:@"开始录屏" style:UIBarButtonItemStylePlain target:self action:@selector(start)];
    UIBarButtonItem *playBtn = [[UIBarButtonItem alloc] initWithTitle:@"结束录屏" style:UIBarButtonItemStylePlain target:self action:@selector(stop)];
    
    self.navigationItem.rightBarButtonItem = playBtn;
    
    self.navigationItem.leftBarButtonItem = leftBar;
    
    UIButton *btn1 =  [UIButton buttonWithType:UIButtonTypeSystem];
    btn1.frame = CGRectMake(110, 100, 100, 33);
    btn1.backgroundColor = [UIColor redColor];
    [btn1 setTitle:@"点我啊" forState:UIControlStateNormal];
    [self.view addSubview:btn1];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"keyPath:%@,change:%@",keyPath,change);
    if ([keyPath isEqualToString:@"available"] && [change[@"new"] integerValue] == 1) {
        [self start];
    }
}
- (void)checkout{
    
    if (@available(iOS 9.0, *)) {
        if ([RPScreenRecorder sharedRecorder].available) {
            NSLog(@"可以录屏");
            [self start];
            
        }else{
            NSLog(@"未授权");
            [[RPScreenRecorder sharedRecorder] addObserver:self forKeyPath:@"available" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
        }
    } else {
        NSLog(@"不支持录屏");
    }

}
- (void)start{
    if ([RPScreenRecorder sharedRecorder].recording) {
        NSLog(@"录制中...");
    }else{
        NSLog(@"1---[RPScreenRecorder sharedRecorder].microphoneEnabled:%d",[RPScreenRecorder sharedRecorder].microphoneEnabled);
        if(![RPScreenRecorder sharedRecorder].microphoneEnabled){
            [[RPScreenRecorder sharedRecorder] setMicrophoneEnabled:YES];
        }
        NSLog(@"2---[RPScreenRecorder sharedRecorder].microphoneEnabled:%d",[RPScreenRecorder sharedRecorder].microphoneEnabled);
        [RPScreenRecorder sharedRecorder].delegate = self;
        if (@available(iOS 10.0, *)) {
            [[RPScreenRecorder sharedRecorder] startRecordingWithHandler:^(NSError * _Nullable error) {
                NSLog(@"startRecordingWithHandler:%@",error);
            }];
        } else if(@available(iOS 9.0, *))  {
            [[RPScreenRecorder sharedRecorder] startRecordingWithMicrophoneEnabled:YES handler:^(NSError * _Nullable error) {
                NSLog(@"startRecordingWithMicrophoneEnabled:%@",error);
            }];
        }
    
    }
    
    
}
- (void)stop{
    if ([RPScreenRecorder sharedRecorder].recording) {
        [[RPScreenRecorder sharedRecorder] stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
            NSLog(@"stopRecordingWithHandler");
            if (!error) {
                previewViewController.previewControllerDelegate = self;
                [self presentViewController:previewViewController animated:YES completion:nil];
            }
        }];
    }
}

#pragma mark - RPScreenRecorderDelegate
- (void)screenRecorder:(RPScreenRecorder *)screenRecorder didStopRecordingWithPreviewViewController:(RPPreviewViewController *)previewViewController error:(NSError *)error /*API_AVAILABLE(ios(11.0)*/{
    
    if(@available(iOS 11.0,*)){
        NSLog(@"didStopRecordingWithPreviewViewController: %@",error);
    }
}

-(void)screenRecorderDidChangeAvailability:(RPScreenRecorder *)screenRecorder{
    NSLog(@"screenRecorderDidChangeAvailability:%@",screenRecorder);
}

- (void)screenRecorder:(RPScreenRecorder *)screenRecorder didStopRecordingWithError:(NSError *)error previewViewController:(RPPreviewViewController *)previewViewController{
    if(@available(iOS 9.0,*)){
        NSLog(@"didStopRecordingWithError :%@",error);
    }
}


#pragma mark - RPPreviewViewControllerDelegate
- (void)previewControllerDidFinish:(RPPreviewViewController *)previewController{
    NSLog(@"previewControllerDidFinish");
    [previewController dismissViewControllerAnimated:YES completion:nil];

    
}
- (void)previewController:(RPPreviewViewController *)previewController didFinishWithActivityTypes:(NSSet<NSString *> *)activityTypes{
    NSLog(@"didFinishWithActivityTypes:%@",activityTypes);
}
@end
