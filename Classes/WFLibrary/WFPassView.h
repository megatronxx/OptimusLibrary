//
//  WFPassView.h
//  UVTao
//
//  Created by mac on 2018/9/26.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^WFPassViewHandler)(NSString *password);

@interface WFPassView : UIView
@property (nonatomic,copy) WFPassViewHandler completionBlock;
@property (nonatomic,assign) NSInteger passLength;
@property (nonatomic,strong) UIFont *passFont;
@property (nonatomic,strong) UIColor *tinColor;
@property (nonatomic,strong) UIColor *passColor;
@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, assign) CGFloat itemSpace;
- (void)initData;
/** 更新输入框数据 */
- (void)updateLabelBoxWithText:(NSString *)text;

/** 抖动输入框 */
- (void)startShakeViewAnimation;

- (void)didInputPasswordError;
@end

NS_ASSUME_NONNULL_END
