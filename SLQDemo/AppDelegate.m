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
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self setup3DTouch];
    return YES;
}
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
