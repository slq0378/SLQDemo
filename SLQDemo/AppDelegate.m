//
//  AppDelegate
//
//
//  Created by song on 2021/5/13.
//  Copyright © 2021 song. All rights reserved.

#import "AppDelegate.h"
#import "Test1ViewController.h"
#import "Test2ViewController.h"
#import "Test3ViewController.h"
#import "MainViewController.h"
#import <PushKit/PushKit.h>
#import <UserNotifications/UserNotifications.h>
@interface AppDelegate()< PKPushRegistryDelegate, UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
//    [self setup3DTouch];
    [self registerPushNotification];
    
    
//    [self showLocalPush:@{
//        @"alert":@"计算机三级"
//    }];
    return YES;
}

#pragma mark - 不同版本的推送注册
- (void)registerPushNotification{
    UIApplication *application = [UIApplication sharedApplication];

    //远程推送
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 10.0){
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionBadge+UNAuthorizationOptionAlert+UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [application registerForRemoteNotifications];
                });
            }
        }];
        [application registerForRemoteNotifications];
    }else if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0) {
        UIUserNotificationType types = UIUserNotificationTypeSound|UIUserNotificationTypeBadge|UIUserNotificationTypeAlert;
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [application registerUserNotificationSettings:setting];
        //      注册远程通知
        [application registerForRemoteNotifications];
        
    }else{
        //  iOS8之前,注册远程通知
        UIRemoteNotificationType types = UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:types];
    }
}

/**
 *  但APNs服务器返回deviceToken的时候调用该方法
 *
 *  @param application 应用
 *  @param deviceToken deviceToken 包含(手机的UUID,应用BundleID)
 
 <e792c765 7eeb42f7 7c689f92 58e4cd3d 646adc55 c7a9eb49 d7b8ef8f c4f34ec4>
 <4ba408ae 5a6f957c 4aade33a 37598c8b 17ff9d4f 7c274dac ab83442c b69a3ac1>
 deviceToken 不包含 “<” 和 ">"
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
    
    NSLog(@"device token -->>%@",receiveToken);
    
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0) {
        //使用Pushkit的VOIP专享推送
        PKPushRegistry *pushRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
        pushRegistry.delegate = self;
        pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
//        NSLog(@"registerPushNotification 8.0");
    }
    
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"userInfo : %@", userInfo);
    if (application.applicationState == UIApplicationStateActive) {
        return;
    }
    
    NSString * data = userInfo[@"data"];
    if (data.length > 0) {
        
        
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@">>>>>userinfo<<<<<");
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSLog(@"======+++++didReceiveLocalNotification--%@",notification.userInfo);
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

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type{
    NSLog(@"推送---> %@",payload.dictionaryPayload);
    
    NSDictionary *dict = payload.dictionaryPayload;
    NSMutableDictionary *apsDict = [[dict objectForKey:@"aps"] mutableCopy];
    
    //本地通知
    [self showLocalPush:apsDict];
    
}


- (void)showLocalPush:(NSDictionary *)msgDict{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    UILocalNotification *localNotification = [[UILocalNotification alloc]init];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = 1;
    localNotification.alertBody = msgDict[@"alert"];
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

#pragma mark - UNUserNotificationCenterDelegate  >= iOS10.0
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSLog(@"willPresentNotification---->");
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    NSLog(@"didReceiveNotificationResponse---->%@",response);
    // iOS 10 点击通知会调用这个，无论是否用UNUserNotificationCenter
    
    completionHandler();
}

#pragma mark - 3D
- (void)setup3DTouch{
    // 判断是否支持3DTouch
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(shortcutItems)]) {
        UIApplicationShortcutIcon *icon1 = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeAdd];
        UIApplicationShortcutIcon *icon2 = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeAdd];
        UIMutableApplicationShortcutItem *item1 = [[UIMutableApplicationShortcutItem alloc] initWithType:@"addCar" localizedTitle:@"新增1" localizedSubtitle:nil icon:icon1 userInfo:nil];
        UIMutableApplicationShortcutItem *item2 = [[UIMutableApplicationShortcutItem alloc] initWithType:@"addPerson" localizedTitle:@"新增2" localizedSubtitle:nil icon:icon2 userInfo:nil];
        [[UIApplication sharedApplication] setShortcutItems:@[item1,item2]];
    }
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    NSLog(@"openURL:%@",url);

    return  YES;
}




#pragma mark - 3DTouch action

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    
    NSString *type = shortcutItem.type;
    NSLog(@"shortcutItem：%@",type);

    if ([type isEqualToString:@"addCar"]) {
    
        UINavigationController *rootViewController = (UINavigationController*)[UIApplication sharedApplication].keyWindow.rootViewController;
        NSArray *viewControllers = rootViewController.viewControllers;
        MainViewController *navi = viewControllers[0];
        Test1ViewController *vc = [[Test1ViewController alloc] init];
        [navi.navigationController pushViewController:vc animated:YES];
        
    }else {
        UINavigationController *rootViewController = (UINavigationController*)[UIApplication sharedApplication].keyWindow.rootViewController;
        NSArray *viewControllers = rootViewController.viewControllers;
        MainViewController *navi = viewControllers[0];
        Test2ViewController *vc = [[Test2ViewController alloc] init];
        [navi.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - UISceneSession lifecycle
- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    NSLog(@"%s",__FUNCTION__);
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}
 
 
- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    
      NSLog(@"%s",__FUNCTION__);

}
@end
