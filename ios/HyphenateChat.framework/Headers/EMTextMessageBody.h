/**
 *  \~chinese
 *  @header EMTextMessageBody.h
 *  @abstract 文本消息体。
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMTextMessageBody.h
 *  @abstract The text message body.
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#import "EMMessageBody.h"

/**
 *  \~chinese 
 *  文本消息体。
 *
 *  \~english 
 *  The text message body.   
 */
@interface EMTextMessageBody : EMMessageBody

/**
 *  \~chinese 
 *  文本内容。
 *
 *  \~english 
 *  The text content.
 */
@property (nonatomic, copy, readonly) NSString *_Nonnull text;

/**
 *  \~chinese
 *  翻译的目标语言。
 *
 *  \~english
 *  The target language codes to translate.
 */
@property (nonatomic, copy) NSArray<NSString*>*_Nullable targetLanguages;

/**
 *  \~chinese
 *  译文信息。
 *
 *  \~english
 *  Translated information.
 */
@property (nonatomic, copy, readonly) NSDictionary<NSString*,NSString*>*_Nullable translations;
 
/**
 *  \~chinese 
 *  初始化文本消息体。
 *
 *  @param aText   文本内容。
 *  
 *  @result 文本消息体实例。
 *
 *  \~english
 *  Initializes a text message body instance.
 *
 *  @param aText   The text content.
 *
 *  @result The text message body instance.
 */
- (instancetype _Nonnull)initWithText:(NSString *_Nullable)aText;

@end
