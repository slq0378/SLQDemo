//
//  NotificationService.m
//  NotificationServiceExtension
//
//  Created by hz on 2021/8/16.
//  Copyright © 2021 难说再见了. All rights reserved.
//

#import "NotificationService.h"
#import <UIKit/UIKit.h>

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService
// 系统接到通知后，有最多30秒在这里重写通知内容（在此方法可进行一些网络请求，如上报是否收到通知等操作）
- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
     NSLog(@"%s",__FUNCTION__);
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    NSLog(@"%@",request.content);
    // 添加附件
    //1. 下载
    NSURL *url = [NSURL URLWithString:self.bestAttemptContent.userInfo[@"aps"][@"image-url"]];
    NSString *type = self.bestAttemptContent.userInfo[@"aps"][@"media"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    [[session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable temporaryFileLocation, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            //2. 保存数据
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *fileExt = [self fileExtensionForMediaType:type];
            NSURL *localURL = [NSURL fileURLWithPath:[temporaryFileLocation.path stringByAppendingString:fileExt]];
            [fileManager moveItemAtURL:temporaryFileLocation toURL:localURL error:&error];
            // 也可以保存到userInfo里
//            NSMutableDictionary * dict = [self.bestAttemptContent.userInfo mutableCopy];
//            [dict setObject:[NSData dataWithContentsOfURL:localURL] forKey:@"image"];
            self.bestAttemptContent.userInfo = @{};
            NSError *attachmentError = nil;
            UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"" URL:localURL options:nil error:&attachmentError];
            if (attachmentError) {
                NSLog(@"%@", attachmentError.localizedDescription);
            }
            //3 添加到附件
            self.bestAttemptContent.attachments = @[attachment];
        }else{
            self.bestAttemptContent.title = @"标题";
            self.bestAttemptContent.subtitle = @"子标题";
            self.bestAttemptContent.body = self.bestAttemptContent.userInfo[@"aps"][@"image-url"];
        }
        //4. 返回新的通知内容
        self.bestAttemptContent.categoryIdentifier = @"myNotificationCategory";// 和NotificationConentExtension关联
        self.contentHandler(self.bestAttemptContent);
    }] resume];
}
// 处理过程超时，则收到的通知直接展示出来
- (void)serviceExtensionTimeWillExpire {
     NSLog(@"%s",__FUNCTION__);
    self.contentHandler(self.bestAttemptContent);
}

- (NSString *)fileExtensionForMediaType:(NSString *)type {
    NSString *ext = type;
    if ([type isEqualToString:@"image"]) {
        ext = @"jpg";
    }
    else if ([type isEqualToString:@"video"]) {
        ext = @"mp4";
    }
    else if ([type isEqualToString:@"audio"]) {
        ext = @"mp3";
    }
    return [@"." stringByAppendingString:ext];
}
@end
