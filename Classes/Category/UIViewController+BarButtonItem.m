//
//  UIViewController+BarButtonItem.m
//  BocoWowManager
//
//  Created by boco on 16/6/2.
//  Copyright © 2016年 Boco. All rights reserved.
//

#import "UIViewController+BarButtonItem.h"

@implementation UIViewController (BarButtonItem)

/**
 * 文字居右
 */
- (UIBarButtonItem *)barButtonItemWithTitle:(NSString *)title andAction:(SEL)action
{
    UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonItem.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [buttonItem setTitle:title forState:UIControlStateNormal];
    [buttonItem addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonItem sizeToFit];
    buttonItem.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItem];
    return barItem;
}

/**
 * 文字居左
 */
- (UIBarButtonItem *)leftBarButtonItemWithTitle:(NSString *)title andAction:(SEL)action
{
    UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeSystem];
    [buttonItem setTitle:title forState:UIControlStateNormal];
    [buttonItem addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonItem sizeToFit];
    buttonItem.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    buttonItem.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItem];
    return barItem;
}

- (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image
                             highlightImage:(UIImage *)highlightImage
                                  andAction:(SEL)action
{
    UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonItem setImage:image forState:UIControlStateNormal];
    [buttonItem setImage:highlightImage forState:UIControlStateSelected];
    [buttonItem sizeToFit];
    [buttonItem addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItem];
    return barItem;
}

/**
 * title
 */
- (UIButton *)titleButtonWithTitle:(NSString *)title andAction:(SEL)action
{
    UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeSystem];
    [buttonItem setTitle:title forState:UIControlStateNormal];
    [buttonItem addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [buttonItem sizeToFit];
    buttonItem.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    return buttonItem;
}

- (void)setTitleAsDefault
{
    self.navigationController.navigationBar.titleTextAttributes = @{
        NSForegroundColorAttributeName : [UIColor whiteColor],
        NSFontAttributeName : [UIFont boldSystemFontOfSize:16]
    };
}

@end
