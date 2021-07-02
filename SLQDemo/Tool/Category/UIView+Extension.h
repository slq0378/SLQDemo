//
//  UIView+Extension.h
//  Weibo
//
//  Created by Vincent_Guo on 15-3-16.
//  Copyright (c) 2015年 Fung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)

/**
 *  UIView的坐标
 */
@property(nonatomic, assign) CGPoint origin;

/**
 *  UIView的尺寸
 */
@property(nonatomic, assign) CGSize size;

/**
 *  UIView的宽度
 */
@property(nonatomic, assign) CGFloat w;

/**
 *  UIView的高度
 */
@property(nonatomic, assign) CGFloat h;

/**
 *  UIView的'X'坐标（起始）
 */
@property(nonatomic, assign) CGFloat x;

/**
 *  UIView的'Y'坐标（起始）
 */
@property(nonatomic, assign) CGFloat y;

/**
 *  UIView的'X'坐标（居中）
 */
@property(nonatomic, assign) CGFloat midX;

/**
 *  UIView的'Y'坐标（居中）
 */
@property(nonatomic, assign) CGFloat midY;

/**
 *  UIView的'X'坐标（结束）
 */
@property(nonatomic, assign) CGFloat maxX;

/**
 *  UIView的'Y'坐标（结束）
 */
@property(nonatomic, assign) CGFloat maxY;

/**
 *  获取当前View的控制器对象
 */
- (UIViewController *)getCurrentViewController;
@end
