/**
 *  \~chinese
 *  @header EMVideoMessageBody.h
 *  @abstract 视频消息体。
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMVideoMessageBody.h
 *  @abstract The video message body.
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#import "EMFileMessageBody.h"

/**
 *  \~chinese
 *  视频消息体。
 *
 *  \~english
 *  The video message body.
 */
@interface EMVideoMessageBody : EMFileMessageBody

/**
 *  \~chinese
 *  视频时长, 单位为秒。
 *
 *  \~english
 *  The video duration, in seconds.
 */
@property (nonatomic) int duration;

/**
 *  \~chinese
 *  缩略图的本地路径。
 *
 *  \~english
 *  The local path of thumbnail.
 */
@property (nonatomic, copy) NSString *_Nullable thumbnailLocalPath;

/**
 *  \~chinese
 *  缩略图在服务器的路径。
 *
 *  \~english
 *  The URL of the thumbnail on the server.
 */
@property (nonatomic, copy) NSString *_Nullable thumbnailRemotePath;

/**
 *  \~chinese
 *  缩略图的密钥, 下载缩略图时需要密匙做校验。
 *
 *  \~english
 *  The secret key of the thumbnail, which is required for verification when downloading the thumbnail.
 */
@property (nonatomic, copy) NSString *_Nullable thumbnailSecretKey;

/**
 *  \~chinese
 *  视频缩略图的尺寸。
 *
 *  \~english
 *  The size of the video thumbnail.
 */
@property (nonatomic) CGSize thumbnailSize;

/**
 *  \~chinese
 *  缩略图下载状态。
 *
 *  \~english
 *  The download status of the thumbnail.
 */
@property (nonatomic)EMDownloadStatus thumbnailDownloadStatus;

@end
