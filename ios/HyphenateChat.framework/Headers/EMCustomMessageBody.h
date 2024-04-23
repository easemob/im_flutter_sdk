/**
 *  \~chinese
 *  @header EMCustomMessageBody.h
 *  @abstract 自定义消息体
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMCustomMessageBody.h
 *  @abstract Custom message body
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>
#import "EMCommonDefs.h"
#import "EMMessageBody.h"

/**
 *  \~chinese
 *  自定义消息体。
 *
 *  \~english
 *  The custom message body.
 */
@interface EMCustomMessageBody : EMMessageBody

/**
 *  \~chinese
 *  自定义事件。
 *
 *  \~english
 *  The custom event.
 */
@property (nonatomic, copy) NSString *event;

/**
 *  \~chinese
 *  自定义扩展字典。
 *
 *  \~english
 *  The custom extension dictionary.
 */
@property (nonatomic, copy) NSDictionary<NSString *,NSString *> *customExt;


/**
 *  \~chinese
 *  初始化自定义消息体。
 *
 *  @param aEvent   自定义事件。
 *  @param aCustomExt 自定义扩展字典。
 *
 *  @result 自定义消息体实例。
 *
 *  \~english
 *  Initializes a custom message body instance.
 *
 *  @param aEvent   The custom event.
 *  @param aCustomExt The custom extension dictionary.
 *
 *  @result The custom message body instance.
 */
- (instancetype _Nonnull)initWithEvent:(NSString *_Nullable)aEvent customExt:(NSDictionary<NSString *,NSString *> *_Nullable)aCustomExt;
@end
