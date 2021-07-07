//
//  SampleHandler.h
//  boradcastr
//
//  Created by song on 2021/7/6.
//  Copyright © 2021 难说再见了. All rights reserved.
//

#import <ReplayKit/ReplayKit.h>

@interface SampleHandler : RPBroadcastSampleHandler

@end


@interface NSDate (Timestamp)
+ (NSString *)timestamp;
@end
 
@implementation NSDate (Timestamp)
+ (NSString *)timestamp {
    long long timeinterval = (long long)([NSDate timeIntervalSinceReferenceDate] * 1000);
    return [NSString stringWithFormat:@"%lld", timeinterval];
}
@end
