//
//  SLQAskDataModel
//  
//
//  Created by song on 2021/5/13.
//  Copyright © 2021 song. All rights reserved.
//

#import "SLQAskDataModel.h"
#import <objc/runtime.h>
@implementation SLQAskDataModel
- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (instancetype)modelWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}
// 重写description方法，中文打印出来是乱吗，还需要实现数组和字典的两个分类才能正常打印中文
- (NSString *)description{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    uint count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i = 0 ; i < count; i ++) {
        objc_property_t property = properties[i];
        NSString *name = @(property_getName(property));
        id value = [self valueForKey:name]?:nil;
        [dict setObject:value forKey:name];
    }
    free(properties);
    return [NSString stringWithFormat:@"<%@ : %p>--%@",[self class],self,dict];
}
@end
