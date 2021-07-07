//
//  SQLiteManager
//
//
//  Created by song on 2021/5/13.
//  Copyright © 2021 song. All rights reserved.

#import "SQLiteManager.h"
#import <objc/runtime.h>
@interface SQLiteManager ()
//存储查询结果
@property (nonatomic,strong) NSArray *resultArr;
@end

@implementation SQLiteManager

+ (instancetype)shareInstance{
    static SQLiteManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [instance reloadDataBase];
    });
    return instance;
}


#pragma mark - ///////////////////////////JSON///////////////////////////
#pragma mark model直接转JSON
+ (NSString *)transferToJSONWithModel:(id)model {
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([model class], &count);
    
    NSMutableString *jsonStr = [NSMutableString string];
    [jsonStr appendString:@"{"];
    
    for (int i= 0; i < count; i++) {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [model valueForKey:(NSString *)propertyName];
        /**************/
        const char * attribute = property_getAttributes(property);//获取属性类型
        NSString *attributeStr = [NSString stringWithUTF8String: attribute];
        //        NSLog(@"attributeStr = %@",attributeStr);
        if ([attributeStr rangeOfString:@"T@\"NSString\""].location != NSNotFound) {  //NSString类型加引号
            NSString *str = [NSString stringWithFormat:@"\"%@\":\"%@\",",propertyName,propertyValue?:@""];
            [jsonStr appendString:str];
        }else if ([attributeStr rangeOfString:@"T@\"NSNumber\""].location != NSNotFound) {  //NSNumber类型不加引号
            NSString *str = [NSString stringWithFormat:@"\"%@\":\"%@\"",propertyName,propertyValue?:@""];
            [jsonStr appendString:str];
        }else {
            NSString *str = [NSString stringWithFormat:@"\"%@\":\"%@\"",propertyName,propertyValue?:@""];
            [jsonStr appendString:str];
        }
        
        //        NSString *str = [NSString stringWithFormat:@"'%@':'%@',",propertyName,propertyValue];
        //        [jsonStr appendString:str];
        /**************/
    }
    [jsonStr deleteCharactersInRange:NSMakeRange(jsonStr.length - 1, 1)];
    [jsonStr appendString:@"}"];
    NSLog(@"jsonStr = %@",jsonStr);
    
    return jsonStr;
}
#pragma mark model去除指定属性转JSON
+ (NSString *)transferToJSONWithModel:(id)model withoutPropertyNameArr:(NSArray *)propertyNameArr {
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([model class], &count);
    
    NSMutableString *jsonStr = [NSMutableString string];
    [jsonStr appendString:@"{"];
    
    for (int i= 0; i < count; i++) {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
    
        if (![propertyNameArr containsObject:propertyName]) {
            id propertyValue = [model valueForKey:(NSString *)propertyName];
            const char * attribute = property_getAttributes(property);//获取属性类型
            NSString *attributeStr = [NSString stringWithUTF8String: attribute];
            if ([attributeStr rangeOfString:@"T@\"NSString\""].location != NSNotFound) {  //NSString类型加引号
                NSString *str = [NSString stringWithFormat:@"\"%@\":\"%@\",",propertyName,propertyValue?:@""];
                [jsonStr appendString:str];
            }else if ([attributeStr rangeOfString:@"T@\"NSNumber\""].location != NSNotFound) {  //NSNumber类型不加引号
                NSString *str = [NSString stringWithFormat:@"\"%@\":%@,",propertyName,propertyValue?:@""];
                [jsonStr appendString:str];
            }else {
                NSString *str = [NSString stringWithFormat:@"\"%@\":%@,",propertyName,propertyValue?:@""];
                [jsonStr appendString:str];
            }
         
        }
        
    }
    [jsonStr deleteCharactersInRange:NSMakeRange(jsonStr.length - 1, 1)];
    [jsonStr appendString:@"}"];
    NSLog(@"jsonStr = %@",jsonStr);
    
    return jsonStr;
}
#pragma mark model去除指定属性并替换指定key的value为设置的值后再转JSON
+ (NSString *)transferToJSONWithModelValue:(id)model andReplaceDict:(NSDictionary *)replaceDict withoutPropertyNameArr:(NSArray *)propertyNameArr {
    
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([model class], &count);
    
    NSMutableString *jsonStr = [NSMutableString string];
    [jsonStr appendString:@"{"];
    
    // 获取需要替换的键值对数组
    NSArray *keys = [replaceDict allKeys];
    //    NSArray *values = [replaceDict allValues];
    
    for (int i= 0; i < count; i++) {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        
        //        if (propertyNameArr != nil) {//去除不需要的属性名
        if (![propertyNameArr containsObject:propertyName]) {
            
            if ([keys containsObject:propertyName]) {//需要替换的属性值
                const char * attribute = property_getAttributes(property);//获取属性类型
                NSString *attributeStr = [NSString stringWithUTF8String: attribute];
                NSLog(@"attributeStr = %@",attributeStr);
                if ([attributeStr rangeOfString:@"T@\"NSString\""].location != NSNotFound) {  //NSString类型加引号
                    NSString *str = [NSString stringWithFormat:@"\"%@\":\"%@\",",propertyName,replaceDict[propertyName]?:@""];
                    [jsonStr appendString:str];
                }else if ([attributeStr rangeOfString:@"T@\"NSNumber\""].location != NSNotFound) {  //NSNumber类型不加引号
                    NSString *str = [NSString stringWithFormat:@"\"%@\":%@,",propertyName,replaceDict[propertyName]?:@""];
                    [jsonStr appendString:str];
                }else {
                    NSString *str = [NSString stringWithFormat:@"\"%@\":%@,",propertyName,replaceDict[propertyName]?:@""];
                    [jsonStr appendString:str];
                }
                
            }else {
                id propertyValue = [model valueForKey:(NSString *)propertyName];
                const char * attribute = property_getAttributes(property);//获取属性类型
                NSString *attributeStr = [NSString stringWithUTF8String: attribute];
                //        NSLog(@"attributeStr = %@",attributeStr);
                if ([attributeStr rangeOfString:@"T@\"NSString\""].location != NSNotFound) {  //NSString类型加引号
                    NSString *str = [NSString stringWithFormat:@"\"%@\":\"%@\",",propertyName,propertyValue?:@""];
                    [jsonStr appendString:str];
                }else if ([attributeStr rangeOfString:@"T@\"NSNumber\""].location != NSNotFound) {  //NSNumber类型不加引号
                    NSString *str = [NSString stringWithFormat:@"\"%@\":%@,",propertyName,propertyValue?:@""];
                    [jsonStr appendString:str];
                }else {
                    NSString *str = [NSString stringWithFormat:@"\"%@\":%@,",propertyName,propertyValue?:@""];
                    [jsonStr appendString:str];
                }
            }
            
        }
    }
    [jsonStr deleteCharactersInRange:NSMakeRange(jsonStr.length - 1, 1)];
    [jsonStr appendString:@"}"];
    NSLog(@"jsonStr = %@",jsonStr);
    
    return jsonStr;
    
}
#pragma mark model去除指定属性并替换指定key为要替换的key后再转JSON
+ (NSString *)transferToJSONWithModelKey:(id)model withoutPropertyNameArr:(NSArray *)propertyNameArr withReplacedPropertyNameDict:(NSDictionary *)replacedPropertyNameDict {
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([model class], &count);
    
    NSArray *replacedPropertyNameArr = [replacedPropertyNameDict allKeys];  // 获取字典的所有key
    
    NSMutableString *jsonStr = [NSMutableString string];
    [jsonStr appendString:@"{"];
    
    for (int i= 0; i < count; i++) {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        
        if (propertyNameArr != nil) {  //去除不需要的属性名
            
            if (![propertyNameArr containsObject:propertyName]) {
                if ([replacedPropertyNameArr containsObject:propertyName]) {  //替换属性名
                    id propertyValue = [model valueForKey:(NSString *)propertyName];
                    NSString *str = [NSString stringWithFormat:@"\"%@\":\"%@\",",replacedPropertyNameDict[propertyName],propertyValue?:@""];
                    [jsonStr appendString:str];
                }else {  //不需要替换属性名
                    id propertyValue = [model valueForKey:(NSString *)propertyName];
                    NSString *str = [NSString stringWithFormat:@"\"%@\":\"%@\",",propertyName,propertyValue?:@""];
                    [jsonStr appendString:str];
                }
                
            }
        }
        else {
            if ([replacedPropertyNameArr containsObject:propertyName]) {  //替换属性名
                id propertyValue = [model valueForKey:(NSString *)propertyName];
                NSString *str = [NSString stringWithFormat:@"\"%@\":\"%@\",",replacedPropertyNameDict[propertyName],propertyValue?propertyValue:@""];
                [jsonStr appendString:str];
            }else {  //不需要替换属性名
                id propertyValue = [model valueForKey:(NSString *)propertyName];
                NSString *str = [NSString stringWithFormat:@"\"%@\":\"%@\",",propertyName,propertyValue?:@""];
                [jsonStr appendString:str];
            }
        }
        
    }
    [jsonStr deleteCharactersInRange:NSMakeRange(jsonStr.length - 1, 1)];
    [jsonStr appendString:@"}"];
    NSLog(@"jsonStr = %@",jsonStr);
    
    return jsonStr;
}


#pragma mark - ///////////////////////////SQLite///////////////////////////
/// 查询
- (NSArray *)recorsSetWithSql:(NSString *)sql{
    
    [self.queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback){
        FMResultSet *result = [db executeQuery:sql];
        if (result == nil) { //没有查询结果
            return;
        }
        
        NSMutableArray *array = [NSMutableArray array];
        while (result.next) {
            int col = [result columnCount];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary]; //每一行为一个字典
            for (int i = 0; i < col; i++) {
                NSString *colName = [result columnNameForIndex:i];
                id value = [result objectForColumnIndex:i];
                dict[colName] = value;
            }
            [array addObject:dict];
        }
        self.resultArr = array;
        
        [result close];
    }];
    return self.resultArr;
}

+ (BOOL)createTableWithFileName:(NSString *)table {
    return [[SQLiteManager shareInstance] createTableWithFileName:table];
}
+ (BOOL)createTableWithSql:(NSString *)sql {
    return [[SQLiteManager shareInstance] createTableWithSql:sql];
}
- (BOOL)createTableWithSql:(NSString *)sql {
    BOOL __block isSucced = NO;
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([db executeStatements:sql]) {
//            NSLog(@"创建表成功:%@",sql);
            isSucced = YES;
        }else{
            isSucced = NO;
            //            NSLog(@"创建表失败:%@",sql);
        }
    }];
    
    return isSucced;
}
/// 创建表
- (BOOL)createTableWithFileName:(NSString *)table{
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"db.sql" ofType:nil];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:table ofType:nil];
    NSString *sql = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    BOOL __block isSucced = NO;
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([db executeStatements:sql]) {
//            NSLog(@"创建表成功:%@",sql);
            isSucced = YES;
        }else{
            isSucced = NO;
            NSLog(@"创建表失败:%@",sql);
        }
    }];
    
    return isSucced;
}

/**
 判断表中是否存储某个字段

 @param col 字段名称，默认text类型
 @param table 表名称
 */
+ (void)addColum:(NSString *)col toTable:(NSString *)table {
    // 1、表是否存在
    NSString *sqlTable = [NSString stringWithFormat:@"SELECT COUNT(*) as CNT FROM sqlite_master where type='table' and name='%@'",table];// CNT = 1;
    NSArray *tableRes = [[SQLiteManager shareInstance] recorsSetWithSql:sqlTable];
    // 2、字段是否存在
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) as CNT FROM sqlite_master where name = '%@' and sql like '%%%@%%'",table,col];// CNT = 1
    NSArray *res = [[SQLiteManager shareInstance] recorsSetWithSql:sql];
    // 3、表存在且字段不存在就新增
    if(![[tableRes firstObject][@"CNT"]  isEqual:@(0)]) {
        if ([[res firstObject][@"CNT"] isEqual:@(0)]) {
            NSString *addSql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ text;",table,col];
            [[SQLiteManager shareInstance].queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                if([db executeUpdate:addSql]) {
                    NSLog(@"增加字段成功%@",addSql);
                }else {
                    NSLog(@"增加字段错误%@", [db lastError].userInfo);
                }
                
            }];
        }
    }
}

+ (BOOL)isExistModel:(id)model {
    
    __block BOOL isExist = NO;
    [[SQLiteManager shareInstance].queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *className = NSStringFromClass([model class]); // OC 类似：CarePeopleModel
        unsigned int count = 0;
        objc_property_t *properties = class_copyPropertyList([model class], &count); // 属性名列表
        NSMutableArray *propertyNames = [NSMutableArray array];
        objc_property_t property = properties[0]; // 主键id
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
         [propertyNames addObject:propertyName];
        // 主键值
        // 每一次遍历属性数组，通过valueForKey获取属性的值
        if (![model valueForKey:propertyNames[0]]) {
            [model setValue:@"" forKey:propertyNames[0]];
        }
        NSString *keyid = [model valueForKey:propertyNames[0]];
        NSString *searchStr = [NSString stringWithFormat:@"select * from %@ where %@ = '%@'",className,propertyName,keyid];
        //        NSLog(@"***************\n%@",searchStr);
        if ([[db executeQuery:searchStr] next]) {
            // 存在记录，更新
            isExist = YES;
        }else {
            // 记录不存在，插入
            isExist = NO;
        }
    }];
    
    return isExist;
}

+ (BOOL)insertDataWithModels:(NSArray *)models {
    __block BOOL isSucced = NO;
    for (NSObject *mod in models) {
       isSucced = [self insertDataWithModel:mod];
    }
    return isSucced;
}
+ (BOOL)insertOrUpdateDataWithModel:(id)model {
    //    // 以前的查询语句  select *from ZDDUserModel where user_id = ?
    //    // 后台不可能有重复的用户id（譬如QQ号码）用户的唯一标示user_id来表示
    //    NSString *selectStr = [NSString stringWithFormat:@"select *from %@ where %@ = ?",NSStringFromClass([model class]),[KMODEL_PROPERTYS objectAtIndex:0]];
    //    // 获取对应属性的对应值
    //    FMResultSet * resultSet = [myDb executeQuery:selectStr,[model valueForKey:[KMODEL_PROPERTYS objectAtIndex:0]]];
    
    __block BOOL isSucced = NO;
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([model class], &count);
    NSMutableArray *propertyNames = [NSMutableArray array];
    // 本次做插入操作
    // 以前插入的句子 insert into ZDDUserModel (user_id,userName,userIcon,expirationDate) values (?,?,?,?);
    
    // 插入语句第一部分
    //    NSString *modelName = NSStringFromClass([model class]);  //swift类似：JingMinLianDong.CarePeopleModel
    //    NSString *namespace = [NSBundle mainBundle].infoDictionary[@"CFBundleExecutable"];
    //    NSString *prefixStr = [NSString stringWithFormat:@"%@.",namespace];
    //    NSString *className = [modelName stringByReplacingOccurrencesOfString:prefixStr withString:@""];
    NSString *className = NSStringFromClass([model class]); // OC 类似：CarePeopleModel
    //    NSLog(@"className = %@",className);
    NSString *insertStrOne = [NSString stringWithFormat:@"insert or replace into %@ (",className];
    //    NSString *insertStrOne = [NSString stringWithFormat:@"insert into %@ (",NSStringFromClass([model class])];
    
    
    // 插入语句第二部分
    NSMutableString *insertStrTwo = [NSMutableString string];
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        [propertyNames addObject:propertyName];
        //        id propertyValue = [model valueForKey:(NSString *)propertyName];
        [insertStrTwo appendString:propertyName];
        if (i != count - 1) {
            [insertStrTwo appendString:@","];
        }
    }
    // 插入语句第三部分
    NSString *insertStrThree =[NSString stringWithFormat:@") values ("];
    // 插入语句第四部分
    NSMutableString *insertStrFour =[NSMutableString string];
    for (int i = 0; i < count; i++) {
        [insertStrFour appendFormat:@"?"];
        if (i != count - 1) {
            [insertStrFour appendFormat:@","];
        }
    }
    // 插入整个语句
    NSString *insertStr = [NSString stringWithFormat:@"%@%@%@%@);",insertStrOne,insertStrTwo,insertStrThree,insertStrFour];
    
    NSLog(@"insertStr = %@",insertStr);
    
    // 属性值数组
    NSMutableArray *propertyValue = [NSMutableArray array];
    for (NSString *property in propertyNames) {
        // 每一次遍历属性数组，通过valueForKey获取属性的值
        if (![model valueForKey:property]) {
            [model setValue:@"" forKey:property];
        }
        [propertyValue addObject:[model valueForKey:property]];
    }
//    NSLog(@"value = %@",propertyValue);
    [[SQLiteManager shareInstance].queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        if([db executeUpdate:insertStr withArgumentsInArray:propertyValue]) {
            isSucced = YES;
        }
        else {
            isSucced = NO;
        }
    }];
    return isSucced;
}
+ (BOOL)insertDataWithModel:(id)model {
    //    // 以前的查询语句  select *from ZDDUserModel where user_id = ?
    //    // 后台不可能有重复的用户id（譬如QQ号码）用户的唯一标示user_id来表示
    //    NSString *selectStr = [NSString stringWithFormat:@"select *from %@ where %@ = ?",NSStringFromClass([model class]),[KMODEL_PROPERTYS objectAtIndex:0]];
    //    // 获取对应属性的对应值
    //    FMResultSet * resultSet = [myDb executeQuery:selectStr,[model valueForKey:[KMODEL_PROPERTYS objectAtIndex:0]]];
    
    __block BOOL isSucced = NO;
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([model class], &count);
    NSMutableArray *propertyNames = [NSMutableArray array];
    // 本次做插入操作
    // 以前插入的句子 insert into ZDDUserModel (user_id,userName,userIcon,expirationDate) values (?,?,?,?);
    
    // 插入语句第一部分
    //    NSString *modelName = NSStringFromClass([model class]);  //swift类似：YangGuangJiaYuan.CarePeopleModel
    //    NSString *namespace = [NSBundle mainBundle].infoDictionary[@"CFBundleExecutable"];
    //    NSString *prefixStr = [NSString stringWithFormat:@"%@.",namespace];
    //    NSString *className = [modelName stringByReplacingOccurrencesOfString:prefixStr withString:@""];
    NSString *className = NSStringFromClass([model class]); // OC 类似：CarePeopleModel
//    NSLog(@"className = %@",className);
    NSString *insertStrOne = [NSString stringWithFormat:@"insert or replace into %@ (",className];
    //    NSString *insertStrOne = [NSString stringWithFormat:@"insert into %@ (",NSStringFromClass([model class])];
    
    
    // 插入语句第二部分
    NSMutableString *insertStrTwo = [NSMutableString string];
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        [propertyNames addObject:propertyName];
        //        id propertyValue = [model valueForKey:(NSString *)propertyName];
        [insertStrTwo appendString:propertyName];
        if (i != count - 1) {
            [insertStrTwo appendString:@","];
        }
    }
    // 插入语句第三部分
    NSString *insertStrThree =[NSString stringWithFormat:@") values ("];
    // 插入语句第四部分
    NSMutableString *insertStrFour =[NSMutableString string];
    for (int i = 0; i < count; i++) {
        [insertStrFour appendFormat:@"?"];
        if (i != count - 1) {
            [insertStrFour appendFormat:@","];
        }
    }
    // 插入整个语句
    NSString *insertStr = [NSString stringWithFormat:@"%@%@%@%@);",insertStrOne,insertStrTwo,insertStrThree,insertStrFour];
    
//    NSLog(@"insertStr = %@",insertStr);
    
    // 属性值数组
    NSMutableArray *propertyValue = [NSMutableArray array];
    for (NSString *property in propertyNames) {
        // 每一次遍历属性数组，通过valueForKey获取属性的值
        if (![model valueForKey:property]) {
            [model setValue:@"" forKey:property];
        }
        [propertyValue addObject:[model valueForKey:property]];
    }
    [[SQLiteManager shareInstance].queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        if([db executeUpdate:insertStr withArgumentsInArray:propertyValue]) {
            isSucced = YES;
        }
        else {
            isSucced = NO;
        }
    }];
    return isSucced;
}

+ (BOOL)updateDataWithModel:(id)model {
    
    __block BOOL isSucced = NO;
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([model class], &count);
    NSMutableArray *propertyNames = [NSMutableArray array];
    
    // 以前的更新语句 update ZDDUserModel set userId = ?,userName = ?,email = ? where user_id =%@
    
    // 更新语句第一部分
    //    NSString *modelName = NSStringFromClass([model class]);  //类似：YangGuangJiaYuan.CarePeopleModel
    //    NSString *namespace = [NSBundle mainBundle].infoDictionary[@"CFBundleExecutable"];
    //    NSString *prefixStr = [NSString stringWithFormat:@"%@.",namespace];
    //    NSString *className = [modelName stringByReplacingOccurrencesOfString:prefixStr withString:@""];
    NSString *className = NSStringFromClass([model class]); // OC 类似：CarePeopleModel
    NSString *updateStrOne = [NSString stringWithFormat:@"update %@ set ",className];
    //    NSString *updateStrOne = [NSString stringWithFormat:@"update %@ set ",NSStringFromClass([model class])];
    // 更新语句第二部分
    NSMutableString *updateStrTwo = [NSMutableString string];
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        [propertyNames addObject:propertyName];
        
        if (i != 0) {  //主键不进行更新(主键默认放在第一位)
            [updateStrTwo appendFormat:@"%@ = ?",propertyName];
        }
        //        [updateStrTwo appendFormat:@"%@ = ?",propertyName];
        
        if (i != count -1 && i != 0) {
            [updateStrTwo appendFormat:@","];
        }
        
        // 属性值数组
        NSMutableArray *propertyValue = [NSMutableArray array];
        for (NSString *property in propertyNames) {
            // 每一次遍历属性数组，通过valueForKey获取属性的值
            if (![model valueForKey:property]) {
                [model setValue:@"" forKey:property];
            }
            [propertyValue addObject:[model valueForKey:property]];
        }
    
        // 更新语句第三部分
        NSString *updateStrThree = [NSString stringWithFormat:@" where %@ = '%@';",propertyNames.firstObject, propertyValue.firstObject];
        if ([updateStrTwo hasSuffix:@","] ) {
//            [updateStrTwo deleteCharactersInRange:NSMakeRange(updateStrTwo.length - 1, 1)];
        }
        // 更新总语句
        NSString *updateStr = [NSString stringWithFormat:@"%@%@%@",updateStrOne,updateStrTwo,updateStrThree];
//        NSLog(@"-----updateStr = %@",updateStr);
        
        // 属性值数组去掉主键
        [propertyValue removeObjectAtIndex:0];
        [[SQLiteManager shareInstance].queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
            if([db executeUpdate:updateStr withArgumentsInArray:propertyValue]) {
                isSucced = YES;
            }
            else {
                isSucced = NO;
            }

        }];
    }
    return isSucced;
}
+ (BOOL)deleteDataWithModel:(id)model andWhere:(NSString *)sql {
    __block BOOL isSucced = NO;
    NSString *className = NSStringFromClass([model class]); // OC 类似：CarePeopleModel
    NSString *deleteStr = nil;
    
    deleteStr = [NSString stringWithFormat:@"delete from %@ %@;",className,sql];
    
    //    NSString *selectStr = [NSString stringWithFormat:@"select *from %@ %@",NSStringFromClass([model class]),rule];
    NSLog(@"selectStr = %@",deleteStr);
    [[SQLiteManager shareInstance].queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if (![db executeUpdate:deleteStr]) {
            //            NSLog(@"delete error");
            isSucced = NO;
        }else {
            isSucced = YES;
        }
    }];
    return isSucced;
}
+ (BOOL)deleteDataWithModel:(id)model andKeyid:(NSString *)keyid {
    __block BOOL isSucced = NO;
    NSString *className = NSStringFromClass([model class]); // OC 类似：CarePeopleModel
    NSString *deleteStr = nil;
    
    if (keyid != nil) {
        deleteStr = [NSString stringWithFormat:@"delete from %@ where keyid = '%@';",className,keyid];
    }else {
        deleteStr = [NSString stringWithFormat:@"delete from %@;",className];
    }
    //    NSString *selectStr = [NSString stringWithFormat:@"select *from %@ %@",NSStringFromClass([model class]),rule];
//    NSLog(@"selectStr = %@",deleteStr);
    [[SQLiteManager shareInstance].queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if (![db executeUpdate:deleteStr]) {
//            NSLog(@"delete error");
            isSucced = NO;
        }else {
            isSucced = YES;
        }
    }];
    return isSucced;
}

+ (NSArray *)selectDataWithModel:(id)model andRule:(NSString *)rule {
    //    NSString *modelName = NSStringFromClass([model class]);  //类似：YangGuangJiaYuan.CarePeopleModel
    //    NSString *namespace = [NSBundle mainBundle].infoDictionary[@"CFBundleExecutable"];
    //    NSString *prefixStr = [NSString stringWithFormat:@"%@.",namespace];
    //    NSString *className = [modelName stringByReplacingOccurrencesOfString:prefixStr withString:@""];
    NSString *className = NSStringFromClass([model class]); // OC 类似：CarePeopleModel
    NSString *selectStr = nil;
    if (rule != nil) {
        selectStr = [NSString stringWithFormat:@"select distinct * from %@ %@",className,rule];
    }else {
        selectStr = [NSString stringWithFormat:@"select distinct * from %@;",className];
    }
    //    NSString *selectStr = [NSString stringWithFormat:@"select *from %@ %@",NSStringFromClass([model class]),rule];
//    NSLog(@"selectStr = %@",selectStr);
    NSArray *array = [[SQLiteManager shareInstance] recorsSetWithSql:selectStr];
    return array;
}

- (void)reloadDataBase{

    
    NSString *sandBoxPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *path = [sandBoxPath stringByAppendingPathComponent:@"mydata4.db"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDirExist = [fileManager fileExistsAtPath:path];
    if (!isDirExist) {
        NSLog(@"path===>%@",path);
        self.queue = [FMDatabaseQueue databaseQueueWithPath:path];
    }else{
//        NSLog(@"存在 path===>%@",path);
        self.queue = [FMDatabaseQueue databaseQueueWithPath:path];
    }
}

/// 创建表
- (void)createTable:(NSString *)table{
    //    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"db.sql" ofType:nil];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:table ofType:nil];
    NSString *sql = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([db executeStatements:sql]) {
//            NSLog(@"创建表成功:%@",sql);
        }else{
            NSLog(@"创建表失败:%@",sql);
        }
    }];
    
}
//json字符串转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    if(err) {
        
        NSLog(@"json解析失败：%@",err);
        
        return nil;
        
    }
    return dic;
}

//字典转字符串
+ (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
