//
//  WFHeartBits.h
//  HeartBits
//
//  Created by mac on 2019/5/5.
//  Copyright © 2019年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class HeartLive;
NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    HBCheack_UnCover,
    HBCheack_UnStable,
    HBCheack_Testing,
} HBCheack_Status;

@protocol HeartBeatPluginDelegate <NSObject>
- (void)startHeartDelegateRatePoint:(NSDictionary *)point;
@optional
- (void)startHeartDelegateRateError:(NSError *)error;
- (void)startHeartDelegateRateFrequency:(NSInteger)frequency;
@end


@interface WFHeartBits : NSObject
@property (copy, nonatomic) void ((^backPoint)(NSDictionary *));
@property (copy, nonatomic) void ((^frequency)(NSInteger ));
@property (copy, nonatomic) void ((^Error)(NSError *));
@property (assign, nonatomic) id <HeartBeatPluginDelegate> delegate;
@property (nonatomic,strong) CALayer* imageLayer;
// 输出的所有点
@property (strong, nonatomic) NSMutableArray            *points;
@property (strong, nonatomic) NSMutableArray            *pointDatas;
@property (nonatomic,weak) HeartLive *live;

/**
 *  单例
 */
+ (instancetype)shareManager;



- (void)start;

/**
 *  调用摄像头测心率方法
 *
 *  @param backPoint 浮点和时间戳的 实时回调
 *                 * 数据类型   字典
 *                 * 数据格式   {  "1473386373135.52" = "0.3798618"; }
 *                      * 字典Key:     NSNumber类型double浮点数->时间戳  小数点前精确到毫秒
 *                      * 字典Value:   NSNumber类型float浮点数，数据未处理全部返回
 *  @param frequency 返回心率
 *  @param error     错误信息
 */
- (void)startHeartRatePoint:(void(^)(NSDictionary *point))backPoint
                  Frequency:(void(^)(NSInteger fre))frequency
                      Error:(void(^)(NSError *error))error;

/**
 *  结束方法
 */
- (void)stop;
@end


/*
 
 //创建了一个心电图的View
 self.live = [[HeartLive alloc]initWithFrame:CGRectMake(10, 100, self.view.frame.size.width-20, 150)];
 [self.view addSubview:self.live];
 
 - (void)startHeartDelegateRatePoint:(NSDictionary *)point {
 NSNumber *n = [[point allValues] firstObject];
 //拿到的数据传给心电图View
 [self.live drawRateWithPoint:n];
 }
 */

@interface HeartLive : UIView

- (void)drawRateWithPoint:(NSNumber *)point;

@end

NS_ASSUME_NONNULL_END
