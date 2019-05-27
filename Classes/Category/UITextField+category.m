//
//  UITextField+category.m
//  wfdemo
//
//  Created by mac on 2019/2/19.
//  Copyright © 2019年 mac. All rights reserved.
//

#import "UITextField+category.h"
#import <objc/runtime.h>
const NSString *editHandlerKey;
@implementation UITextField (category)
-(void)didEdit:(void (^)(NSString *text))handler
{
    if (handler) {
        objc_removeAssociatedObjects(self);
        objc_setAssociatedObject(self, &editHandlerKey, handler, OBJC_ASSOCIATION_COPY);
    }
    [self addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
}
- (void)textFieldEditChanged:(UITextField*)textField
{
    NSLog(@"textfield text %@",textField.text);
    void (^handler)(NSString *text) = objc_getAssociatedObject(self, &editHandlerKey);
    if (handler) {
        handler(textField.text);
    }
}
@end
