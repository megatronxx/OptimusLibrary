//
//  NSObject+Extension.h
//  BocoVideoPlatform
//
//  Created by mac on 2017/12/20.
//  Copyright © 2017年 BOCO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Extension)
-(NSArray *)allProperty;

///lkdhelper 保存（如果存在则更新，否则插入）
-(void)ldkdb_save;
///查询数据库所有
-(NSArray *)ldkdb_queryAll;
///根据主键查询数据库
-(NSArray *)ldkdb_query:(NSString *)keyValue;
///根据键值对查询数据
-(NSArray *)ldkdb_query:(NSString *)key value:(NSString *)value;
@end
