/**
 *  \~chinese
 *  @header EMVoiceMessageBody.h
 *  @abstract 语音消息体。
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMVoiceMessageBody.h
 *  @abstract The voice message body.
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#import "EMFileMessageBody.h"

/**
 *  \~chinese 
 *  语音消息体。
 *
 *  \~english
 *  The voice message body.
 */
@interface EMVoiceMessageBody : EMFileMessageBody

/**
 *  \~chinese 
 *  语音时长，单位为秒。SDK 没有规定取值范围，用户可以根据需求设置。
 *
 *  \~english 
 *  The voice duration, in seconds. You can customize the length accordingly.
 */
@property (nonatomic) int duration;

@end
