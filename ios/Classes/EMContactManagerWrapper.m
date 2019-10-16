//
//  EMContactManagerWrapper.m
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "EMContactManagerWrapper.h"
#import <Hyphenate/Hyphenate.h>
#import "EMSDKMethod.h"

typedef enum : NSUInteger {
    CONTACT_ADD = 0,
    CONTACT_DELETE,
    INVITED,
    INVITATION_ACCEPTED,
    INVITATION_DECLINED
} EMContactEvent;

@interface EMContactManagerWrapper () <EMContactManagerDelegate>

@end

@implementation EMContactManagerWrapper
- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                                   registrar:registrar]) {
        
        [EMClient.sharedClient.contactManager addDelegate:self delegateQueue:nil];
    }
    return self;
}


#pragma mark - FlutterPlugin
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    result(FlutterMethodNotImplemented);
}

#pragma mark - EMContactManagerDelegate

- (void)friendshipDidAddByUser:(NSString *)aUsername {
    NSDictionary *map = @{
        @"type":@(CONTACT_ADD),
        @"userName":aUsername
    };
    [self.channel invokeMethod:EMMethodKeyOnContactChanged
                     arguments:map];
}

- (void)friendshipDidRemoveByUser:(NSString *)aUsername {
    NSDictionary *map = @{
        @"type":@(CONTACT_DELETE),
        @"userName":aUsername
    };
    [self.channel invokeMethod:EMMethodKeyOnContactChanged
                     arguments:map];
}

- (void)friendRequestDidReceiveFromUser:(NSString *)aUsername
                                message:(NSString *)aMessage {
    NSDictionary *map = @{
        @"type":@(INVITED),
        @"userName":aUsername,
        @"reason":aMessage
    };
    [self.channel invokeMethod:EMMethodKeyOnContactChanged
                     arguments:map];
}

- (void)friendRequestDidApproveByUser:(NSString *)aUsername {
    NSDictionary *map = @{
        @"type":@(INVITATION_ACCEPTED),
        @"userName":aUsername
    };
    [self.channel invokeMethod:EMMethodKeyOnContactChanged
                     arguments:map];
}

- (void)friendRequestDidDeclineByUser:(NSString *)aUsername {
    NSDictionary *map = @{
        @"type":@(INVITATION_DECLINED),
        @"userName":aUsername
    };
    [self.channel invokeMethod:EMMethodKeyOnContactChanged
                     arguments:map];
}

@end
