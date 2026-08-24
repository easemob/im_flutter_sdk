/**
 *  \~chinese
 *  @header IEMStatisticsManager.h
 *  @abstract 消息流量统计相关操作代理协议。
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header IEMStatisticsManager.h
 *  @abstract This protocol defines the message statistics operations. 
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>
#import "EMChatMessageStatistics.h"

/**
 *  \~chinese
 *  消息方向，用于查询。
 *
 *  \~english
 *  The message direction types for querying.
 */
typedef NS_ENUM(NSUInteger, EMMessageStatisticsDirection) {
    EMMessageStatisticsDirectionSend = 0, /** \~chinese 当前用户发送的消息。\~english This message is sent from the local client.*/
    EMMessageStatisticsDirectionReceive, /** \~chinese 当前用户接收到的消息。 \~english The message is received by the local client.*/
    EMMessageStatisticsDirectionAll = 100, /** \~chinese 当前用户发送或接收的消息。 \~english  The message is sent from or received by the local client.*/
};

/**
 *  \~chinese
 *  消息类型，用于查询。
 *
 *  \~english
 *  The message body types for querying.
 */
typedef NS_ENUM(NSUInteger, EMMessageStatisticsType) {
    EMMessageStatisticsTypeText = 0, /** \~chinese 文本消息。 \~english A text message.*/
    EMMessageStatisticsTypeImage,  /** \~chinese 图片消息。 \~english An image message.*/
    EMMessageStatisticsTypeVideo,  /** \~chinese 视频消息。 \~english A video message.*/
    EMMessageStatisticsTypeLocation, /** \~chinese 位置消息。 \~english A location message.*/
    EMMessageStatisticsTypeVoice, /** \~chinese 语音消息。 \~english A voice message.*/
    EMMessageStatisticsTypeFile, /** \~chinese 文件消息。 \~english A file message.*/
    EMMessageStatisticsTypeCmd, /** \~chinese  透传消息。 \~english A command message.*/
    EMMessageStatisticsTypeCustom, /** \~chinese 自定义消息。\~english A custom message.*/
    EMMessageStatisticsTypeAll = 100, /** \~chinese 所有消息类型。\~english All message types.*/
};


@class EMError;

/**
 *  \~chinese
 *  流量统计相关操作代理协议。
 * 
 * 该协议中的方法可用于统计一定时间段内发送和/接收的指定类型的本地消息数量及其流量。
 * 
 * 本地消息的流量统计功能默认关闭。若要使用该功能，需在 SDK 初始化前设置 {@link EMOptions#enableStatistics} 开启。
 * 
 * SDK 只支持统计该功能开启后最近 30 天内发送和接收的消息。各类消息的流量计算方法如下：
 * - 对于文本、透传、位置和自定义消息，消息流量为消息体的流量；
 * - 对于图片和视频消息，消息流量为消息体、图片或视频文件以及缩略图的流量之和；
 * - 对于文件和语音消息，消息流量为消息体和附件的流量。
 * 
* @note
 * 1. 对于携带附件的消息，下载成功后 SDK 才统计附件的流量。若附件下载多次，则会对下载的流量进行累加。
 * 2. 对于从服务器拉取的漫游消息，如果本地数据库中已经存在，则不进行统计。
 * 
 * SDK 仅统计本地消息的流量，而非消息的实际流量。一般而言，该统计数据小于实际流量，原因如下：
 * - 未考虑发送消息时通用协议数据的流量；
 * - 对于接收到的消息，服务端会进行消息聚合，添加通用字段，而消息流量统计为各消息的流量，未考虑通用字段的流量消耗。
 * 
 *
 *  \~english
 * The protocol that defines statistical operations of message traffic.
 * 
 * This protocol contains methods that are used to calculate the number of local messages of certain types sent and/or received in a specified period, as well as their traffic.
 * 
 * This traffic statistics function is disabled by default. To use this function, you need to enable it by setting {@link EMOptions#enableStatistics} prior to the SDK initialization. The SDK can collect statistics of messages that are sent and received after this function is enabled.
 *  
 * The SDK only calculates the traffic of messages that are sent and received within the last 30 days after the traffic statistics function is enabled. 
 * 
 *  The message traffic is calculated as follows:
 *  - For a text, command, location or custom message, the message traffic is the traffic of the message body.
 *  - For an image or video message, the message traffic is the traffic sum of the message body, the image or video file, and the thumbnail.
 *  - For a file or voice message, the message traffic is the traffic sum of the message body and the attachment.
 * 
 * @note
 * 1. For messages with attachments, the traffic will be calculated only if the download is successful.
 *    If an attachment is downloaded multiple times, its download traffic will be accumulated.
 * 2. For roaming messages pulled from the server, if they already exist in the local database, the SDK ignores them during traffic calculation.
 * 
 * The SDK only measures the traffic of local messages, but not the actual message traffic. Generally, the calculated traffic volume is smaller than the actual traffic because of the following:
 *   - The traffic of the common protocol data generated during message sending is not considered;
 *   - For the received messages, the server aggregates them and adds common fields. During traffic statistics, the SDK only calculates the traffic of individual messages, but ignoring the traffic of common fields. 
 * 
 */
@protocol IEMStatisticsManager <NSObject>

@required


/**
 *  \~chinese
 *  根据消息 ID 获取消息流量统计信息。
 *
 *  @param messageId  消息 ID。
 *  @return 返回消息的流量统计信息。统计数据详见 {@link EMChatMessageStatistics}。
 *
 *  \~english
 *  Gets the message traffic statistics by message ID.
 * 
 *  @param messageId The message ID.
 *  @return The message traffic statistics. 
 */
- (EMChatMessageStatistics* _Nullable)getMessageStatisticsById:(NSString* _Nonnull)messageId;

/**
 *  \~chinese
 *  获取一定时间段内发送和/或接收的指定类型的消息条数。
 *
 *  @param startTimestamp  起始时间戳，单位为毫秒。
 *  @param endTimestamp 结束时间戳，单位为毫秒。
 *  @param direction  消息方向。
 *  @param type  消息类型。
 *  @return 返回符合条件的消息条数。调用失败时返回 `0`。
 *
 *  \~english
 *  Gets the count of messages of certain types that are sent and/or received in a specified period.
 * 
 *  @param startTimestamp  The starting timestamp for statistics. The unit is millisecond.
 *  @param endTimestamp The ending timestamp for statistics. The unit is millisecond.
 *  @param direction  The message direction.
 *  @param type  The message type.
 *  @return The count of messages that meet the statistical conditions. `0` is returned in the case of a call failure.
 */
- (NSInteger)getMessageCountWithStart:(NSInteger)startTimestamp
                                  end:(NSInteger)endTimestamp
                            direction:(EMMessageStatisticsDirection)direction
                                 type:(EMMessageStatisticsType)type;


/**
 *  \~chinese
 *  获取一定时间段内发送和/或接收的指定类型的消息的总流量。
 * 
 *  消息流量单位为字节。
 *
 *  @param startTimestamp  起始时间戳，单位为毫秒。
 *  @param endTimestamp 结束时间戳，单位为毫秒。
 *  @param direction  消息方向。
 *  @param type  消息类型。
 *  @return 返回符合条件的消息的总流量，单位字节。调用失败时返回 `0`。
 *
 *  \~english
 *  Gets the total traffic amount of messages that meet the statistical conditions.
 * 
 *  The traffic is measured in bytes.
 * 
 *  @param startTimestamp  The starting timestamp for statistics. The unit is millisecond.
 *  @param endTimestamp The ending timestamp for statistics. The unit is millisecond.
 *  @param direction  The message direction.
 *  @param type  The message type.
 *  @return The total traffic amount of messages that meet the statistical conditions. `0` is returned in the case of a call failure.
 */
- (NSInteger)getMessageStatisticsSizeWithStart:(NSInteger)startTimestamp
                                           end:(NSInteger)endTimestamp
                                     direction:(EMMessageStatisticsDirection)direction
                                          type:(EMMessageStatisticsType)type;

@end
