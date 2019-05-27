/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import <UIKit/UIKit.h>
typedef void(^ChooseImageHandler)(UIImage *img,NSError *err);
typedef void(^ChooseVideoHandler)(UIImage *img,NSURL *videoUrl,NSError *err);
@interface UIViewController (HUD)<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

///导航条下的小提示
-(void)showNavgationTip:(NSString *)tip;
-(void)showNavgationTip:(NSString *)tip isWait:(BOOL)iswait;

//改变导航条颜色
- (void)changeNavigationBarWithColor:(UIColor *)color;

-(void)chooseImageWithHandler:(ChooseImageHandler)handler;
-(void)chooseVideoWithHandler:(ChooseVideoHandler)handler;
@end
