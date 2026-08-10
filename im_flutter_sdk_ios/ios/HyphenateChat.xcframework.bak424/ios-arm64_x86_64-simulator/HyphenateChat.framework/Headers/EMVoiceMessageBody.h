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
 *  语音时长，单位为秒。
 *
 *  \~english 
 *  The voice duration in seconds. 
 * 
 */
@property (nonatomic) int duration;

/**
 *  \~chinese
 *  语音消息转文字后的文本内容。
 *
 *  \~english
 *  The text transcribed from the voice message.
 */
@property (nonatomic, copy, readonly) NSString *text;

-(instancetype _Nonnull ) init NS_UNAVAILABLE;
@end
