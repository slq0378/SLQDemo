//
//  ViewController
//
//
//  Created by song on 2021/5/13.
//  Copyright © 2021 song. All rights reserved.

#import "MainViewController.h"
#import "SLQPrecompile.h"
#import "SLQVideoPushViewController.h"
#import "SLQVideoPlayViewController.h"
#import <ReplayKit/ReplayKit.h>
#import <AVKit/AVKit.h>
#import <Photos/Photos.h>
static NSString *const XXCellId = @"SLQCollectionViewCellId";

API_AVAILABLE(ios(12.0))
@interface MainViewController ()
@property (nonatomic,strong) RPSystemBroadcastPickerView *broadPickerView;
@end

@implementation MainViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = ThemeColor;
    self.title= @"腾讯云直播";
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
     self.navigationController.navigationBar.barTintColor = ThemeColor;
     self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:25]}];
    
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc ] initWithTitle:@"开直播" style:UIBarButtonItemStylePlain target:self action:@selector(videoPush)];
    UIBarButtonItem *playBtn = [[UIBarButtonItem alloc] initWithTitle:@"看直播" style:UIBarButtonItemStylePlain target:self action:@selector(watchVideo)];
    
    self.navigationItem.rightBarButtonItem = playBtn;

    self.navigationItem.leftBarButtonItem = leftBar;
//    UIButton *btn1 =  [UIButton buttonWithType:UIButtonTypeSystem];
//    btn1.frame = CGRectMake(110, 100, 100, 100);
////    btn1.backgroundColor = [UIColor redColor];
////    [btn1 setTitle:@"点我录屏" forState:UIControlStateNormal];
//    [btn1 addTarget:self action:@selector(systemBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn1];
//    btn1.tag = 12;
    
    if (@available(iOS 12.0, *)) {
        self.broadPickerView = [[RPSystemBroadcastPickerView alloc] initWithFrame:CGRectMake(110, 100, 100, 100)];
        self.broadPickerView.preferredExtension = @"com.ask.answer.live.boradcastr";
        [self.view addSubview:self.broadPickerView];
    } else {
        
    }
    
    
    UIButton *btn2 =  [UIButton buttonWithType:UIButtonTypeSystem];
    btn2.frame = CGRectMake(110, 300, 100, 100);
    btn2.backgroundColor = [UIColor redColor];
    [btn2 setTitle:@"查看回放" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(watchRecord:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    btn2.tag = 12;
    
}
- (void)watchRecord:(UIButton *)sender {
    NSLog(@"watchRecord");
    NSArray<NSURL *> *allResource = [[self fetechAllResource] sortedArrayUsingComparator:^NSComparisonResult(NSURL *  _Nonnull obj1, NSURL * _Nonnull obj2) {
        //排序，每次都查看最新录制的视频
        return [obj2.path compare:obj1.path options:(NSCaseInsensitiveSearch)];
    }];
    AVPlayerViewController *playerViewController;
    playerViewController = [[AVPlayerViewController alloc] init];
    NSLog(@"url%@:",allResource);
//
//    for (NSURL *url in allResource) {
//        [self saveVideoWithUrl:url];
//    }
    playerViewController.player = [AVPlayer playerWithURL:allResource.firstObject];
    //    playerViewController.delegate = self;
    [self presentViewController:playerViewController animated:YES completion:^{
        [playerViewController.player play];
        NSLog(@"error == %@", playerViewController.player.error);
    }];
    
}
- (NSString *)getDocumentPath {
    
    static NSString *replaysPath;
    if (!replaysPath) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentRootPath = [fileManager containerURLForSecurityApplicationGroupIdentifier:@"group.com.ask.answer.live"];
        replaysPath = [documentRootPath.path stringByAppendingPathComponent:@"Replays"];
        if (![fileManager fileExistsAtPath:replaysPath]) {
            NSError *error_createPath = nil;
            BOOL success_createPath = [fileManager createDirectoryAtPath:replaysPath withIntermediateDirectories:true attributes:@{} error:&error_createPath];
            if (success_createPath && !error_createPath) {
                NSLog(@"%@路径创建成功!", replaysPath);
            } else {
                NSLog(@"%@路径创建失败:%@", replaysPath, error_createPath);
            }
        }
    }
    return replaysPath;
}
- (NSArray <NSURL *> *)fetechAllResource {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *documentPath = [self getDocumentPath];
    NSURL *documentURL = [NSURL fileURLWithPath:documentPath];
    NSError *error = nil;
    NSArray<NSURL *> *allResource  =  [fileManager contentsOfDirectoryAtURL:documentURL includingPropertiesForKeys:@[] options:(NSDirectoryEnumerationSkipsSubdirectoryDescendants) error:&error];
    return allResource;
    
}
- (void)systemBtnClick:(UIButton *)sender {
    NSLog(@"dsystemBtnClick");
//    if (sender.tag == 12)
//    {
//        for (UIView *view in self.broadPickerView.subviews)
//        {
//            if ([view isKindOfClass:[UIButton class]])
//            {
//                [(UIButton*)view sendActionsForControlEvents:UIControlEventTouchDown];
//            }
//        }
//    }
    
}

- (void)watchVideo{
    // 没有域名，暂时无法测试
    SLQVideoPlayViewController* vc = [[SLQVideoPlayViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)videoPush{
    
    SLQVideoPushViewController* vc = [[SLQVideoPushViewController alloc] init];

    [self.navigationController pushViewController:vc animated:YES];
}
//
- (void)saveVideoWithUrl:(NSURL *)url {
    PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
    [photoLibrary performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"已将视频保存至相册");
        } else {
            NSLog(@"未能保存视频到相册");
        }
    }];
}
@end
