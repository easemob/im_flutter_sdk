//
//  DemoConfManager.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 23/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Hyphenate/Hyphenate.h>
#import "ConfInviteUsersViewController.h"

@class EMConferenceViewController;
@interface DemoConfManager : NSObject

+ (instancetype)sharedManager;

- (void)inviteMemberWithConfType:(EMConferenceType)aConfType
                      inviteType:(ConfInviteType)aInviteType
                  conversationId:(NSString *)aConversationId
                        chatType:(EMChatType)aChatType
                        password:(NSString *)aPassword
                          record:(BOOL)isRecord
                           merge:(BOOL)isMerge
               popFromController:(UIViewController *)aController;

- (void)endConference:(EMCallConference *)aCall
            isDestroy:(BOOL)aIsDestroy;

- (void)createAndJoinConference:(NSDictionary *)dict completion:(void (^)(EMCallConference *aCall,EMError *aError))aCompletionBlock;

- (void)joinCoference:(NSDictionary *)dict completion:(void (^)(EMCallConference *aCall,EMError *aError))aCompletionBlock;



@end
