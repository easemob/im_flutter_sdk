//
//  EMContactManagerWrapper.m
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "EMContactManagerWrapper.h"
#import <Hyphenate/Hyphenate.h>

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

- (void)friendRequestDidApproveByUser:(NSString *)aUsername {
    
}

- (void)friendRequestDidDeclineByUser:(NSString *)aUsername {
    
}

- (void)friendshipDidRemoveByUser:(NSString *)aUsername {
    
}

- (void)friendshipDidAddByUser:(NSString *)aUsername {
    
}

- (void)friendRequestDidReceiveFromUser:(NSString *)aUsername
                                message:(NSString *)aMessage {
    
}
@end
