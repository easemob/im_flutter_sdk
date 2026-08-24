//
//  EMCombineMessageBody.h
//  HyphenateChat
//
//  Created by li xiaoming on 2023/6/19.
//  Copyright © 2023 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMFileMessageBody.h"

/**
 *  \~chinese
 *  合并消息体。
 *
 *  \~english
 *  The combine message body.
 */
@interface EMCombineMessageBody : EMFileMessageBody

/**
 *  \~chinese
 *  消息标题。
 *
 *  \~english
 *  The message title.
 */
@property (nonatomic,strong) NSString*_Nullable title;

/**
 *  \~chinese
 *  消息概要。
 *
 *  \~english
 *  The message summary.
 */
@property (nonatomic,strong) NSString*_Nullable summary;

/**
 *  \~chinese
 *  兼容文本。
 *
 *  \~english
 *  The compatible text.
 */
@property (nonatomic,strong) NSString*_Nullable compatibleText;

/**
 *  \~chinese
 *  合并消息的消息Id列表。
 *
 *  \~english
 *  Get the list of messageId included in the combined message.
 */
@property (nonatomic,readonly) NSArray<NSString *> * _Nonnull messageIdList;

/**
 *  \~chinese
 *  初始化合并消息体。
 *
 *  @param aTitle   合并消息的标题。
 *  @param aSummary 合并消息的概要。
 *  @param aCompatibleText 兼容文本。
 *  @param aMessageIdList 合并消息的消息Id列表。
 *
 *  @result 合并消息体实例。
 *
 *  \~english
 *  Initializes a combined message body instance.
 *
 *  @param aTitle   The title of the combined message.
 *  @param aSummary The summary of the combined message.
 *  @param aCompatibleText The compatible text.
 *  @param aMessageIdList The list of messageId included in the combined message.
 *
 *  @result The combined message body instance.
 */

- (instancetype _Nonnull)initWithTitle:(NSString *_Nullable)aTitle
                               summary:(NSString *_Nullable)aSummary
                        compatibleText:(NSString *_Nullable)aCompatibleText
                         messageIdList:(NSArray<NSString*>*_Nonnull)aMessageIdList;

-(instancetype _Nonnull ) init NS_UNAVAILABLE;
@end
