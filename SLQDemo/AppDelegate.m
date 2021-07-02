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

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
@end
