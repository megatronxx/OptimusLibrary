//
//  QRCodeView.h
//  ZGHMS
//
//  Created by HaiLai on 15/12/17.
//  Copyright © 2015年 海莱. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^QRScanHandler)(NSDictionary *info,NSError *err);

@interface QRCodeView : UIView

@property(nonatomic,strong)UITextField* myTF;
-(instancetype)initWithHandler:(QRScanHandler)handler;
-(void)startScan;
-(void)reStart;
@end
