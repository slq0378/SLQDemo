//
//  ViewController
//
//
//  Created by song on 2021/5/13.
//  Copyright © 2021 song. All rights reserved.

#import "MainViewController.h"
#import <ReplayKit/ReplayKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SystemScreenRecordController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
@interface NSDate (Timestamp)
+ (NSString *)timestamp;
@end
 
@implementation NSDate (Timestamp)
+ (NSString *)timestamp {
    long long timeinterval = (long long)([NSDate timeIntervalSinceReferenceDate] * 1000);
    return [NSString stringWithFormat:@"%lld", timeinterval];
}
@end

@interface MainViewController ()<RPScreenRecorderDelegate,RPPreviewViewControllerDelegate>
@property (nonatomic,strong) AVAssetWriter *assetWriter;
@property (nonatomic,strong) AVAssetWriterInput *videoInput;
@property (nonatomic,strong) AVAssetWriterInput *audioInput;
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
    [btn1 addTarget:self action:@selector(systemBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    
    
    UIButton *btn2 =  [UIButton buttonWithType:UIButtonTypeSystem];
    btn2.frame = CGRectMake(110, 300, 100, 33);
    btn2.backgroundColor = [UIColor redColor];
    [btn2 setTitle:@"预览视频" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(previewVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
}
- (void)previewVideo {
    
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
- (void)systemBtnClick{
    SystemScreenRecordController *vc = [[SystemScreenRecordController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
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
    [self initData];
    
    if ([RPScreenRecorder sharedRecorder].recording) {
        NSLog(@"录制中...");
    }else{

        NSLog(@"1---[RPScreenRecorder sharedRecorder].microphoneEnabled:%d",[RPScreenRecorder sharedRecorder].microphoneEnabled);
        if(![RPScreenRecorder sharedRecorder].microphoneEnabled){
            [[RPScreenRecorder sharedRecorder] setMicrophoneEnabled:YES];
        }
        NSLog(@"2---[RPScreenRecorder sharedRecorder].microphoneEnabled:%d",[RPScreenRecorder sharedRecorder].microphoneEnabled);
        [RPScreenRecorder sharedRecorder].delegate = self;
        if (@available(iOS 11.0, *)) {
            [[RPScreenRecorder sharedRecorder] startCaptureWithHandler:^(CMSampleBufferRef  _Nonnull sampleBuffer, RPSampleBufferType bufferType, NSError * _Nullable error) {
                NSLog(@"拿到流,可以直播推流");
                switch (bufferType) {
                    case RPSampleBufferTypeAudioApp:
                        NSLog(@"内部音频流");
                        break;
                    case RPSampleBufferTypeVideo:
                        NSLog(@"内部视频流");
                        AVAssetWriterStatus status = self.assetWriter.status;
                       
                        if (status == AVAssetWriterStatusUnknown) {
                            [self.assetWriter startWriting];
                            CMTime time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                            [self.assetWriter startSessionAtSourceTime:time];
                            
                        }
                        if (status == AVAssetWriterStatusWriting ) {
                            if (self.videoInput.isReadyForMoreMediaData) {
                                BOOL success = [self.videoInput appendSampleBuffer:sampleBuffer];
                                if (!success) {
                                    [self stopRecording];
                                }
                            }
                        }
                        if (status == AVAssetWriterStatusFailed || status == AVAssetWriterStatusCompleted || status == AVAssetWriterStatusCancelled) {
                            return;
                        }
                        break;
                    case RPSampleBufferTypeAudioMic:
                        NSLog(@"麦克风音频");
                        if (self.audioInput.isReadyForMoreMediaData) {
                            BOOL success = [self.audioInput appendSampleBuffer:sampleBuffer];
                            if (!success) {
                                [self stopRecording];
                            }
                        }
                        break;
                    default:
                        break;
                }
            } completionHandler:^(NSError * _Nullable error) {
                NSLog(@"startCaptureWithHandler completionHandler");
                if (error) {

                }else{

                }
            }];
        }
        else
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
- (void)ddd {
    
// 获取沙盒根目录路径
    NSString *homeDir = NSHomeDirectory();
    
    // 获取Documents目录路径
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject];
    
    //获取Library的目录路径
    NSString *libDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES) lastObject];
    
    // 获取cache目录路径
    NSString *cachesDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) firstObject];

    // 获取tmp目录路径
    NSString *tmpDir =NSTemporaryDirectory();
    
    // 获取应用程序程序包中资源文件路径的方法：
    NSString *bundle = [[NSBundle mainBundle] bundlePath];

    NSLog(@"homeDir=%@ \n docDir=%@ \n libDir=%@ \n cachesDir=%@ \n tmpDir=%@ \n bundle=%@", homeDir,docDir, libDir, cachesDir, tmpDir, bundle);
    
}
// #import <Photos/Photos.h>
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
- (void)stop{
    if ([RPScreenRecorder sharedRecorder].recording) {
        
        if (@available(iOS 14.0, *)) {
            __weak typeof(self) weakSelf = self;
            NSString *cachesDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) firstObject];
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/test.mp4",cachesDir]];
            [[RPScreenRecorder sharedRecorder] stopRecordingWithOutputURL:url  completionHandler:^(NSError * _Nullable error) {
                NSLog(@"stopRecordingWithOutputURL:%@",url);
                [weakSelf saveVideoWithUrl:url];
               
            }];
        } else {
            [[RPScreenRecorder sharedRecorder] stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
                NSLog(@"stopRecordingWithHandler");
                if (!error) {
                    previewViewController.previewControllerDelegate = self;
                    [self presentViewController:previewViewController animated:YES completion:nil];
                }
            }];
            [self stopRecording];
        }
  
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

#pragma mark - Video
- (NSString *)getDocumentsPath
{
    //获取Documents路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSLog(@"path:%@", path);
    return path;
}
- (NSString *)getVideoPath {
    
    static NSString *replaysPath;
    if (!replaysPath) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentRootPath = [NSURL URLWithString:[self getDocumentsPath]];
        replaysPath = [documentRootPath.path stringByAppendingPathComponent:@"Replays"];
        if (![fileManager fileExistsAtPath:replaysPath]) {
            NSError *error_createPath = nil;
            BOOL success_createPath = [fileManager createDirectoryAtPath:replaysPath withIntermediateDirectories:true attributes:@{} error:&error_createPath];
            if (success_createPath && !error_createPath) {
                NSLog(@"%@路径创建成功!", replaysPath);
            } else {
                NSLog(@"%@路径创建失败:%@", replaysPath, error_createPath);
            }
        }else{
            NSLog(@"%@路径已存在!", replaysPath);
        }
    }
    return replaysPath;
}
- (NSURL *)getFilePathUrl {
    NSString *time = [NSDate timestamp];
    NSString *fileName = [time stringByAppendingPathExtension:@"mp4"];
    NSString *fullPath = [[self getVideoPath] stringByAppendingPathComponent:fileName];
    return [NSURL fileURLWithPath:fullPath];
}

- (NSArray <NSURL *> *)fetechAllResource {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *documentPath = [self getVideoPath];
    NSURL *documentURL = [NSURL fileURLWithPath:documentPath];
    NSError *error = nil;
    NSArray<NSURL *> *allResource  =  [fileManager contentsOfDirectoryAtURL:documentURL includingPropertiesForKeys:@[] options:(NSDirectoryEnumerationSkipsSubdirectoryDescendants) error:&error];
    return allResource;
    
}
- (void)initData {
    if ([self.assetWriter canAddInput:self.videoInput]) {
        [self.assetWriter addInput:self.videoInput];
    }
    
//    else{
//        NSLog(@"添加input失败");
//    }
}
- (AVAssetWriter *)assetWriter{
    if (!_assetWriter) {
        NSError *error = nil;
        _assetWriter = [[AVAssetWriter alloc] initWithURL:[self getFilePathUrl] fileType:(AVFileTypeMPEG4) error:&error];
        NSAssert(!error, @"_assetWriter 初始化失败");
    }
    return _assetWriter;
}
-(AVAssetWriterInput *)audioInput{
    if (!_audioInput) {
        // 音频参数
        NSDictionary *audioCompressionSettings = @{
            AVEncoderBitRatePerChannelKey:@(28000),
            AVFormatIDKey:@(kAudioFormatMPEG4AAC),
            AVNumberOfChannelsKey:@(1),
            AVSampleRateKey:@(22050)
        };
        _audioInput  = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioCompressionSettings];
    }
    return _audioInput;
}

-(AVAssetWriterInput *)videoInput{
    if (!_videoInput) {
        
        CGSize size = [UIScreen mainScreen].bounds.size;
        // 视频大小
        NSInteger numPixels = size.width * size.height;
        // 像素比
        CGFloat bitsPerPixel = 7.5;
        NSInteger bitsPerSecond = numPixels * bitsPerPixel;
        // 码率和帧率设置
        NSDictionary *videoCompressionSettings = @{
            AVVideoAverageBitRateKey:@(bitsPerSecond),//码率
            AVVideoExpectedSourceFrameRateKey:@(25),// 帧率
            AVVideoMaxKeyFrameIntervalKey:@(15),// 关键帧最大间隔
            AVVideoProfileLevelKey:AVVideoProfileLevelH264BaselineAutoLevel,
            AVVideoPixelAspectRatioKey:@{
                    AVVideoPixelAspectRatioVerticalSpacingKey:@(1),
                    AVVideoPixelAspectRatioHorizontalSpacingKey:@(1)
            }
        };
        CGFloat scale = [UIScreen mainScreen].scale;
        
        // 视频参数
        NSDictionary *videoOutputSettings = @{
            AVVideoCodecKey:AVVideoCodecTypeH264,
            AVVideoScalingModeKey:AVVideoScalingModeResizeAspectFill,
            AVVideoWidthKey:@(size.width*scale),
            AVVideoHeightKey:@(size.height*scale),
            AVVideoCompressionPropertiesKey:videoCompressionSettings
        };
        
        _videoInput  = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoOutputSettings];
        _videoInput.expectsMediaDataInRealTime = true;
    }
    return _videoInput;
}
- (void)stopRecording {
    if(self.assetWriter.status != AVAssetWriterStatusCompleted){
        [self.assetWriter finishWritingWithCompletionHandler:^{
            NSLog(@"结束写入数据");
            self.assetWriter = nil;
            self.videoInput = nil;
            self.audioInput  = nil;
        }];
 
    }
}

@end
