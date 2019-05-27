//
//  UIButton+Block.h
//  ZGHMS
//
//  Created by HaiLai on 15/11/19.
//  Copyright © 2015年 海莱. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
typedef void (^ActionBlock)(void);
@interface UIButton (Block)
@property (readonly) NSMutableDictionary *event;
- (void) handleControlEvent:(UIControlEvents)controlEvent withBlock:(ActionBlock)action;
- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

///是否可点击
- (void)cannotClick;
- (void)canClick;

///扩大点击相应区域
- (void)setEnlargeEdgeWithTop:(CGFloat) top right:(CGFloat) right bottom:(CGFloat) bottom left:(CGFloat) left;
- (void)setEnlargeEdge:(CGFloat) size;
@end
