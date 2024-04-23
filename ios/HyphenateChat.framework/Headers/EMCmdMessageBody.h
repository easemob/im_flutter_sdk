/**
 *  \~chinese
 *  @header EMCmdMessageBody.h
 *  @abstract 命令消息体对象。
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMCmdMessageBody.h
 *  @abstract The command message body object.
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#import "EMMessageBody.h"

/**
 *  \~chinese 
 *  命令消息体对象。
 *
 *  \~english
 *  The command message body.
 */
@interface EMCmdMessageBody : EMMessageBody

/**
 *  \~chinese
 *  命令内容。
 *
 *  \~english
 *  The command content.
 */
@property (nonatomic, copy) NSString *action;

/**
 *  \~chinese
 *  是否只投递在线用户。默认为否，同时投递给在线和离线用户；设置为 YES 则只投递在线用户。
 *  一般来说，用户不在线时有需要接收的消息，服务器会把消息放到离线队列，等用户上线后，再由 SDK 从离线队列中把消息拉走，对用户来说就是“收到了离线期间的消息”。但针对设置了 `isDeliverOnlineOnly` 的 cmd 消息，服务器不会写到离线队列，这样用户再上线后就不会取到了，从而达到 “只投递在线” 的效果。
 *
 *  \~english
 *  Whether this cmd msg is delivered to the online users only. The default value is NO. Set this parameter as YES and the msg is delivered to the online users only, so the offline users won't receive the msg when they log in later.
 */
@property (nonatomic) BOOL isDeliverOnlineOnly;

/**
 *  \~chinese
 *  初始化命令消息体。
 *  `EMMessage` 的 `ext` 属性是用户自己定义的关键字，接收后，解析出自定义的字符串，可以自行处理。
 *  
 *  @param aAction  命令内容。
 *  
 *  @result 命令消息体实例。
 *
 *  \~english
 *  The construct command message body.
 *  Developer self-defined command string that can be used for specifing custom action/command. See `ext` in `EMMessage`.
 *  
 *  @param aAction  The self-defined command string content.
 *
 *  @result The instance of command message body.
 */
- (instancetype _Nonnull)initWithAction:(NSString * _Nonnull)aAction;

@end
