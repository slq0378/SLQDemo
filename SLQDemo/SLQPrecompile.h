//
//  SLQPrecompile_h
//
//
//  Created by song on 2021/5/13.
//  Copyright © 2021 song. All rights reserved.

#ifndef SLQPrecompile_h
#define SLQPrecompile_h
/*
 版本号
 */
#define SystemVersion [[UIDevice currentDevice].systemVersion floatValue]

/*
 屏幕宽度
 */
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

/*
 屏幕高度
 */
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

/*
 判断是否刘海屏
 */
#define IPhoneX (SystemVersion >= 11.f ? ([[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0) : NO)

/*
 状态栏高度
 */
#define kStatusBarHeight (CGFloat)(IPhoneX ? (SystemVersion >= 14.f ? [[UIApplication sharedApplication] statusBarFrame].size.height : (44.0)) : (20.0))

/*
 状态栏和导航栏总高度
 */
#define kNavBarHeight (CGFloat)(IPhoneX ? (SystemVersion >= 14.f ? (44.0 + kStatusBarHeight) : (88.0)) : (64.0))

/*
 TabBar高度
 */
#define kTabBarHeight (CGFloat)(IPhoneX ? (49.0 + 34.0) : (49.0))

/*
 顶部安全区域远离高度
 */
#define kTopBarSafeHeight (CGFloat)(IPhoneX ? (44.0) : (0))

/*
 底部安全区域远离高度
 */
#define kBottomSafeHeight (CGFloat)(IPhoneX ? (34.0) : (0))


#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

#pragma mark - 颜色
#ifndef RGB
#define RGB(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#endif

#ifndef RGBA
#define RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f \
alpha:(a)]
#endif

#ifndef UIColorFromRGB
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#endif

#ifndef UIColorFromRGBA
#define UIColorFromRGBA(rgbValue,alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(float)alphaValue]
#endif

#pragma mark - 字体
//#define kSystemFontSizeLevel [[[NSUserDefaults standardUserDefaults] objectForKey:@"WholeFontLevel"] == nil ? @"0" : [[NSUserDefaults standardUserDefaults] objectForKey:@"WholeFontLevel"] integerValue] // 级别越大字体越大1-4
#define kSystemFontSizeLevel 0

#define kSystemFontOfSize(size) [UIFont systemFontOfSize:((size) + (kSystemFontSizeLevel))]
#define kBoldSystemFontOfSize(size) [UIFont boldSystemFontOfSize:((size) + (kSystemFontSizeLevel))]

#define ThemeColor UIColorFromRGBA(0x1abc9c,1)
#endif /* SLQPrecompile_h */
