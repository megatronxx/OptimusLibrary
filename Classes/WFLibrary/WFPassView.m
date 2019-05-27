//
//  WFPassView.m
//  UVTao
//
//  Created by mac on 2018/9/26.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "WFPassView.h"
#import <objc/runtime.h>
#import "Library.h"
@interface WFPassView ()<UITextFieldDelegate>
@property (nonatomic, strong) NSMutableArray <UILabel*> *labelBoxArray;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) NSString *currentText;

@end

@implementation WFPassView
#pragma mark - getter and setter
-(NSInteger)passLength
{
    if (_passLength <= 0) {
        _passLength = 6;
    }
    return _passLength;
}
-(UIFont *)passFont
{
    if (!_passFont) {
        _passFont = SYSTEMFONT(20);
    }
    return _passFont;
}
-(UIColor *)tinColor
{
    if (!_tinColor) {
        _tinColor = HEXCOLOR(@"#555555");
    }
    return _tinColor;
}
-(UIColor *)passColor
{
    if (!_passColor) {
        _passColor = HEXCOLOR(@"#7777777");
    }
    return _passColor;
}
-(CGFloat)itemWidth
{
    if (_itemWidth <= 0) {
        _itemWidth = self.height;
    }
    return _itemWidth;
}
-(CGFloat)itemSpace
{
    if (_itemSpace <= 0) {
        _itemSpace = WFCGFloatX(5);
    }
    return _itemSpace;
}
- (NSMutableArray *)labelBoxArray
{
    if (!_labelBoxArray)
    {
        _labelBoxArray = [NSMutableArray array];
    }
    return _labelBoxArray;
}

- (UITextField *)textField
{
    if (!_textField)
    {
        _textField = [[UITextField alloc] init];
        [_textField addTarget:self action:@selector(textDidChanged:) forControlEvents:UIControlEventEditingChanged];
        _textField.keyboardType = UIKeyboardTypeNumberPad;
        _textField.delegate = self;
    }
    return _textField;
}
#pragma mark - event
-(void)initilization
{
    [self addSubview:self.textField];
    @WeakSelf;
    [self addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        [selfp.textField becomeFirstResponder];
    }];
    [self.textField becomeFirstResponder];
}
#pragma mark - method
- (void)initData
{
    self.currentText = @"";
    for (int i = 0; i < self.passLength; i ++)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * (self.itemWidth + self.itemSpace), 0, self.itemWidth, self.itemWidth)];
        label.textColor = self.passColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = self.passFont;
        [WFFunctions WFUIaddBorderToView:label top:NO left:NO bottom:YES right:NO borderColor:self.tintColor borderWidth:1];
        [self addSubview:label];
        
        [self.labelBoxArray addObject:label];
    }
}

- (void)animationShowTextInLabel:(UILabel *)label
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //特殊字符不居中显示，设置文本向下偏移
        NSAttributedString * att1 = [[NSAttributedString alloc] initWithString:@"●" attributes:@{NSBaselineOffsetAttributeName:@(0)}];
        label.attributedText = att1;
    });
}

- (void)updateAllLabelTextToNone
{
    for (int i = 0; i < self.passLength; i++)
    {
        UILabel *label = self.labelBoxArray[i];
        label.text = @"";
    }
}

- (void)transformTextInTextField:(UITextField *)textField
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        textField.text = @"●";
    });
}
#pragma mark - public method
- (void)updateLabelBoxWithText:(NSString *)text
{
    //输入时
    if (text.length > self.currentText.length) {
        for (int i = 0; i < self.passLength; i++)
        {
            UILabel *label = self.labelBoxArray[i];
            if (i < text.length - 1)
            {
                //特殊字符不居中显示，设置文本向下偏移
                NSAttributedString * att1 = [[NSAttributedString alloc] initWithString:@"●" attributes:@{NSBaselineOffsetAttributeName:@(0)}];
                label.attributedText = att1;
            }
            else if (i == text.length - 1)
            {
                label.text = [text substringWithRange:NSMakeRange(i, 1)];
                [self animationShowTextInLabel: label];
            }
            else
            {
                label.text = @"";
            }
        }
    }
    //删除时
    else
    {
        for (int i = 0; i < self.passLength; i++)
        {
            UILabel *label = self.labelBoxArray[i];
            if (i < text.length)
            {
                //特殊字符不居中显示，设置文本向下偏移
                NSAttributedString * att1 = [[NSAttributedString alloc] initWithString:@"●" attributes:@{NSBaselineOffsetAttributeName:@(0)}];
                label.attributedText = att1;
            }
            else
            {
                label.text = @"";
            }
        }
    }
    self.textField.text = text;
    self.currentText = text;
}
- (void)startShakeViewAnimation
{
    CAKeyframeAnimation *shake = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    shake.values = @[@0,@-10,@10,@-10,@0];
    shake.additive = YES;
    shake.duration = 0.25;
    [self.layer addAnimation:shake forKey:@"shake"];
}

- (void)didInputPasswordError
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startShakeViewAnimation];
        self.textField.text = @"";
        [self updateAllLabelTextToNone];
    });
}

#pragma mark - life
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.width = frame.size.width;
        self.height = frame.size.height;
        [self initilization];
    }
    return self;
}
- (instancetype)init
{
    if (self = [super init])
    {
        self.width = WF_SCREEN_WIDTH;
        self.height = WFCGFloatY(50);
        [self initilization];
    }
    return self;
}

#pragma mark - delegate
#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (void)textDidChanged:(UITextField *)textField
{
    if (textField.text.length > self.passLength)
    {
        textField.text = [textField.text substringToIndex:self.passLength];
    }
    
    [self updateLabelBoxWithText:textField.text];
    if (textField.text.length == self.passLength)
    {
        if (self.completionBlock)
        {
            self.completionBlock(self.textField.text);
        }
    }
}

@end
