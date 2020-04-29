//
//  Live2ViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/20.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMConferenceViewController.h"

@interface Live2ViewController : EMConferenceViewController

- (instancetype)initWithJoinConfId:(NSString *)aConfId
                          password:(NSString *)aPassword
                             admin:(NSString *)aAdmin
                            chatId:(NSString *)aChatId
                          chatType:(EMChatType)aChatType;

- (void)handleRoleChangedMessage:(EMMessage *)aMessage;

@end
