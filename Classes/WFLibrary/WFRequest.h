//
//  WFRequest.h
//  FrameWorkDemo
//
//  Created by 海莱 on 15/10/8.
//  Copyright (c) 2015年 海莱. All rights reserved.
//

#pragma mark - 网络交互的核心
#import <Foundation/Foundation.h>

///user agent
#define kUserAgent      @"UserAgent"

typedef enum : NSUInteger {
    WFRequestCacheTypeNone,
    WFRequestCacheTypeOffLineShow,
    WFRequestCachePriorShow,
} WFRequestCacheType_t;

typedef void(^requestHandler)(NSDictionary *info);

@interface WFRequest : NSObject
@property(nonatomic,assign)BOOL isStopNetWorkActive;//是否禁止状态栏的网络菊花
@property (nonatomic,assign) WFRequestCacheType_t cacheType;
///正常
- (void)requestWithURL:(NSString *)url callBack:(requestHandler)handler parameter:(NSMutableDictionary *)paramters;
///多媒体
- (void)requestWithAudioURL:(NSString *)url callBack:(requestHandler)handler parameter:(NSMutableDictionary *)paramters;
//手动关闭连接
- (void)closeConnect;
@end
