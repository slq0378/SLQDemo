//
//  NSString+Size.h
//  SLQVideoLive
//
//  Created by song on 2021/5/14.
//  Copyright © 2021 难说再见了. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Size)
/**
 * 计算文字高度，可以处理计算带行间距的
 */
- (CGSize)boundingRectWithSize:(CGSize)size font:(UIFont*)font  lineSpacing:(CGFloat)lineSpacing;
/**
 *  计算最大行数文字高度,可以处理计算带行间距的
 */
- (CGFloat)boundingRectWithSize:(CGSize)size font:(UIFont*)font  lineSpacing:(CGFloat)lineSpacing maxLines:(NSInteger)maxLines;
/**
 *  计算是否超过一行   用于给Label 赋值attribute text的时候 超过一行设置lineSpace
 */
- (BOOL)isMoreThanOneLineWithSize:(CGSize)size font:(UIFont *)font lineSpaceing:(CGFloat)lineSpacing;
@end

NS_ASSUME_NONNULL_END
