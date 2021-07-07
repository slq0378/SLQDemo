//
//  SQLiteManager
//
//
//  Created by song on 2021/5/13.
//  Copyright © 2021 song. All rights reserved.

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface SQLiteManager : NSObject
@property (nonatomic,strong) FMDatabaseQueue *queue;

+ (instancetype)shareInstance;
- (void)reloadDataBase;

#pragma mark - ///////////////////////////JSON///////////////////////////
/**
 *  将model转化为JSONString
 *
 *  @param model 要转化的model
 *  @param propertyNameArr    需要去除的属性值名称数组
 *
 *  @return 指定格式的JSONString
 */
+ (NSString *)transferToJSONWithModel:(id)model withoutPropertyNameArr:(NSArray *)propertyNameArr;

/**
 *  将model转化为JSONString
 *
 *  @param model           model
 *  @param replaceDict     要替换的属性键值对,对应key替换value
 *  @param propertyNameArr 需要去除的属性值名称数组
 *
 *  @return json
 */
+ (NSString *)transferToJSONWithModelValue:(id)model andReplaceDict:(NSDictionary *)replaceDict withoutPropertyNameArr:(NSArray *)propertyNameArr;

/**
 *  模型转json
 *
 *  @param model model
 *
 *  @return json str
 */
+ (NSString *)transferToJSONWithModel:(id)model;

/**
 *  将model转化为JSONString
 *
 *  @param model 要转化的model
 *  @param propertyNameArr    需要去除的属性值名称数组
 *  @param replacedPropertyNameDict 根据接口需要替换的预留字段,替换key
 *  @return 指定格式的JSONString
 */
+ (NSString *)transferToJSONWithModelKey:(id)model withoutPropertyNameArr:(NSArray *)propertyNameArr withReplacedPropertyNameDict:(NSDictionary *)replacedPropertyNameDict;


#pragma mark - ///////////////////////////SQLite///////////////////////////
/**
 创建表
 
 @param table 文件名
 @return  是否成功
 */
- (BOOL)createTableWithFileName:(NSString *)table;
/**
 创建表

 @param table 文件名
 @return  是否成功
 */
+ (BOOL)createTableWithFileName:(NSString *)table;
/**
 创建表

 @param sql sql语句
 @return 是否成功
 */
+ (BOOL)createTableWithSql:(NSString *)sql;

- (void)createTable:(NSString *)table;

/// 查询
- (NSArray *)recorsSetWithSql:(NSString *)sql;
/**
 记录是否存在

 @param model 模型

 @return 结果bool
 */
+ (BOOL)isExistModel:(id)model;

/**
 *  插入或者更新数据库，根据主键id自动判断
 *
 *  @param model model description
 */
+ (BOOL)insertOrUpdateDataWithModel:(id)model;
/**
 插入或者更新数据库

 @param models 模型数组

 */
+ (BOOL)insertDataWithModels:(NSArray *)models;
/**
 *  插入或者更新数据库，根据主键id自动判断
 *
 *  @param model model description
 */
+ (BOOL)insertDataWithModel:(id)model;

/**
 *  更新数据库
 *
 *  @param model model
 */
+ (BOOL)updateDataWithModel:(id)model;

// 按照条件删除记录
+ (BOOL)deleteDataWithModel:(id)model andWhere:(NSString *)sql;
/**
 *  删除数据库记录，目前所有数据库的主键名称一致都是keyid
 *
 *  @param model 模型
 *  @param keyid 主键
 */
+ (BOOL)deleteDataWithModel:(id)model andKeyid:(NSString*)keyid;

/**
 *  选择数据，结果字典数组
 *
 *  @param model model 即表名
 *  @param rule  条件
 *
 *  @return 结果字典数组
 */
+ (NSArray *)selectDataWithModel:(id)model andRule:(NSString *)rule;
/**
 判断表中是否存在某个字段，先判断表是否存在，再判断字段是否存在，不存就新增字段
 
 @param col 字段名称，默认text类型
 @param table 表名称
 */
+ (void)addColum:(NSString *)col toTable:(NSString *)table;
//json字符串转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
//字典转字符串
+ (NSString*)dictionaryToJson:(NSDictionary *)dic;
@end
