//
//  EMChatroomOptions.h
//  HyphenateSDK
//
//  Created by XieYajie on 09/01/2017.
//  Copyright © 2017 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  \~chinese
 *  @abstract 聊天室的设置选项。
 *
 *  \~english
 *  The options of a chatroom.
 */
@interface EMChatroomOptions : NSObject

/**
 *  \~chinese
 *  聊天室的最大成员数。取值范围 [3,5000]，默认值 200。
 *
 *  \~english
 *  The maximum number of members in a chatroom. The value range is [3,5000], and the default value is 200.
 */
@property (nonatomic) NSInteger maxUsersCount;

@end
