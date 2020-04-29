//
//  ConfInviteYserCell11.m
//  EMiOSDemo
//
//  Created by easemob-DN0164 on 2020/4/26.
//  Copyright © 2020 easemob-DN0164. All rights reserved.
//

#import "ConfInviteUserCell.h"
#import "Masonry.h"

@interface ConfInviteUserCell ()
@property (nonatomic, strong) UIImageView *checkView;;
@end

@implementation ConfInviteUserCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _setupSubviews];
    }
    
    return self;
}

- (void)_setupSubviews
{
    self.imgView = [[UIImageView alloc] init];
    self.imgView.image = [UIImage imageNamed:@"user_avatar_blue"];
    [self.contentView addSubview:self.imgView];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont systemFontOfSize:17.0];
    self.nameLabel.numberOfLines = 1;
    [self.contentView addSubview:self.nameLabel];
    
    self.checkView = [[UIImageView alloc] init];
    self.checkView.image = [UIImage imageNamed:@"uncheck"];
    [self.contentView addSubview:self.checkView];
    
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@45);
        make.left.equalTo(self.contentView.mas_left).offset(16);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    [self.checkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@25);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
        make.left.equalTo(self.imgView.mas_right).offset(10);
        make.right.equalTo(self.checkView.mas_left).offset(-10);
    }];
    

}

- (void)setIsChecked:(BOOL)isChecked
{
    if (_isChecked != isChecked) {
        _isChecked = isChecked;
        
        if (isChecked) {
            self.checkView.image = [UIImage imageNamed:@"checked"];
        } else {
            self.checkView.image = [UIImage imageNamed:@"uncheck"];
        }
    }
}

@end
