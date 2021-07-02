//
//  NSArray+CN.m
//  SLQVideoLive
//
//  Created by song on 2021/5/25.
//  Copyright © 2021 难说再见了. All rights reserved.
//

#import "NSArray+CN.h"

@implementation NSArray (CN)
-(NSString *)descriptionWithLocale:(id)locale
{
    NSMutableString *msr = [NSMutableString string];
    [msr appendString:@"["];
    for (id obj in self) {
        [msr appendFormat:@"\n\t%@,",obj];
    }
    //去掉最后一个逗号（,）
    if ([msr hasSuffix:@","]) {
        NSString *str = [msr substringToIndex:msr.length - 1];
        msr = [NSMutableString stringWithString:str];
    }
    [msr appendString:@"\n]"];
    return msr;
}
@end
