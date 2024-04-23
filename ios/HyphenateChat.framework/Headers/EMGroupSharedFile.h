/**
 *  \~chinese
 *  @header EMGroupSharedFile.h
 *  @abstract 群组共享文件
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMGroupSharedFile.h
 *  @abstract Group share file
 *  @author Hyphenate
 *  @version 3.00
 */
#import <Foundation/Foundation.h>

/**
 *  \~chinese
 *  群共享文件对象
 *
 *  \~english
 *  The group shared file object.
 */
@interface EMGroupSharedFile : NSObject

/**
 *  \~chinese
 *  文件 ID，是文件的唯一标识符。
 *
 *  \~english
 *  The file ID, which is the unique identifier of a file.
 */
@property (nonatomic, copy, readonly) NSString *fileId;

/**
 *  \~chinese
 *  文件名称。
 *
 *  \~english
 *  The name of the file.
 */
@property (nonatomic, copy, readonly) NSString *fileName;

/**
 *  \~chinese
 *  文件发布者。
 *
 *  \~english
 *  The owner of the file.
 */
@property (nonatomic, copy, readonly) NSString *fileOwner;

/**
 *  \~chinese
 *  文件创建 Unix 时间戳，单位为毫秒。
 *
 *  \~english
 *  The Unix timestamp for creating the file, in ms.
 */
@property (nonatomic) long long createdAt;

/**
 *  \~chinese
 *  文件大小（字节）。
 *
 *  \~english
 *  The data length (bytes) of the file. 
 */
@property (nonatomic) long long fileSize;

/**
 *  \~chinese
 *  获取群共享文件实例。
 *
 *  @param aFileId    文件 ID。
 *
 *  @result 群共享文件实例。
 *
 *  \~english
 *  Gets the shared file instance.
 *
 *  @param aFileId  The file ID.
 *
 *  @result The shared file instance.
 */
+ (instancetype)sharedFileWithId:(NSString*)aFileId;


#pragma mark - EM_DEPRECATED_IOS 3.8.8

/**
 *  \~chinese
 *  文件创建时间
 *
 *  \~english
 *  Create Time of File
 */
@property (nonatomic) long long createTime
__deprecated_msg("Use createdAt instead");

@end
