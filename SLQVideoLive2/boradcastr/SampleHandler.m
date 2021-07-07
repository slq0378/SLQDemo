//
//  SampleHandler.m
//  broadcast
//
//  Created by song on 2021/7/6.
//  Copyright © 2021 难说再见了. All rights reserved.
//


#import "SampleHandler.h"
#import <AVFoundation/AVFoundation.h>

@interface SampleHandler()
@property (nonatomic,strong) AVAssetWriter *assetWriter;
@property (nonatomic,strong) AVAssetWriterInput *videoInput;
@property (nonatomic,strong) AVAssetWriterInput *audioInput;
@end

@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
    NSLog(@"启动广播:%@",setupInfo);
    [self initData];
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
        }else{
            NSLog(@"%@路径已存在!", replaysPath);
        }
    }
    return replaysPath;
}
- (NSURL *)getFilePathUrl {
    NSString *time = [NSDate timestamp];
    NSString *fileName = [time stringByAppendingPathExtension:@"mp4"];
    NSString *fullPath = [[self getDocumentPath] stringByAppendingPathComponent:fileName];
    return [NSURL fileURLWithPath:fullPath];
}

- (NSArray <NSURL *> *)fetechAllResource {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *documentPath = [self getDocumentPath];
    NSURL *documentURL = [NSURL fileURLWithPath:documentPath];
    NSError *error = nil;
    NSArray<NSURL *> *allResource  =  [fileManager contentsOfDirectoryAtURL:documentURL includingPropertiesForKeys:@[] options:(NSDirectoryEnumerationSkipsSubdirectoryDescendants) error:&error];
    return allResource;
    
}
- (void)initData {
    if ([self.assetWriter canAddInput:self.videoInput]) {
        [self.assetWriter addInput:self.videoInput];
    }else{
        NSLog(@"添加input失败");
    }
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


- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
    NSLog(@"暂停广播");
    [self stopRecording];
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
    NSLog(@"恢复广播");
    [self stopRecording];
}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
    NSLog(@"完成广播");
    [self stopRecording];
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
            // Handle video sample buffer
            // 得到YUV数据
            NSLog(@"视频流");
            AVAssetWriterStatus status = self.assetWriter.status;
            if (status == AVAssetWriterStatusFailed || status == AVAssetWriterStatusCompleted || status == AVAssetWriterStatusCancelled) {
                return;
            }
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
            break;
        case RPSampleBufferTypeAudioApp:
            // Handle audio sample buffer for app audio
            // 处理app音频
            NSLog(@"App音频流");
            break;
        case RPSampleBufferTypeAudioMic:
            // Handle audio sample buffer for mic audio
            // 处理麦克风音频
            NSLog(@"麦克风音频流");
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
}
- (void)stopRecording {
//    if (self.assetWriter.status == AVAssetWriterStatusWriting) {

        [self.assetWriter finishWritingWithCompletionHandler:^{
            NSLog(@"结束写入数据");
        }];
//        [self.audioInput markAsFinished];
//    }
}

@end
