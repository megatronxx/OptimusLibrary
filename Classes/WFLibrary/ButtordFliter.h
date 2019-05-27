//
//  ButtordFliter.h
//  wfdemo
//
//  Created by mac on 2019/5/7.
//  Copyright © 2019年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//巴特沃斯滤波器参数
typedef struct
{
    int N;          //巴特沃斯滤波器阶数
    int length;     //滤波器系统函数系数数组的长度
    float fc;       //巴特沃斯滤波器截止频率
    float cosW0;    //中心频率，带通带阻时用到
    float fs;       //采样频率
    int filterType; //需要设计的数字滤波器类型
    Boolean isFOK;
}ButterFilterStruct;

typedef enum : NSUInteger {
    FILTER_IIR_BUTTER_LOW,
    FILTER_IIR_BUTTER_HIGH,
    FILTER_IIR_BUTTER_PASS,
    FILTER_IIR_BUTTER_STOP
} FILTER_IIR_BUTTER_TYPE;

typedef enum : NSUInteger {
    SYMBOL_ADD,
    SYMBOL_SUB
} SYMBOL_TYPE;

@interface MyMath : NSObject
+ (void)pascalTriangle:(int)N andSymbol:(int)symbol andReturnVector:(int *)vector;
+ (void)coefficientEquation:(int *)originalCoef andOriginalN:(int)N andNextCoef:(int *)nextCoef andNextN:(int)nextN;
+ (void)coefficientEquation2:(float *)originalCoef andOriginalN:(int)N andNextCoef:(float *)nextCoef andNextN:(int)nextN;
@end

@interface ButtordFliter : NSObject
/*======================================================================
 * 方法名：  filterIIRButterLowpass
 * 方法功能：设计巴特沃斯样本低通示波器
 *
 * 变量名称：
 *          fpass - 通带截止频率（模拟频率）
 *          fstop - 阻带截止频率（模拟频率）
 *          rp    - 通带最大衰减（dB）
 *          rs    - 阻带最小衰减（dB）
 *          Fs    - 采样频率
 *
 * 返回值：  返回巴特沃斯低通滤波器的阶数N和截止频率Ws结构体
 *=====================================================================*/
+ (ButterFilterStruct)filterIIRButterLowpass:(float *)passF andStopF:(float *)stopF andPassRipple:(float)rp andStopRipple:(float)rs andFs:(float)fs andFilterType:(int)filterType;

/*======================================================================
 * 方法名：  butterSbValue
 * 方法功能：计算巴特沃斯滤波器分母多项式H(s)的系数Sb，注意：分子为Wc^N
 * 说明：   Sb[k] = Wc^(N-k) * Pb，其中Pb是归一化的分母多项式的根，可查表得到
 *         系数由低次向高次排列
 *
 * 变量名称：
 *          butterValue   - 存放滤波器参数（阶数和截止频率）的结构体变量
 *          returnSb      - 计算结果
 *
 * 返回值：  void
 *=====================================================================*/
+ (void)butterSbValue:(ButterFilterStruct)butterValue andReturnSb:(float *)returnSb;


/*======================================================================
 * 方法名：  butterLowOrHigh
 * 方法功能：计算巴特沃斯低通（高通）滤波器系统方法的系数，包括分子和分母系数
 *
 * 变量名称：
 *          butterValue   - 存放滤波器参数（阶数和截止频率）的结构体变量
 *          sb            - 传入的模拟滤波器的系数，即H(s)的分母系数
 *          numerator     - 计算后的分子系数数组
 *          denominator   - 计算后的分母系数数组
 *
 * 返回值：  void
 *=====================================================================*/
+ (void)butterLowOrHigh:(ButterFilterStruct)butterValue andSb:(float *)sb andNumerator:(float *)numerator andDenominator:(float *)denominator;

/*======================================================================
 * 方法名：  butterPassOrStop
 * 方法功能：计算巴特沃斯带通（带阻）滤波器系统方法的系数，包括分子和分母系数
 *
 * 变量名称：
 *          butterValue   - 存放滤波器参数（阶数和截止频率）的结构体变量
 *          sb            - 传入的模拟滤波器的系数，即H(s)的分母系数
 *          numerator     - 计算后的分子系数数组
 *          denominator   - 计算后的分母系数数组
 *
 * 返回值：  void
 *=====================================================================*/
+ (void)butterPassOrStop:(ButterFilterStruct)butterValue andSb:(float *)sb andNumerator:(float *)numerator andDenominator:(float *)denominator;


/*======================================================================
 * 方法名：  filter
 * 方法功能：根据数字滤波器系统方法（系数），对原始信号进行滤波
 *
 * 变量名称：
 *          butterValue   - 存放滤波器参数（阶数和截止频率）的结构体变量
 *          numerator     - 系统方法，分子系数数组
 *          denominator   - 系统方法，分母系数数组
 *          xVector       - 输入的原始信号（数组）
 *          length        - 原始信号的长度，也是滤波后信号的长度
 *          yVector       - 滤波后的信号（数组）
 *
 * 返回值：  设计是否成功，true-成功，false-失败
 *=====================================================================*/
+ (Boolean)filter:(ButterFilterStruct)butterValue andNumerator:(float *)numerator andDenominator:(float *)denominator andXVector:(float *)xVector andXLength:(int)length andReturnY:(float *)yVector;

///测试低通滤波器
-(void)testLowFliter;
///测试高通滤波器
-(void)testHeightFliter;
///测试带通滤波器
-(void)testPassFliter;
///测试带阻滤波器
-(void)testStopFliter;
@end

NS_ASSUME_NONNULL_END
