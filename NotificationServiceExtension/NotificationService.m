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
    NSURL *url = [NSURL URLWithString:@"https://tva1.sinaimg.cn/large/008i3skNgy1gtir9lwnj0j61x40gsabl02.jpg"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            //2. 保存数据
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject
                              stringByAppendingPathComponent:@"download/image.jpg"];
            UIImage *image = [UIImage imageWithData:data];
            NSError *err = nil;
            [UIImageJPEGRepresentation(image, 1) writeToFile:path options:NSAtomicWrite error:&err];
            //3. 添加附件
            UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"remote-atta1" URL:[NSURL fileURLWithPath:path] options:nil error:&err];
            if (attachment) {
                self.bestAttemptContent.attachments = @[attachment];
            }
        }else{
            self.bestAttemptContent.title = @"标题";
                self.bestAttemptContent.subtitle = @"子标题";
                self.bestAttemptContent.body = @"body";
        }
        //4. 返回新的通知内容
        self.contentHandler(self.bestAttemptContent);
    }];
    [task resume];
}
// 处理过程超时，则收到的通知直接展示出来
- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
     NSLog(@"%s",__FUNCTION__);
    self.contentHandler(self.bestAttemptContent);
}

@end
