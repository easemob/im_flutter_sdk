/**
 *  \~chinese
 *  @header EMMessageBody.h
 *  @abstract 消息体类型的基类
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMMessageBody.h
 *  @abstract Base class of message body
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

/**
 *  \~chinese
 *  消息体类型。
 *
 *  \~english
 *  The enum of message body types.
 */
typedef NS_ENUM(NSInteger, EMMessageBodyType) {
    /** \~chinese 文本消息。 \~english A text message.*/
    EMMessageBodyTypeText   = 1,
    /** \~chinese 图片消息。 \~english An image message.*/
    EMMessageBodyTypeImage,
    /** \~chinese 视频消息。 \~english A video message.*/
    EMMessageBodyTypeVideo,
    /** \~chinese 位置消息。 \~english A location message.*/
    EMMessageBodyTypeLocation,
    /** \~chinese 语音消息。 \~english A voice message.*/
    EMMessageBodyTypeVoice,
    /** \~chinese 文件消息。 \~english A file message.*/
    EMMessageBodyTypeFile,
    /** \~chinese 指令消息。 \~english A command message.*/
    EMMessageBodyTypeCmd,
    /** \~chinese 自定义消息。\~english A custom message.*/
    EMMessageBodyTypeCustom,
    /** \~chinese 合并消息。\~english A combine message.*/
    EMMessageBodyTypeCombine,
};

/**
 *  \~chinese
 *  消息体。
 *  不直接使用，由子类继承实现。
 *
 *  \~english
 *  The message body.
 */
@interface EMMessageBody : NSObject

-(instancetype _Nonnull ) init NS_UNAVAILABLE;

/**
 *  \~chinese
 *  消息体类型。
 *
 *  \~english
 *  The message body type.
 */
@property (nonatomic, readonly) EMMessageBodyType type;
/**
 *  \~chinese
 *  获取最后一次消息修改的时间戳，单位为毫秒。。
 *
 *  \~english
 *  Get the UNIX timestamp of the last message modification, in milliseconds.
 */
@property (nonatomic, assign,readonly) NSUInteger operationTime;
/**
 *  \~chinese
 *  获取最后一次消息修改的操作者的用户 ID。
 *
 *  \~english
 *  Get the user ID of the operator that modified the message last time.
 */
@property (nonatomic,nullable,readonly) NSString *operatorId;
/**
 *  \~chinese
 *  获取消息修改次数。
 *
 *  \~english
 *  Get the number of times a message is modified.
 */
@property (nonatomic, assign,readonly) NSUInteger operatorCount;

@end
