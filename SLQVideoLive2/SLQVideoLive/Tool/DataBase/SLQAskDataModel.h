//
//  SLQAskDataModel
//
//
//  Created by song on 2021/5/13.
//  Copyright © 2021 song. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLQAskDataModel : NSObject
@property (nonatomic, copy) NSString *keyid;
@property (nonatomic, copy) NSString *typeId;
@property (nonatomic, copy) NSString *ask;
@property (nonatomic, copy) NSString *answer;
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, copy) NSString *updateTime;
@property (nonatomic, copy) NSString *nextCircle;
@property (nonatomic, copy) NSString *ext1;
@property (nonatomic, copy) NSString *ext2;
- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)modelWithDict:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
