//
//  EMButton.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/19.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMButtonState : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIImage *image;

@end

@interface EMButton : UIControl

@property (nonatomic, strong) UILabel *titleLabel;

- (instancetype)initWithTitle:(NSString *)aTitle
                       target:(id)aTarget
                       action:(SEL)aAction;

- (void)setTitle:(nullable NSString *)title
        forState:(UIControlState)state;

- (void)setTitleColor:(nullable UIColor *)color
             forState:(UIControlState)state;

- (void)setImage:(nullable UIImage *)image
        forState:(UIControlState)state;

@end
