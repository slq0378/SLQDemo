//
//  UIView+Extension.m
//  Weibo
//
//  Created by Vincent_Guo on 15-3-16.
//  Copyright (c) 2015年 Fung. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)

- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size
{
    return self.bounds.size;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGFloat)w
{
    return self.size.width;
}

- (void)setW:(CGFloat)w
{
    CGRect frame = self.frame;
    frame.size.width = w;
    self.frame = frame;
}

- (CGFloat)h
{
    return self.size.height;
}

- (void)setH:(CGFloat)h
{
    CGRect frame = self.frame;
    frame.size.height = h;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)midX
{
    return self.center.x;
}

- (void)setMidX:(CGFloat)midX
{
    self.center = CGPointMake(midX, self.center.y);
}

- (CGFloat)midY
{
    return self.center.y;
}

- (void)setMidY:(CGFloat)midY
{
    self.center = CGPointMake(self.center.x, midY);
}

- (CGFloat)maxX
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setMaxX:(CGFloat)maxX
{
    CGRect frame = self.frame;
    frame.origin.x = maxX - frame.size.width;
    self.frame = frame;
}

- (CGFloat)maxY
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setMaxY:(CGFloat)maxY
{
    CGRect frame = self.frame;
    frame.origin.y = maxY - frame.size.height;
    self.frame = frame;
}

/**
 *  获取当前View的控制器对象
 */
- (UIViewController *)getCurrentViewController
{
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}
@end
