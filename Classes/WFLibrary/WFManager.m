//
//  WFManager.m
//  CBHMobile
//
//  Created by mac on 2017/11/13.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "WFManager.h"

@implementation WFManager
@synthesize registInfo,systemInitInfo,loginInfo;

+(WFManager *)shareManager
{
    static WFManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[WFManager alloc]init];
        }
    });
    return manager;
}

-(NSString *)loginToken
{
    NSString *token = [self.loginInfo objectForKey:@"token"] ?: @"";
    return token;
}
-(NSString *)loginId
{
    NSString *idd = [self.loginInfo objectForKey:@"id"] ?: @"";
    return idd;
}

-(void)clean
{
    if (self) {
        [registInfo removeAllObjects];
        registInfo = nil;
        [self cleanInit];
    }
}
-(void)cleanInit
{
    [systemInitInfo removeAllObjects];
    systemInitInfo = nil;
    [self cleanLogin];
}
-(void)cleanLogin
{
    [loginInfo removeAllObjects];
    loginInfo = nil;
}
-(void)cleanRegist
{
    [registInfo removeAllObjects];
    registInfo = nil;
}
@end
