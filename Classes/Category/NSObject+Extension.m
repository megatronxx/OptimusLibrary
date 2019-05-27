//
//  NSObject+Extension.m
//  BocoVideoPlatform
//
//  Created by mac on 2017/12/20.
//  Copyright © 2017年 BOCO. All rights reserved.
//

#import "NSObject+Extension.h"
#import <objc/runtime.h>
#import "Library.h"
@implementation NSObject (Extension)
-(NSArray *)allProperty
{
    NSMutableArray *props = [NSMutableArray new];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [[NSString alloc] initWithFormat:@"%s",property_getName(property)];
        [props addObject:propertyName];
    }
    free(properties);
    return props;
}
///lkdhelper 保存（如果存在则更新，否则插入）
-(void)ldkdb_save
{
    NSString *pkey =  [self.class performSelector:@selector(getPrimaryKey)];
    NSString *pvalue = [self valueForKey:pkey];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ = '%@';",NSStringFromClass(self.class),pkey,pvalue];
    //    NSLog(@"检查数据库数据：\n%@",sql);
//    NSArray *resr = [self.class searchWithSQL:sql];
    NSArray *resr = [self.class performSelector:@selector(searchWithSQL:) withObject:sql];
    if (resr.count > 0) {
        NSString *updateSql = [NSString stringWithFormat:@"%@ = '%@'",pkey,pvalue];
        //        NSLog(@"更新数据：\n%@",updateSql);
//        [self.class updateToDB:self where:updateSql];
        [self.class performSelector:@selector(updateToDB:where:) withObject:self withObject:updateSql];
    }else{
        //        NSLog(@"插入数据");
//        [self.class insertToDB:self];
        [self.class performSelector:@selector(insertToDB:) withObject:self];
    }
}
///查询数据库所有
-(NSArray *)ldkdb_queryAll
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@;",NSStringFromClass(self.class)];
    //    NSLog(@"检查数据库数据：\n%@",sql);
//    NSArray *resr = [self.class searchWithSQL:sql];
    NSArray *resr = [self.class performSelector:@selector(searchWithSQL:) withObject:sql];
    return resr;
}
///根据主键查询数据库
-(NSArray *)ldkdb_query:(NSString *)keyValue
{
//    NSString *pkey =  [self.class getPrimaryKey];
    NSString *pkey =  [self.class performSelector:@selector(getPrimaryKey)];
    NSString *pvalue = keyValue;
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ = '%@';",NSStringFromClass(self.class),pkey,pvalue];
    //    NSLog(@"检查数据库数据：\n%@",sql);
//    NSArray *resr = [self.class searchWithSQL:sql];
    NSArray *resr = [self.class performSelector:@selector(searchWithSQL:) withObject:sql];
    return resr;
}
///根据键值对查询数据
-(NSArray *)ldkdb_query:(NSString *)key value:(NSString *)value
{
    NSString *pkey =  key;
    NSString *pvalue = value;
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ = '%@';",NSStringFromClass(self.class),pkey,pvalue];
    //    NSLog(@"检查数据库数据：\n%@",sql);
//    NSArray *resr = [self.class searchWithSQL:sql];
    NSArray *resr = [self.class performSelector:@selector(searchWithSQL:) withObject:sql];
    return resr;
}
@end
