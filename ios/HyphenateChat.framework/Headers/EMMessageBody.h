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
    EMMessageBodyTypeText   = 1,    /** \~chinese 文本消息。 \~english A text message.*/
    EMMessageBodyTypeImage,         /** \~chinese 图片消息。 \~english An image message.*/
    EMMessageBodyTypeVideo,         /** \~chinese 视频消息。 \~english A video message.*/
    EMMessageBodyTypeLocation,      /** \~chinese 位置消息。 \~english A location message.*/
    EMMessageBodyTypeVoice,         /** \~chinese 语音消息。 \~english A voice message.*/
    EMMessageBodyTypeFile,          /** \~chinese 文件消息。 \~english A file message.*/
    EMMessageBodyTypeCmd,           /** \~chinese 指令消息。 \~english A command message.*/
    EMMessageBodyTypeCustom,        /** \~chinese 自定义消息。\~english A custom message.*/
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

/**
 *  \~chinese 
 *  消息体类型。
 *
 *  \~english 
 *  The message body type.
 */
@property (nonatomic, readonly) EMMessageBodyType type;

@end
