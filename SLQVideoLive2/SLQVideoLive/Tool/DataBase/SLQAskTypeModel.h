//
//  SLQAskTypeModel.h
//  SLQVideoLive
//
//  Created by song on 2021/5/21.
//  Copyright © 2021 难说再见了. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLQAskTypeModel : NSObject
@property (nonatomic, copy) NSString *keyid;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, copy) NSString *ext1;
@property (nonatomic, copy) NSString *ext2;
- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)modelWithDict:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
