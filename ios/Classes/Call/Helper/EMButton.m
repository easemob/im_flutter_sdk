//
//  EMButton.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/19.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMButton.h"
#import "Masonry.h"

#define EMButtonDefaultTitleColor [UIColor blackColor]

@implementation EMButtonState

@end

@interface EMButton()

@property (nonatomic, strong) NSString *normalTitle;

@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, strong) NSMutableDictionary *stateDict;

@end

@implementation EMButton

- (instancetype)initWithTitle:(NSString *)aTitle
                       target:(id)aTarget
                       action:(SEL)aAction
{
    self = [super init];
    if (self) {
        _normalTitle = aTitle;
        _stateDict = [[NSMutableDictionary alloc] init];
        
        
        [self _setupSubviewsWithTitle:aTitle];
        
        [self addTarget:aTarget action:aAction forControlEvents:UIControlEventTouchUpInside];
        
        EMButtonState *buttonState = [[EMButtonState alloc] init];
        buttonState.title = aTitle;
        buttonState.titleColor = EMButtonDefaultTitleColor;
        [self.stateDict setObject:buttonState forKey:@(UIControlStateNormal)];
    }
    
    return self;
}

- (void)_setupSubviewsWithTitle:(NSString *)aTitle
{
    self.imgView = [[UIImageView alloc] init];
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.imgView];
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(self).multipliedBy(0.6);
    }];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = EMButtonDefaultTitleColor;
    self.titleLabel.font = [UIFont systemFontOfSize:13];
    self.titleLabel.text = aTitle;
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imgView.mas_bottom);
        make.bottom.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
    }];
}

#pragma mark - Private

- (EMButtonState *)_getButtonStateWithState:(UIControlState)aState
{
    EMButtonState *buttonState = [self.stateDict objectForKey:@(aState)];
    if (!buttonState) {
        buttonState = [[EMButtonState alloc] init];
        buttonState.title = self.normalTitle;
        buttonState.titleColor = EMButtonDefaultTitleColor;
        [self.stateDict setObject:buttonState forKey:@(aState)];
    }
    
    return buttonState;
}

- (void)_reloadWithState:(UIControlState)aState
{
    EMButtonState *buttonState = [self.stateDict objectForKey:@(aState)];
    if (buttonState) {
        self.imgView.image = buttonState.image;
        self.titleLabel.textColor = buttonState.titleColor;
        self.titleLabel.text = buttonState.title;
    }
}

#pragma mark - Public

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    UIControlState state = UIControlStateNormal;
    if (selected) {
        state = UIControlStateSelected;
    }
    [self _reloadWithState:state];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    UIControlState state = UIControlStateNormal;
    if (!enabled) {
        state = UIControlStateDisabled;
    }
    [self _reloadWithState:state];
}

- (void)setTitle:(nullable NSString *)title
        forState:(UIControlState)state
{
    EMButtonState *buttonState = [self _getButtonStateWithState:state];
    buttonState.title = title;
    
    if (self.state == state) {
        self.titleLabel.text = title;
    }
}

- (void)setTitleColor:(nullable UIColor *)color
             forState:(UIControlState)state
{
    EMButtonState *buttonState = [self _getButtonStateWithState:state];
    buttonState.titleColor = color;
    
    if (self.state == state) {
        self.titleLabel.textColor = color;
    }
}

- (void)setImage:(nullable UIImage *)image
        forState:(UIControlState)state
{
    EMButtonState *buttonState = [self _getButtonStateWithState:state];
    buttonState.image = image;
    
    if (self.state == state) {
        self.imgView.image = image;
    }
}

@end
