//
//  QRCodeView.m
//  ZGHMS
//
//  Created by HaiLai on 15/12/17.
//  Copyright © 2015年 海莱. All rights reserved.
//

#import "QRCodeView.h"
#import <objc/runtime.h>
#import <AVFoundation/AVFoundation.h>
///带navigationbar View 的高度
#define WF_UI_VIEW_HEIGHT ([[UIScreen mainScreen]bounds].size.height-64)
///不带navigationbar View 的高度
#define WF_SCREEN_WIDTH [[UIScreen mainScreen]bounds].size.width
static NSString *QRCodeKey;

@interface QRCodeView ()<AVCaptureMetadataOutputObjectsDelegate>
{
    ///计数
    CGFloat num;
    ///可否滚动
    BOOL upOrdown;
}
///计时器
@property (nonatomic,strong) NSTimer *timer;
///滚动的线条
@property (nonatomic,strong) UIImageView *scanLine;
///设备
@property (nonatomic,strong) AVCaptureDevice *device;
///输入
@property (nonatomic,strong) AVCaptureDeviceInput *input;
///输出
@property (nonatomic,strong) AVCaptureMetadataOutput *output;
///对话
@property (nonatomic,strong) AVCaptureSession *session;
///扫码区域
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *preview;
@end

@implementation QRCodeView
@synthesize timer,scanLine,device,input,output,session,preview;
#pragma mark - 事件

#pragma mark - 方法
-(void)initilization
{

    
    session = [[AVCaptureSession alloc]init];
    session.sessionPreset = AVCaptureSessionPresetHigh;
    
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        NSError *err;
        //扫码输入
        input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&err];
        if (!err) {
            [session addInput:input];
            
            //扫码输出
            output = [[AVCaptureMetadataOutput alloc]init];
            [session addOutput:output];
            [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
            NSLog(@"支持的扫描类型：%@",output.availableMetadataObjectTypes);
            output.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeQRCode];
            output.rectOfInterest = CGRectMake((WF_UI_VIEW_HEIGHT / 2 - 110) / WF_UI_VIEW_HEIGHT,(WF_SCREEN_WIDTH / 2 - 110) / WF_SCREEN_WIDTH,220/WF_UI_VIEW_HEIGHT,220/WF_SCREEN_WIDTH);
        

            //扫码场景
            preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
            preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
            preview.frame = [[UIScreen mainScreen]bounds];
            [self.layer addSublayer:preview];
            //背景
            UIImageView *containIV = [[UIImageView alloc]init];
            CGRect rect = CGRectMake(WF_SCREEN_WIDTH / 2 - 110,WF_UI_VIEW_HEIGHT / 2 - 110,220,220);
            containIV.frame = rect;
            containIV.image = [UIImage imageNamed:@"pick_bg"];
            [self addSubview:containIV];
            
            //扫描线
            scanLine = [[UIImageView alloc]initWithFrame:CGRectMake(WF_SCREEN_WIDTH / 2 - 110,WF_UI_VIEW_HEIGHT / 2 - 110,220,2)];
            scanLine.image = [UIImage imageNamed:@"line"];
            [self addSubview:scanLine];
            //定时器
            timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(animate) userInfo:nil repeats:YES];

        }else{
            NSLog(@"创建输入出错：%@",err);
            NSError *err = [NSError errorWithDomain:@"扫码出错" code:1024 userInfo:nil];
            QRScanHandler handler = objc_getAssociatedObject(self, &QRCodeKey);
            handler(nil,err);
            [session stopRunning];
        }
    }
}
-(void)animate
{
    if (upOrdown){
        num = num + 1.0f;
        CGFloat move = num * 2;
        scanLine.frame = CGRectMake(WF_SCREEN_WIDTH / 2 - 110, WF_UI_VIEW_HEIGHT / 2 - 110 + move, 220, 2);
        if (2*num >= 220.0f) {
            upOrdown = NO;
        }
    }else{
        num = num - 1.0f;
        CGFloat move = num * 2;
        scanLine.frame = CGRectMake(WF_SCREEN_WIDTH / 2 - 110, WF_UI_VIEW_HEIGHT / 2 - 110 + move, 220, 2);
        if (num <= 0.0f) {
            upOrdown = YES;
        }
    }
}
-(instancetype)initWithHandler:(QRScanHandler)handler
{
    if (self = [super init]) {
        objc_removeAssociatedObjects(self);
        objc_setAssociatedObject(self, &QRCodeKey, handler, OBJC_ASSOCIATION_COPY);
        [self initilization];
    }
    return self;
}
-(void)startScan
{
    if (session != nil) {
        [session startRunning];
    }
}
-(void)reStart
{
    [timer invalidate];
    [session stopRunning];
    [session removeInput:input];
   // [output setMetadataObjectsDelegate:nil queue:nil];
    
    [self initilization];
    [self startScan];
}
#pragma mark - 生命周期
-(void)dealloc
{
    [timer invalidate];
    [session stopRunning];
    [preview removeFromSuperlayer];
    [output setMetadataObjectsDelegate:nil queue:nil];
}
#pragma mark - delegate
#pragma mark - acputure out put delegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *val;
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = (AVMetadataMachineReadableCodeObject *)metadataObjects[0];
        val = [obj stringValue];
        
        NSDictionary *dic = @{@"QRCodeContent":val};
        QRScanHandler handler = objc_getAssociatedObject(self, &QRCodeKey);
        handler(dic,nil);
        [session stopRunning];
    }
}
@end
