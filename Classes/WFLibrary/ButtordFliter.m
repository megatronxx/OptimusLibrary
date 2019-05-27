//
//  ButtordFliter.m
//  wfdemo
//
//  Created by mac on 2019/5/7.
//  Copyright © 2019年 mac. All rights reserved.
//

#import "ButtordFliter.h"
@implementation MyMath

/*======================================================================
 * 函数名：  pascalTriangle
 * 函数功能：计算杨辉三角的第N行的值（数组），该系列值为(x+1)^N的系数，
 *         加改进(x-1)^N的系数，最低次数在第一个
 *
 * 变量名称：
 *          N      - 杨辉三角第N行，N=0,1,...,N
 *          symbol - 运算符号，0——(x+1)^N，1——(x-1)^N
 *          vector - 返回数组，杨辉三角的第N行的值
 *
 * 返回值：  void
 *=====================================================================*/

+ (void)pascalTriangle:(int)N andSymbol:(int)symbol andReturnVector:(int *)vector
{
    vector[0] = 1;
    if(N == 0)
    {
        return;
    }
    else if (N == 1)
    {
        if(symbol == SYMBOL_ADD)
        {
            vector[1] = 1;
        }
        else
        {
            vector[0] = -1; //如果是减号，则第二项系数是-1
            vector[1] = 1;
        }
        return;
    }
    int length = N + 1; //数组长度
    int temp[length];   //定义中间变量
    
    temp[0] = 1;
    temp[1] = 1;
    
    for(int i = 2; i <= N; i++)
    {
        vector[i] = 1;
        for(int j = 1; j < i; j++)
        {
            vector[j] = temp[j - 1] + temp[j]; //x[m][n] = x[m-1][n-1] + x[m-1][n]
        }
        if(i == N) //最后一次不需要给中间变量赋值
        {
            if(symbol == SYMBOL_SUB) //运算符为减号
            {
                for(int k = 0; k < length; k++)
                {
                    vector[k] = vector[k] * pow(-1, length - 1 - k);
                }
            }
            return;
        }
        for(int j = 1; j <= i; j++)
        {
            temp[j] = vector[j];
        }
    }
}

/*======================================================================
 * 函数名：  coefficientEquation（整数）和coefficientEquation2（浮点数）
 * 函数功能：计算多项式相乘的系数，最低次数在第一个
 *
 * 变量名称：
 *          originalCoef - 原来的系数数组，计算后的系数也存储在该数组内
 *          N            - 原来数组中数据的长度，多项式最高次为N-1
 *          nextCoef     - 与原数组相乘的数组的系数（两项）
 *
 * 返回值：  void
 *=====================================================================*/

+ (void)coefficientEquation:(int *)originalCoef andOriginalN:(int)N andNextCoef:(int *)nextCoef andNextN:(int)nextN
{
    float tempCoef[N + nextN - 1];    //中间变量
    for(int i = 0; i < N + nextN - 1; i++)
    {
        tempCoef[i] = originalCoef[i]; //中间变量初始化
        originalCoef[i] = 0;
    }
    
    for(int j = 0; j < nextN; j++)
    {
        for(int i = j; i < N + nextN - 1; i++)
        {
            originalCoef[i] += tempCoef[i-j] * nextCoef[j];
        }
    }
}
+(void)coefficientEquation2:(float *)originalCoef andOriginalN:(int)N andNextCoef:(float *)nextCoef andNextN:(int)nextN
{
    float tempCoef[N + nextN - 1];    //中间变量
    for(int i = 0; i < N + nextN - 1; i++)
    {
        tempCoef[i] = originalCoef[i]; //中间变量初始化
        originalCoef[i] = 0;
    }
    
    for(int j = 0; j < nextN; j++)
    {
        for(int i = j; i < N + nextN - 1; i++)
        {
            originalCoef[i] += tempCoef[i-j] * nextCoef[j];
        }
    }
}

@end





@implementation ButtordFliter

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

+ (ButterFilterStruct)filterIIRButterLowpass:(float *)passF andStopF:(float *)stopF andPassRipple:(float)rp andStopRipple:(float)rs andFs:(float)fs andFilterType:(int)filterType
{
    ButterFilterStruct nAndFc;      //返回滤波器的阶数N和截止频率fc
    nAndFc.filterType = filterType; //滤波器类型
    float nOfN = 0.0;
    float passW = 0.0, stopW = 0.0, wa = 0.0, wc; //wa = stopW/passW或其导数
    float passF1 = 0.0, passF2 = 0.0, stopF1 = 0.0, stopF2 = 0.0, w0 = 0.0;//w0 - 中心频率
    float passW1 = 0.0, passW2 = 0.0, stopW1 = 0.0, stopW2 = 0.0, fc = 0.0;
    
    rs = fabs(rs);
    rp = fabs(rp);
    passF1 = passF[0];
    stopF1 = stopF[0];
    
    //根据滤波器类型，选择不同的预畸变换式
    switch (filterType) {
        case FILTER_IIR_BUTTER_LOW:
            if(passF1 >= stopF1)
            {
                nAndFc.isFOK = false;
                NSLog(@"错误！应满足：passF < stopF");
                return nAndFc;
            }
            
            nAndFc.isFOK = true;
            passW = tan(passF1 * M_PI / fs);    //数字低通，频率预畸，W = tan(w/2)
            stopW = tan(stopF1 * M_PI / fs);
            wa = fabs(stopW/passW);
            break;
        case FILTER_IIR_BUTTER_HIGH:
            if(passF1 <= stopF1)
            {
                nAndFc.isFOK = false;
                NSLog(@"错误！应满足：passF > stopF");
                return nAndFc;
            }
            
            nAndFc.isFOK = true;
            passW = 1/tan(passF1 * M_PI / fs); //数字高通，频率预畸，W = cot(w/2)
            stopW = 1/tan(stopF1 * M_PI / fs);
            wa = fabs(stopW/passW);
            break;
            
        case FILTER_IIR_BUTTER_PASS:
            passF2 = passF[1];
            stopF2 = stopF[1];
            if(!(stopF1 < passF1 && passF1 < passF2 && passF2 < stopF2))
            {
                nAndFc.isFOK = false;
                NSLog(@"错误！应满足：stopF[1] < passF[1] < passF[2] < stopF[2]");
                return nAndFc;
            }
            
            nAndFc.isFOK = true;
            //转换为数字频率（不进行预畸）
            passW1 = 2 * M_PI * passF1 / fs;
            passW2 = 2 * M_PI * passF2 / fs;
            stopW1 = 2 * M_PI * stopF1 / fs;
            stopW2 = 2 * M_PI * stopF2 / fs;
            
            nAndFc.cosW0 = cos((passW1 + passW2)/2)/cos((passW1 - passW2)/2); //保存cos(w0)
            w0 = acos(nAndFc.cosW0);//求带通滤波器的中心频率
            
            passW1 = (cos(w0)-cos(passW1))/sin(passW1);  //通带截止频率
            passW2 = (cos(w0)-cos(passW2))/sin(passW2);
            
            stopW1 = (cos(w0)-cos(stopW1))/sin(stopW1);
            stopW2 = (cos(w0)-cos(stopW2))/sin(stopW2);
            
            passW = MAX(passW1, passW2);                    //通带截止频率
            stopW = MIN(stopW1, stopW2);                    //阻带截止频率
            wa = fabs(stopW/passW);
            
            break;
            
        case FILTER_IIR_BUTTER_STOP:
            passF2 = passF[1];
            stopF2 = stopF[1];
            if(!(passF1 < stopF1 && stopF1 < stopF2 && stopF2 < passF2))
            {
                nAndFc.isFOK = false;
                NSLog(@"错误！应满足：passF[1] < stopF[1] < stopF[2] < passF[2]");
                return nAndFc;
            }
            
            nAndFc.isFOK = true;
            //转换为数字频率（不进行预畸）
            passW1 = 2 * M_PI * passF1 / fs;
            passW2 = 2 * M_PI * passF2 / fs;
            stopW1 = 2 * M_PI * stopF1 / fs;
            stopW2 = 2 * M_PI * stopF2 / fs;
            
            nAndFc.cosW0 = cos((stopW1 + stopW2)/2)/cos((stopW1 - stopW2)/2); //保存cos(w0)
            w0 = acos(nAndFc.cosW0);//求带通滤波器的中心频率
            
            passW1 = sin(passW1)/(cos(passW1)-nAndFc.cosW0);  //通带截止频率
            passW2 = sin(passW2)/(cos(passW2)-nAndFc.cosW0);
            
            stopW1 = sin(stopW1)/(cos(stopW1)-nAndFc.cosW0);
            stopW2 = sin(stopW2)/(cos(stopW2)-nAndFc.cosW0);
            
            passW = MAX(passW1, passW2);                    //通带截止频率
            stopW = MIN(stopW1, stopW2);                    //阻带截止频率
            
            wa = fabs(stopW/passW);
            
            break;
            
        default:
            break;
    }
    nAndFc.fs = fs; //采样频率
    nAndFc.N = ceil(0.5 * log10((pow(10, 0.1*rs)-1)/(pow(10, 0.1*rp)-1))/log10(wa)); //计算N
    
    nOfN = (float)nAndFc.N;   //将N转化为float型
    
    //根据滤波器类型，选择不同的预畸变换式
    switch (filterType) {
        case FILTER_IIR_BUTTER_LOW:
            wc = stopW / pow((pow(10, 0.1*rs) - 1), 1/(2*nOfN));
            nAndFc.fc = fs/M_PI*atan(wc);                         //计算截止频率(3dB)Hz
            
            nAndFc.length = nAndFc.N + 1; //系数数组长度
            
            break;
            
        case FILTER_IIR_BUTTER_HIGH:
            wc = stopW / pow((pow(10, 0.1*rs) - 1), 1/(2*nOfN));
            //wc = passW / pow((pow(10, 0.1*rp) - 1), 1/(2*nOfN));
            
            nAndFc.fc = fs/M_PI*atan(1/wc); //计算截止频率(3dB)Hz
            
            nAndFc.length = nAndFc.N + 1; //系数数组长度
            
            break;
            
        case FILTER_IIR_BUTTER_PASS:
            wc = stopW1 / pow((pow(10, 0.1*rs) - 1), 1/(2*nOfN));
            fc =asin((2*cos(w0)*wc + sqrt(pow(2*cos(w0)*wc, 2)-4*(wc*wc+1)*(cos(w0)*cos(w0)-1)))/(2*wc*wc+2));
            
            //            wc = passW1 / pow((pow(10, 0.1*rp) - 1), 1/(2*nOfN));
            //            fc =asin((2*cos(w0)*wc + sqrt(pow(2*cos(w0)*wc, 2)-4*(wc*wc+1)*(cos(w0)*cos(w0)-1)))/(2*wc*wc+2));
            
            nAndFc.fc = fs / (2*M_PI) * fc;
            
            nAndFc.length = 2 * nAndFc.N + 1; //系数数组长度
            
            break;
            
        case FILTER_IIR_BUTTER_STOP:
            wc = -1/(stopW1 / pow((pow(10, 0.1*rs) - 1), 1/(2*nOfN)));
            fc =asin((2*cos(w0)*wc + sqrt(pow(2*cos(w0)*wc, 2)-4*(wc*wc+1)*(cos(w0)*cos(w0)-1)))/(2*wc*wc+2));
            
            nAndFc.fc = fs / (2*M_PI) * fc;
            
            nAndFc.length = 2 * nAndFc.N + 1; //系数数组长度
            break;
        default:
            break;
    }
    
    return nAndFc;
}


//定义巴特沃斯滤波器pb系数列表（b0,b1,...,bn）
static float g_butterPb[10][10] = {{1.0,0,0,0,0,0,0,0,0,0},
    {1.0, 1.4142136, 0,0,0,0,0,0,0,0},
    {1.0, 2.0, 2.0, 0,0,0,0,0,0,0},
    {1.0, 2.6131259, 3.4142136, 2.6131259, 0,0,0,0,0,0},
    {1.0, 3.236068, 5.236068, 5.236068, 3.236068, 0,0,0,0,0},
    {1.0, 3.8637033, 7.4641016, 9.1416202, 7.4641016, 3.8637033, 0,0,0,0},
    {1.0, 4.4939592, 10.0978347, 14.5917939, 14.5917939, 10.0978347, 4.4939592, 0,0,0},
    {1.0, 5.1258309, 13.1370712, 21.8461510, 25.6883559, 21.8461510, 13.1370712, 5.1258309, 0,0},
    {1.0, 5.7587705, 16.5817187, 31.1634375, 41.9863857, 41.9863857, 31.1634375, 16.5817187, 5.7587705, 0},
    {1.0, 6.3924532, 20.4317291, 42.8020611, 64.8823963, 74.2334292, 64.8823963, 42.8020611, 20.4317291, 6.3924532}};
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
+ (void)butterSbValue:(ButterFilterStruct)butterValue andReturnSb:(float *)returnSb
{
    int length = butterValue.N;        //滤波器阶数
    float Wc = 0.0;                   //滤波器的截止频率
    
    //选择预畸方法
    switch (butterValue.filterType) {
        case FILTER_IIR_BUTTER_LOW:
            Wc = fabs(tan(butterValue.fc * M_PI / butterValue.fs));
            break;
            
        case FILTER_IIR_BUTTER_HIGH:
            Wc = fabs(1/tan(butterValue.fc * M_PI / butterValue.fs));
            break;
        case FILTER_IIR_BUTTER_PASS:
            Wc = 2 * M_PI * butterValue.fc / butterValue.fs;
            Wc = fabs((butterValue.cosW0 - cos(Wc))/sin(Wc));
            break;
        case FILTER_IIR_BUTTER_STOP:
            Wc = 2 * M_PI * butterValue.fc / butterValue.fs;
            Wc = fabs(sin(Wc)/(cos(Wc) - butterValue.cosW0));
            
            break;
        default:
            break;
    }
    
    for(int i = 0; i < length; i++)
    {
        returnSb[i] = g_butterPb[length - 1][i] * pow(Wc, length-i); //计算系数
    }
    
    returnSb[length] = 1.0; //最高次幂的系数为1
}

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
+ (void)butterLowOrHigh:(ButterFilterStruct)butterValue andSb:(float *)sb andNumerator:(float *)numerator andDenominator:(float *)denominator
{
    int length = butterValue.N;    //滤波器阶数
    
    int tempCoef1[length + 1];     //定义系数数组，用于存放1 - z^(-1)、1 + z^(-1)每项次幂（0-N）系数，最低次在第一个
    int tempCoef2[length + 1];
    int otherN;                    //1+z^(-1)的次数
    
    float Fsx2 = 1;//butterValue.fs * 2; //计算2/T
    
    for(int i = 0; i<= length; i++)
    {
        numerator[i] = 0.0;   //初始化numerator和denominator
        denominator[i] = 0.0;
    }
    
    for(int i = 0; i <= length; i++)
    {
        for(int j = 0; j<= length; j++)
        {
            tempCoef1[j] = 0;     //tempCoef1和tempCoef2进行初始化
            tempCoef2[j] = 0;
        }
        
        otherN = length - i;
        if(butterValue.filterType == FILTER_IIR_BUTTER_LOW)
        {
            [MyMath pascalTriangle:i andSymbol:SYMBOL_SUB andReturnVector:tempCoef1];      //利用杨辉三角计算1 - z^(-1)幂的系数
            [MyMath pascalTriangle:otherN andSymbol:SYMBOL_ADD andReturnVector:tempCoef2]; //利用杨辉三角计算1 + z^(-1)幂的系数
        }
        else
        {
            [MyMath pascalTriangle:i andSymbol:SYMBOL_ADD andReturnVector:tempCoef1];      //利用杨辉三角计算1 + z^(-1)幂的系数
            [MyMath pascalTriangle:otherN andSymbol:SYMBOL_SUB andReturnVector:tempCoef2]; //利用杨辉三角计算1 - z^(-1)幂的系数
        }
        
        [MyMath coefficientEquation:tempCoef1 andOriginalN:i+1 andNextCoef:tempCoef2 andNextN:otherN+1]; //两个多项式相乘，求其系数
        
        for(int j = 0; j <= length; j++)
        {
            denominator[j] += pow(Fsx2, i) * (float)tempCoef1[length - j] * sb[i];
        }
        
        //分子系数
        if(i == 0)
        {
            for(int j = 0; j <= length; j++)
            {
                numerator[j] = sb[0] * tempCoef2[length - j];
            }
        }
    }
    
    //系数归一化，分母的常数项为1
    for(int i = length; i >= 0; i--)
    {
        numerator[i] = numerator[i] / denominator[0];
        denominator[i] = denominator[i] / denominator[0];
    }
}

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
+ (void)butterPassOrStop:(ButterFilterStruct)butterValue andSb:(float *)sb andNumerator:(float *)numerator andDenominator:(float *)denominator
{
    int length = butterValue.length;      //滤波器系数长度
    
    int tempCoef1[length];                //定义系数数组，用于存放1 - z^(-2)、1 - 2*cos(w0)*z^(-1) + z^(-2)每项次幂（0-N）系数，最低次在第一个
    float tempCoef2[length];
    float tempCoef3[length], tempCoef[3];
    int otherN;                           //1+z^(-1)的次数（pass）,1 - 2*cos(w0)*z^(-1) + z^(-2)的次数（stop）
    
    float Fsx2 = 1;//butterValue.fs * 2;  //计算2/T = 1
    
    for(int i = 0; i < length; i++)
    {
        numerator[i] = 0.0;   //初始化numerator和denominator
        denominator[i] = 0.0;
        tempCoef1[i] = 0;     //tempCoef1和tempCoef2进行初始化
        tempCoef2[i] = 0.0;
        tempCoef3[i] = 0.0;
    }
    
    tempCoef[0] = 1.0;
    tempCoef[1] = -2.0 * butterValue.cosW0;
    tempCoef[2] = 1.0;
    
    //----------计算分子系数-----------
    if(butterValue.filterType == FILTER_IIR_BUTTER_PASS) //带通滤波器
    {
        [MyMath pascalTriangle:butterValue.N andSymbol:SYMBOL_SUB andReturnVector:tempCoef1];      //利用杨辉三角计算1 - z^(-1)幂的系数
        
        for(int i = 0; i < length; i++)  //变为1 - z^(-2)幂的系数，填充奇次幂0
        {
            int temp = i%2;  //判断i奇偶
            if(!temp)        //偶次幂不为0
                numerator[i] = sb[0] * tempCoef1[butterValue.N - i/2];
            else
                numerator[i] = 0.0;
        }
    }
    else //带阻滤波器
    {
        tempCoef3[0] = 1.0;                       //1 - 2*cos(w0)*z^(-1) + z^(-2)的系数1,-2cos(w0),1
        tempCoef3[1] = -2.0 * butterValue.cosW0;
        tempCoef3[2] = 1.0;
        
        for(int j = 1; j < butterValue.N; j++)
        {
            [MyMath coefficientEquation2:tempCoef3 andOriginalN:j*2+1 andNextCoef:tempCoef andNextN:3];
        }
        for(int i = 0; i < length; i++)
        {
            numerator[i] = sb[0] * tempCoef3[length - i - 1];
        }
    }
    
    //----------计算分母系数,计算每一加数的系数----------
    for(int i = 0; i <= butterValue.N; i++)
    {
        if(butterValue.filterType == FILTER_IIR_BUTTER_PASS)
        {
            otherN = butterValue.N - i;
        }
        else
        {
            otherN = i;
        }
        
        for(int j = 0; j < length; j++)
        {
            tempCoef1[j] = 0;     //tempCoef1、tempCoef2和tempCoef3进行初始化
            tempCoef2[j] = 0.0;
            tempCoef3[j] = 0.0;
        }
        tempCoef3[0] = 1.0;
        if(butterValue.N - otherN > 0) //当第0次相乘时，第一项为1，其余为0
        {
            tempCoef3[1] = -2.0 * butterValue.cosW0;
            tempCoef3[2] = 1.0;
        }
        
        [MyMath pascalTriangle:otherN andSymbol:SYMBOL_SUB andReturnVector:tempCoef1]; //利用杨辉三角计算1 - z^(-1)幂的系数
        
        for(int j = 0; j < otherN*2+1; j++)  //变为1 - z^(-2)幂的系数，填充奇次幂0
        {
            int temp = j%2;  //判断i奇偶
            if(!temp)        //偶次幂不为0
            {
                tempCoef2[j] = (float)tempCoef1[j/2];
                tempCoef1[j/2] = 0;
            }
            else
                tempCoef2[j] = 0.0;
        }
        
        //利用多项式相乘法，计算1 - 2*cos(w0)*z^(-1) + z^(-2)幂的系数,j表示第几次相乘
        for(int j = 1; j < butterValue.N - otherN; j++)
        {
            [MyMath coefficientEquation2:tempCoef3 andOriginalN:j*2+1 andNextCoef:tempCoef andNextN:3];
        }
        
        [MyMath coefficientEquation2:tempCoef3 andOriginalN:(butterValue.N - otherN)*2+1 andNextCoef:tempCoef2 andNextN:2*otherN+1]; //两个多项式相乘，求其系数
        
        for(int j = 0; j < length; j++)
        {
            denominator[j] += pow(Fsx2, i) * tempCoef3[length - j - 1] * sb[i];
        }
    }
    
    //系数归一化，分母的常数项为1
    for(int i = length - 1; i >= 0; i--)
    {
        numerator[i] = numerator[i] / denominator[0];
        denominator[i] = denominator[i] / denominator[0];
    }
}


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

+ (Boolean)filter:(ButterFilterStruct)butterValue andNumerator:(float *)numerator andDenominator:(float *)denominator andXVector:(float *)xVector andXLength:(int)length andReturnY:(float *)yVector
{
    Boolean isFilterOK = false;
    
    if(!butterValue.isFOK)
    {
        NSLog(@"系统方法错误！");
        isFilterOK = false;
        return isFilterOK;
    }
    
    if(butterValue.N > 10)
    {
        NSLog(@"失败！滤波器的阶数不能大于10。");
        isFilterOK = false;
        return isFilterOK;
    }
    
    int N = butterValue.length; //系数数组的长度
    
    //返回值初始化
    for(int i = 0; i < length; i++)
    {
        yVector[i] = 0.0; //后面循环中用到y递归算法，需要提前初始化
    }
    
    //第一层循环，计算length个y的输出值
    for(int i = 0; i < length; i++)
    {
        if(i == 0)
        {
            yVector[i] = numerator[i]*xVector[i];
        }
        else
        {
            yVector[i] = numerator[0]*xVector[i];
            //第二层循环，计算每个y的每一项
            for(int j = 1; j <= i && j < N; j++)
            {
                yVector[i] += numerator[j]*xVector[i-j] - denominator[j]*yVector[i-j];
            }
        }
        yVector[i] /= denominator[0];
    }
    
    isFilterOK = true;
    return isFilterOK;
}

-(void)testLowFliter
{
    //------------------------------------------------------------------------------------------
    // 1.低通滤波器
    //
    // 通带截止频率：passF = 2000Hz，阻带截止频率：stopF = 2500Hz，抽样频率：fs = 10000Hz
    // 通带衰减：rp = 2dB，阻带衰减：rs = 20dB
    //------------------------------------------------------------------------------------------
    
    float passF1 = 2000, stopF1 = 2500, fs1 = 10000, rp1 = 2, rs1 = 20;  //数字滤波器性能
    int length = 100;
    float xVector1[length],yVector1[length];
    for(int i = 0; i < length; i++)
    {
        xVector1[i] = sin(2*M_PI*1000*i/10000);
        xVector1[i] += sin(2*M_PI*3000*i/10000);
    }
    
    float returnSb[] = {};
    float numerator[] = {};
    float denominator[] = {};
    
    ButterFilterStruct fliter = [ButtordFliter filterIIRButterLowpass:&passF1 andStopF:&stopF1 andPassRipple:rp1 andStopRipple:rs1 andFs:fs1 andFilterType:FILTER_IIR_BUTTER_LOW];
    [ButtordFliter butterSbValue:fliter andReturnSb:returnSb];
    [ButtordFliter butterPassOrStop:fliter andSb:returnSb andNumerator:numerator andDenominator:denominator];
    [ButtordFliter filter:fliter andNumerator:numerator andDenominator:denominator andXVector:xVector1 andXLength:length andReturnY:yVector1];
    
    for(int i = 0; i < length; i++)
    {
        float value = yVector1[i];
        printf("%f",value);
        printf(" ");
    }
}

-(void)testHeightFliter
{
    //------------------------------------------------------------------------------------------
    // 2.高通滤波器
    //
    // 通带截止频率：passF = 3000Hz，阻带截止频率：stopF = 2800Hz，抽样频率：fs = 10000Hz
    // 通带衰减：rp = 3dB，阻带衰减：rs = 10dB
    //------------------------------------------------------------------------------------------
    
    float passF2 = 3000, stopF2 = 2800, fs2 = 10000, rp2 = 3, rs2 = 10;  //数字滤波器性能
    int length = 100;
    float xVector2[length],yVector2[length];
    for(int i = 0; i < length; i++)
    {
        xVector2[i] = sin(2*M_PI*1000*i/1230);
        xVector2[i] += sin(2*M_PI*4000*i/1230);
    }
    
    
    float returnSb[] = {};
    float numerator[] = {};
    float denominator[] = {};
    
    ButterFilterStruct fliter = [ButtordFliter filterIIRButterLowpass:&passF2 andStopF:&stopF2 andPassRipple:rp2 andStopRipple:rs2 andFs:fs2 andFilterType:FILTER_IIR_BUTTER_HIGH];
    [ButtordFliter butterSbValue:fliter andReturnSb:returnSb];
    [ButtordFliter butterPassOrStop:fliter andSb:returnSb andNumerator:numerator andDenominator:denominator];
    [ButtordFliter filter:fliter andNumerator:numerator andDenominator:denominator andXVector:xVector2 andXLength:length andReturnY:yVector2];
    
    for(int i = 0; i < length; i++)
    {
        float value = yVector2[i];
        printf("%f",value);
        printf(" ");
    }
}

-(void)testPassFliter
{
    //------------------------------------------------------------------------------------------
    // 3.带通滤波器
    //
    // 通带截止频率：passF = [15000 40000]Hz，阻带截止频率：stopF = [10000 48000]Hz，抽样频率：fs = 100000Hz
    // 通带衰减：rp = 2dB，阻带衰减：rs = 30dB
    //------------------------------------------------------------------------------------------
    
    float passF3[2] = {15000.0, 40000.0}, stopF3[2] = {10000.0, 48000.0}, fs3 = 100000, rp3 = 2, rs3 = 30;    //数字滤波器性能
    //float passF3[2] = {20000.0, 30000.0}, stopF3[2] = {10000.0, 45000.0}, fs3 = 100000, rp3 = 2, rs3 = 20;  //数字滤波器性能
    int length = 100;
    float xVector3[length],yVector3[length];
    
    for(int i = 0; i < length; i++)
    {
        xVector3[i] = sin(2 * M_PI * 10000 * i / 12300);
        xVector3[i] += sin(2 * M_PI * 30000 * i / 12300);
    }
    
    ButterFilterStruct fliter = [ButtordFliter filterIIRButterLowpass:passF3 andStopF:stopF3 andPassRipple:rp3 andStopRipple:rs3 andFs:fs3 andFilterType:FILTER_IIR_BUTTER_PASS];
    float returnSb[fliter.N];
    float numerator[fliter.length];
    float denominator[fliter.length];
    [ButtordFliter butterSbValue:fliter andReturnSb:returnSb];
    [ButtordFliter butterPassOrStop:fliter andSb:returnSb andNumerator:numerator andDenominator:denominator];
    [ButtordFliter filter:fliter andNumerator:numerator andDenominator:denominator andXVector:xVector3 andXLength:length andReturnY:yVector3];
    
    for(int i = 0; i < length; i++)
    {
        float value = yVector3[i];
        printf("%f",value);
        printf(" ");
    }
}
-(void)testStopFliter
{
    //------------------------------------------------------------------------------------------
    // 4.带阻滤波器
    //
    // 通带截止频率：passF = [10000 45000]Hz，阻带截止频率：stopF = [20000 30000]Hz，抽样频率：fs = 100000Hz
    // 通带衰减：rp = 1dB，阻带衰减：rs = 20dB
    //------------------------------------------------------------------------------------------
    
    float passF4[2] = {10000.0, 45000.0}, stopF4[2] = {20000.0, 30000.0}, fs4 = 100000, rp4 = 1, rs4 = 20;  //数字滤波器性能
    int length = 100;
    float xVector4[length],yVector4[length];
    for(int i = 0; i < length; i++)
    {
        xVector4[i] = sin(2*M_PI*10000*i/12300);
        xVector4[i] += sin(2*M_PI*25000*i/12300);
    }
    
    float returnSb[] = {};
    float numerator[] = {};
    float denominator[] = {};
    
    ButterFilterStruct fliter = [ButtordFliter filterIIRButterLowpass:passF4 andStopF:stopF4 andPassRipple:rp4 andStopRipple:rs4 andFs:fs4 andFilterType:FILTER_IIR_BUTTER_STOP];
    [ButtordFliter butterSbValue:fliter andReturnSb:returnSb];
    [ButtordFliter butterPassOrStop:fliter andSb:returnSb andNumerator:numerator andDenominator:denominator];
    [ButtordFliter filter:fliter andNumerator:numerator andDenominator:denominator andXVector:xVector4 andXLength:length andReturnY:yVector4];
    
    for(int i = 0; i < length; i++)
    {
        float value = yVector4[i];
        printf("%f",value);
        printf(" ");
    }
}
@end
