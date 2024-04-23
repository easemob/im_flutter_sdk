/**
 *  \~chinese
 *  @header EMImageMessageBody.h
 *  @abstract 图片消息体类
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMImageMessageBody.h
 *  @abstract Image message body class
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#import "EMFileMessageBody.h"

/**
 *  \~chinese
 *  创建的图片消息体。以下为两种图片消息体生成的方式，图片数据和图片显示名称或者图片内容和缩略图数据。
 *  -(instancetype)initWithData:displayName: 
 *  or
 *  -(instancetype)initWithData:thumbnailData:
 *  Note: 图片消息体，SDK 会根据压缩率 compressRatio 來发送消息。
 *
 *  \~english
 *  The image message body.
 * 
 *  You can create an image message body by calling one of the following methods:
 * 
 *   -`(instancetype)initWithData:displayName:`
 *   -`(instancetype)initWithData:thumbnailData:`
 * 
 *  Note: SDK will compress the image based on the attribute compressRatio when delivering the image.
 */
@interface EMImageMessageBody : EMFileMessageBody

/**
 *  \~chinese
 *  图片附件的尺寸。
 *
 *  \~english
 *  The resolution of the image.
 */
@property (nonatomic) CGSize size;

/**
 *  \~chinese
 *  图片消息文件的压缩率。
 * 
 *  SDK 在发送图片消息时，会根据该参数的值来压缩图片文件。取值范围是 (0.0,1.0]，默认值是 0.6。其中 1.0 表示原图文件不压缩，0.6 表示将原图文件大小压缩为初始文件的 0.6 倍。如果设置小于等于 0，则 SDK 使用默认值。
 *  
 * \~english
 *  The compression ratio of the image file.
 *  
 *  When sending the image message, the SDK compresses the image file according to the value of this parameter. The value range is (0.0, 1.0], and the default value is 0.6. 1.0 means that the SDK does not compress the image file, and 0.6 means that the SDK compresses the file size to 60% of the original. If you set this parameter to a value lower than 0 (included), the SDK uses the default value.
 */
@property (nonatomic) CGFloat compressionRatio;

/**
 *  \~chinese
 *  缩略图的显示名。
 *
 *  \~english
 *  The display name of thumbnail.
 */
@property (nonatomic, copy) NSString *thumbnailDisplayName;

/**
 *  \~chinese
 *  缩略图的本地路径。发送方可以根据该属性获取缩略本地路径。调用 imageWithContentsOfFile 方法，传入 thumbnailLocalPath 即可获取缩略图的数据。
 * 
 *  UIImage *image = [UIImage imageWithContentsOfFile:thumbnailLocalPath];
 *
 *  \~english
 *  The local path of the thumbnail.
 *  UIImage *image = [UIImage imageWithContentsOfFile:thumbnailLocalPath];
 */
@property (nonatomic, copy) NSString *thumbnailLocalPath;

/**
 *  \~chinese
 *  缩略图在服务器的路径。接收方可以通过该属性获取缩略图服务器路径。
 *
 *  \~english
 *  The URL path of the thumbnail of the server.
 *  
 *   The message receiver gets the thumbnail with this member.
 */
@property (nonatomic, copy) NSString *thumbnailRemotePath;

/**
 *  \~chinese
 *  缩略图的密钥。下载缩略图时用户需要提供密钥进行校验。
 *
 *  \~english
 *  The secret key for the thumbnail. A key is required for verification when downloading thumbnail.
 */
@property (nonatomic, copy) NSString *thumbnailSecretKey;

/**
 *  \~chinese
 *  缩略图的尺寸。
 *
 *  \~english
 *  The resolution of the thumbnail file.
 */
@property (nonatomic) CGSize thumbnailSize;

/**
 *  \~chinese
 *  缩略图文件的大小, 以字节为单位。
 *
 *  \~english
 *  The data length (bytes) of the thumbnail file.
 */
@property (nonatomic) long long thumbnailFileLength;

/**
 *  \~chinese
 *  缩略图下载状态。
 *
 *  \~english
 *  The download status of the thumbnail.
 */
@property (nonatomic)EMDownloadStatus thumbnailDownloadStatus;

/**
 *  \~chinese
 *  初始化图片消息体。
 * 
 * @param aData 图片数据。如果该图片的分辨率和你在控制台 Thumbnail Size 中配置的 width 和 height 不一致，SDK 会对该图片进行压缩。压缩原则维持图片的宽高比，是在控制台 width 和 height 的值为缩略图宽高中的更大值，然后按宽高比计算另一个值。以控制台中配置的 width 和 height 为 200 x 200 为例：
 * 
 *   如果 aData 的分辨率为 200 x 400 (1:2)，则生成的缩略图分辨率为 100 x 200。
 *   如果 aData 的分辨率为 600 x 300 (2:1)，则生成的缩略图分辨率为 200 x 100。
 * 
 * @param aThumbnailData 缩略图数据。该参数不会上传到服务器，只用于本地展示。
 * 
 * @Result 图片消息体实例。
 *
 *  \~english
 *  Initializes an image message body instance.
 *
 *  The image receiver will receive object thumbnail that generated based on sender's aData object.
 * 
 *  Adjusts thumbnail resolution on Hyphenate console -> "Thumbnail Size" -> width and height. Unit in px.
 *  ex. aData resolution 200 x 400 (1：2), thumbnail resolution setting (width x height) 200 x 200, then will generate thumbnail in 100 x 200
 *  ex. aData resolution 600 x 300 (2：1), thumbnail resolution setting (width x height) 200 x 200, then will generate thumbnail in 200 x 100
 *
 *  The image sender can obtain thumbnail from thumbnailLocalPath.
 * 
 *  The image receiver will get thumbnail stored under thumbnailRemotePath after a successful download automatically.
 *  However, if the automatic downloading failed, use the following method,
 *  downloadMessageThumbnail:progress:completion:
 *
 *  @param aData            The original image object in NSData format.
 *  @param aThumbnailData   The thumbnail in NSData format. Will not push to server, but only for local usage.
 *
 *  @result An image message body instance.
 */
- (instancetype)initWithData:(NSData *)aData
               thumbnailData:(NSData *)aThumbnailData;

@end
