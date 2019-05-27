//
//  UIFont+Scale.h
//  ZGHMS
//
//  Created by HaiLai on 15/11/18.
//  Copyright © 2015年 海莱. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Scale)
+(UIFont *)systemFontOfSize:(CGFloat)fontSize withScale:(CGFloat)scale;
+(UIFont*)boldSystemFontOfSize:(CGFloat)fontSize withScale:(CGFloat)scale;
+(UIFont *)nameFont:(NSString *)name size:(CGFloat)fontSize withScale:(CGFloat)scale;

/**
 *  改变行间距
 */
+ (void)changeLineSpaceForLabel:(UILabel *)label WithSpace:(float)space;

/**
 *  改变字间距
 */
+ (void)changeWordSpaceForLabel:(UILabel *)label WithSpace:(float)space;

/**
 *  改变行间距和字间距
 */
+ (void)changeSpaceForLabel:(UILabel *)label withLineSpace:(float)lineSpace WordSpace:(float)wordSpace;
@end
