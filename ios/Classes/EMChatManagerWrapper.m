//
//  EMChatManagerWrapper.m
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "EMChatManagerWrapper.h"
#import <Hyphenate/Hyphenate.h>

@interface EMChatManagerWrapper () <EMChatManagerDelegate>
@end

@implementation EMChatManagerWrapper
- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                               registrar:registrar]) {
    }
    return self;
}
@end
