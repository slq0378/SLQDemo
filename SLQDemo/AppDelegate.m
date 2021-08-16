//
//  AppDelegate
//
//
//  Created by song on 2021/5/13.
//  Copyright © 2021 song. All rights reserved.

#import "AppDelegate.h"
#import "MainViewController.h"
#import <PushKit/PushKit.h>
#import <CallKit/CallKit.h>
#import <UserNotifications/UserNotifications.h>
@interface AppDelegate()< PKPushRegistryDelegate, UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self registerPushNotification];
    [self checkUserNotificationEnable];
    
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0) {
        //使用Pushkit的VOIP专享推送
        PKPushRegistry *pushRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
        pushRegistry.delegate = self;
        pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
        //        NSLog(@"registerPushNotification 8.0");
    }

    return YES;
}

#pragma mark - 不同版本的推送注册
- (void)registerPushNotification{
    UIApplication *application = [UIApplication sharedApplication];
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 10.0){
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionBadge+UNAuthorizationOptionAlert+UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
        }];
        [UNUserNotificationCenter currentNotificationCenter].delegate = self; // 这个很关键，一定记得添加
        [application registerForRemoteNotifications];
    }else if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0) {
        UIUserNotificationType types = UIUserNotificationTypeSound|UIUserNotificationTypeBadge|UIUserNotificationTypeAlert;
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [application registerUserNotificationSettings:setting];
        [application registerForRemoteNotifications];
    }
}

/**
 *  但APNs服务器返回deviceToken的时候调用该方法
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
//    NSLog(@"%s",__FUNCTION__);
    NSString *(^getDeviceToken)(void) = ^() {
        NSString *dataString = [deviceToken description];
        if ([dataString containsString:@"bytes"]) {
            const unsigned char *dataBuffer = (const unsigned char *)deviceToken.bytes;
            NSMutableString *myToken  = [NSMutableString stringWithCapacity:(deviceToken.length * 2)];
            for (int i = 0; i < deviceToken.length; i++) {
                [myToken appendFormat:@"%02x", dataBuffer[i]];
            }
            return (NSString *)[myToken copy];
        } else {
            NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
            NSString *myToken = [[deviceToken description] stringByTrimmingCharactersInSet:characterSet];
            return [myToken stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
    };
    
    NSString *receiveToken = getDeviceToken();
    
    NSLog(@"---->>>>device token：%@",receiveToken);
    
//    if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0) {
//        //使用Pushkit的VOIP专享推送
//        PKPushRegistry *pushRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
//        pushRegistry.delegate = self;
//        pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
////        NSLog(@"registerPushNotification 8.0");
//    }
    
}
#pragma mark - 收到推送，或者点击推送会走这个方法的，如果实现了更高版本方法，不会走，iOS8-iOS10
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"userInfo : %@", userInfo);
//    {
//        aps =     {
//            alert =         {
//                body = "2This is content";
//                subtitle = "Five Card Draw";
//                title = "2This is title";
//            };
//            identifier = 12321;
//    }
    if (application.applicationState == UIApplicationStateActive) {
        return;
    }
    
    NSString * data = userInfo[@"data"];
    if (data.length > 0) {
        
        
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
}
#pragma mark - UNUserNotificationCenterDelegate  >= iOS10.0
// 前台收到推送
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSLog(@"收到推送（前台）---->%@",notification.request.content);
    completionHandler(UNNotificationPresentationOptionAlert);
}

// 点击推送
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    NSLog(@"点击推送---->%@",response);
    completionHandler();
}

#pragma mark pushkit delegate >= iOS8.0
- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(PKPushType)type{
    
//    NSLog(@"%s",__FUNCTION__);
    NSString *pkToken;
    NSString *dataString = [credentials.token description];
    if ([dataString containsString:@"bytes"]) {
        const unsigned char *dataBuffer = (const unsigned char *)credentials.token.bytes;
        NSMutableString *myToken  = [NSMutableString stringWithCapacity:(credentials.token.length * 2)];
        for (int i = 0; i < credentials.token.length; i++) {
            [myToken appendFormat:@"%02x", dataBuffer[i]];
        }
        pkToken = (NSString *)[myToken copy];
    }else{
        pkToken = [[credentials.token description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        pkToken = [pkToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    NSLog(@"---->>>>voip token: %@",pkToken);
    
}
#pragma mark pushkit delegate >= iOS8.0
// 接受消息
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type{
    NSLog(@"推送---> %@",payload.dictionaryPayload);
    
    NSDictionary *dict = payload.dictionaryPayload;
    NSMutableDictionary *apsDict = [[dict objectForKey:@"aps"] mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addLocalNotice:apsDict];
    });
}
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void(^)(void))completion NS_AVAILABLE_IOS(11_0){
    NSLog(@"推送 ios 11---> %@,%@",payload.dictionaryPayload,type);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dict = payload.dictionaryPayload;
        NSMutableDictionary *apsDict = [[dict objectForKey:@"aps"] mutableCopy];
        [self addLocalNotice:apsDict];
        completion();
    });
}

// 添加本地推送，voip默认是没有推送的
- (void)addLocalNotice:(NSMutableDictionary *)apsDict {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        // 标题
        content.title = apsDict[@"alert"][@"title"];
        content.subtitle = apsDict[@"alert"][@"title"];
        // 内容
        content.body = apsDict[@"alert"][@"body"];
        // 声音
       // 默认声音
         content.sound = [UNNotificationSound defaultSound];
     // 添加自定义声音
//       content.sound = [UNNotificationSound soundNamed:@"Alert_ActivityGoalAttained_Salient_Haptic.caf"];
        // 角标 （我这里测试的角标无效，暂时没找到原因）
        content.badge = @1;
        // 多少秒后发送,可以将固定的日期转化为时间
        NSTimeInterval time = [[NSDate dateWithTimeIntervalSinceNow:1] timeIntervalSinceNow];
//        NSTimeInterval time = 10;
        // repeats，是否重复，如果重复的话时间必须大于60s，要不会报错
        UNPushNotificationTrigger *trigger = [[UNPushNotificationTrigger alloc] initWithCoder:nil];
        
        /*
        //如果想重复可以使用这个,按日期
        // 周一早上 8：00 上班
        NSDateComponents *components = [[NSDateComponents alloc] init];
        // 注意，weekday默认是从周日开始
        components.weekday = 2;
        components.hour = 8;
        UNCalendarNotificationTrigger *calendarTrigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
        */
        // 添加通知的标识符，可以用于移除，更新等操作
        NSString *identifier = @"noticeId";
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
        
        [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
            NSLog(@"成功添加推送");
        }];
    }else {
        UILocalNotification *notif = [[UILocalNotification alloc] init];
        // 发出推送的日期
        notif.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
        // 推送的内容
        notif.alertBody = apsDict[@"alert"][@"body"];
        // 可以添加特定信息
        notif.userInfo = @{@"noticeId":@"00001"};
        // 角标
        notif.applicationIconBadgeNumber = 1;
        // 提示音
        notif.soundName = UILocalNotificationDefaultSoundName;
        // 每周循环提醒
        notif.repeatInterval = NSCalendarUnitWeekOfYear;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notif];
    }
}




// 移除某一个指定的通知
- (void)removeOneNotificationWithID:(NSString *)noticeId {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
            for (UNNotificationRequest *req in requests){
                NSLog(@"存在的ID:%@\n",req.identifier);
            }
            NSLog(@"移除currentID:%@",noticeId);
        }];
        
        [center removePendingNotificationRequestsWithIdentifiers:@[noticeId]];
    }else {
        NSArray *array=[[UIApplication sharedApplication] scheduledLocalNotifications];
        for (UILocalNotification *localNotification in array){
            NSDictionary *userInfo = localNotification.userInfo;
            NSString *obj = [userInfo objectForKey:@"noticeId"];
            if ([obj isEqualToString:noticeId]) {
                [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
            }
        }
    }
}

// 移除所有通知
- (void)removeAllNotification {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center removeAllPendingNotificationRequests];
    }else {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}

- (void)checkUserNotificationEnable { // 判断用户是否允许接收通知
    if (@available(iOS 10.0, *)) {
        __block BOOL isOn = NO;
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            if (settings.notificationCenterSetting == UNNotificationSettingEnabled) {
                isOn = YES;
                NSLog(@"打开了通知");
            }else {
                isOn = NO;
                NSLog(@"关闭了通知");
                [self showAlertView];
            }
        }];
    }else {
        if ([[UIApplication sharedApplication] currentUserNotificationSettings].types == UIUserNotificationTypeNone){
            NSLog(@"关闭了通知");
            [self showAlertView];
        }else {
            NSLog(@"打开了通知");
        }
    }
}

- (void)showAlertView {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"通知" message:@"未获得通知权限，请前去设置" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self goToAppSystemSetting];
        }]];
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

// 如果用户关闭了接收通知功能，该方法可以跳转到APP设置页面进行修改
- (void)goToAppSystemSetting {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIApplication *application = [UIApplication sharedApplication];
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([application canOpenURL:url]) {
            if (@available(iOS 10.0, *)) {
                if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
                    [application openURL:url options:@{} completionHandler:nil];
                }
            }else {
                [application openURL:url];
            }
        }
    });
}

@end
