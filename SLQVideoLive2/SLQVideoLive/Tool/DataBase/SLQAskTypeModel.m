//
//  SLQAskTypeModel.m
//  SLQVideoLive
//
//  Created by song on 2021/5/21.
//  Copyright © 2021 难说再见了. All rights reserved.
//

#import "SLQAskTypeModel.h"
#import <objc/runtime.h>
@implementation SLQAskTypeModel
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
