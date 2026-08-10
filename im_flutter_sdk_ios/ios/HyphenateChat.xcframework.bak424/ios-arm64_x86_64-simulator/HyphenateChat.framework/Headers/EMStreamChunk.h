//
//  EMStreamChunk.h
//  HyphenateChat
//
//  Created by 朱继超 on 12/25/25.
//  Copyright © 2025 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,EMStreamChunkStatus) {
    /**
     * \~chinese 流式消息开始。
     * \~english Stream started.
     */
    EMStreamChunkStatusStart = 0,          // Stream started
    /**
     * \~chinese 流式消息开始即完成（单片流式消息）。
     * \~english Stream started and completed in one chunk (single fragment).
     */
    EMStreamChunkStatusStartAndComplete, // Stream started and completed in one chunk (single fragment)
    /**
     * \~chinese 流式消息进行中。
     * \~english Stream in progress.
     */
    EMStreamChunkStatusProgress,       // Stream in progress
    /**
     * \~chinese 流式消息完成。
     * \~english Stream completed.
     */
    EMStreamChunkStatusComplete,       // Stream completed
    /**
     * \~chinese 流式消息错误。
     * \~english Stream ended with error.
     */
    EMStreamChunkStatusError           // Stream ended with error
};

NS_ASSUME_NONNULL_BEGIN

@interface EMStreamChunk : NSObject
/**
 * \~chinese 流式消息分片状态。
 * \~english Stream chunk status of the stream chunk.
 */
@property (nonatomic) EMStreamChunkStatus status;
/**
 * \~chinese 流式消息分片错误码。默认值为0表示正常，如果是其他错误请去EMErrorCode错误码表中查询.
 * \~english Stream chunk error code of the stream chunk. Default value is 0, which indicates no error. If the value is not 0, please refer to the EMErrorCode error code table for details.
 */
@property (nonatomic) int16_t errorCode;
/**
 * \~chinese 流式消息分片完成原因。由用户透传。0代表无异常。
 * \~english Stream chunk finish reason of the stream chunk. Passed through by the user. `0` indicates no exception.
 */
@property (nonatomic) int16_t finishReason;
/**
 * \~chinese 流式消息分片文本内容。
 * \~english Text content of the stream chunk.
 */
@property (nonatomic, copy) NSString* text;
/**
 * \~chinese 流式消息分片自定义类型。
 * \~english Custom type of the stream chunk.
 */
@property (nonatomic, copy) NSString *_Nullable customType;
/**
 * \~chinese 流式消息分片序列号。
 * \~english Sequence number of the stream chunk.
 */
@property (nonatomic) long sequenceNumber;

@end

NS_ASSUME_NONNULL_END
