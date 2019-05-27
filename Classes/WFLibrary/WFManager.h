//
//  WFManager.h
//  CBHMobile
//
//  Created by mac on 2017/11/13.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WFManager : NSObject
@property (nonatomic,strong) NSMutableDictionary *registInfo;
@property (nonatomic,strong) NSMutableDictionary *systemInitInfo;
@property (nonatomic,strong) NSMutableDictionary *loginInfo;


+(WFManager *)shareManager;

-(NSString *)loginToken;
-(NSString *)loginId;

-(void)clean;
-(void)cleanInit;
-(void)cleanLogin;
-(void)cleanRegist;
@end
