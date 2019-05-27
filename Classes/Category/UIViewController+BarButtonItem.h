//
//  UIViewController+BarButtonItem.h
//  BocoWowManager
//
//  Created by boco on 16/6/2.
//  Copyright © 2016年 Boco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (BarButtonItem)

- (UIBarButtonItem *)barButtonItemWithTitle:(NSString *)title andAction:(SEL)action;
- (UIBarButtonItem *)leftBarButtonItemWithTitle:(NSString *)title andAction:(SEL)action;
- (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image
                             highlightImage:(UIImage *)highlightImage
                                  andAction:(SEL)action;
- (UIButton *)titleButtonWithTitle:(NSString *)title andAction:(SEL)action;
- (void)setTitleAsDefault;
@end
