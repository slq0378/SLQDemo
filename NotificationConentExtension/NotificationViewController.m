//
//  NotificationViewController.m
//  NotificationConentExtension
//
//  Created by hz on 2021/8/16.
//  Copyright © 2021 难说再见了. All rights reserved.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

@interface NotificationViewController () <UNNotificationContentExtension,UIActionSheetDelegate>

@property IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any required interface initialization here.
    NSLog(@"%s",__FUNCTION__);
    // 添加action
    UNNotificationAction * likeAction;              //喜欢
    UNNotificationAction * ingnoreAction;           //取消
    UNTextInputNotificationAction * inputAction;    //文本输入
    
    likeAction = [UNNotificationAction actionWithIdentifier:@"action_like"
                                                      title:@"点赞"
                                                    options:UNNotificationActionOptionForeground];
    inputAction = [UNTextInputNotificationAction actionWithIdentifier:@"action_input"
                                                                title:@"评论"
                                                              options:UNNotificationActionOptionForeground
                                                 textInputButtonTitle:@"发送"
                                                 textInputPlaceholder:@"说点什么"];
    ingnoreAction = [UNNotificationAction actionWithIdentifier:@"action_cancel"
                                                         title:@"忽略"
                                                       options:UNNotificationActionOptionDestructive];
    NSString *categoryWithIdentifier = @"myNotificationCategory";// 和info.plist中配置的id一样
    UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:categoryWithIdentifier actions:@[likeAction,inputAction,ingnoreAction] intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
    
    NSSet *sets = [NSSet setWithObjects:category,nil];
    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:sets];
}

- (void)didReceiveNotification:(UNNotification *)notification {
    self.label.text = notification.request.content.body;
    NSLog(@"didReceiveNotification:%@",notification.request.content);
    for (UNNotificationAttachment * attachment in notification.request.content.attachments) {
        NSLog(@"url:%@",attachment.URL);
        if([attachment.URL startAccessingSecurityScopedResource]){
            NSData *data = [NSData dataWithContentsOfURL:attachment.URL];
            self.imageView.image = [UIImage imageWithData:data];
            [attachment.URL stopAccessingSecurityScopedResource];
        }
    
    }
}

- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption))completion {
    NSLog(@"response:%@",response);
    if ([response.actionIdentifier isEqualToString:@"action_like"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            completion(UNNotificationContentExtensionResponseOptionDismiss);
        });
    } else if ([response.actionIdentifier isEqualToString:@"action_input"]) {
        UNTextInputNotificationResponse *inputAction = (UNTextInputNotificationResponse*)response;
        NSLog(@"输入内容：%@",inputAction.userText);
        // TODO: 发送评论
        completion(UNNotificationContentExtensionResponseOptionDismiss);
    } else if ([response.actionIdentifier isEqualToString:@"action_cancel"]) {
        completion(UNNotificationContentExtensionResponseOptionDismiss);
    } else {
        completion(UNNotificationContentExtensionResponseOptionDismiss);
    }
    completion(UNNotificationContentExtensionResponseOptionDoNotDismiss);
}
@end
