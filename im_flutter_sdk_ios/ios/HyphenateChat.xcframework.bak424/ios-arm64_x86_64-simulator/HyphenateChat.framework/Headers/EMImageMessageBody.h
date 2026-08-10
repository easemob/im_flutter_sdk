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
 *  创建的图片消息体。
 * 
 *  可以调用 `(instancetype)initWithData:displayName:` 方法生成图片消息体。
 *  
 *  Note: SDK 会根据压缩率 `compressRatio 发送消息。
 *
 *  \~english
 *  The image message body.
 * 
 *  You can create an image message body by calling `(instancetype)initWithData:displayName:`.
 * 
 *  Note: SDK will compress the image based on the `compressRatio` attribute when delivering the image.
 */
@interface EMImageMessageBody : EMFileMessageBody

/**
 *  \~chinese
 *  图片附件的尺寸。
 *
 *  \~english
 *  The image dimensions.
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
 *  缩略图的本地路径。
 * 
 *  发送方可以根据该属性获取缩略本地路径。调用 `imageWithContentsOfFile` 方法，传入 `thumbnailLocalPath` 即可获取缩略图的数据。
 * 
 *  UIImage *image = [UIImage imageWithContentsOfFile:thumbnailLocalPath];
 *
 *  \~english
 *  The local path of the thumbnail.
 * 
 *  The sender can obtain the local path of the thumbnail via this property, and read the thumbnail data by calling the `imageWithContentsOfFile:` method and passing `thumbnailLocalPath`.
 * 
 *  UIImage *image = [UIImage imageWithContentsOfFile:thumbnailLocalPath];
 */
@property (nonatomic, copy) NSString *thumbnailLocalPath;

/**
 *  \~chinese
 *  缩略图在服务器的路径。
 * 
 *  接收方可以通过该属性获取缩略图服务器路径。
 *
 *  \~english
 *  The URL path of the thumbnail of the server.
 *  
 *  The message recipient can obtain the remote path of the thumbnail with this property.
 */
@property (nonatomic, copy) NSString *thumbnailRemotePath;

/**
 *  \~chinese
 *  缩略图的密钥。
 * 
 *  下载缩略图时用户需要提供密钥进行校验。
 *
 *  \~english
 *  The secret key for the thumbnail. 
 * 
 *  A key is required for verification when downloading thumbnail.
 */
@property (nonatomic, copy) NSString *thumbnailSecretKey;

/**
 *  \~chinese
 *  缩略图的尺寸。
 *
 *  \~english
 *  The thumbnail dimensions.
 */
@property (nonatomic) CGSize thumbnailSize;

/**
 *  \~chinese
 *  缩略图大小, 以字节为单位。
 *
 *  \~english
 *  The thumbnail file size (in bytes).
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
 *  大图的本地路径。
 * 
 *  发送方可根据该属性获取大图的本地路径。调用 `imageWithContentsOfFile` 方法，传入该参数即可获取大图的数据。
 *
 *  \~english
 *  The local path of the large image. 
 * 
 * The sender can obtain the local path of the large image via this property and read image data using `imageWithContentsOfFile`.
 */
@property (nonatomic, copy) NSString *bigImageLocalPath;
/**
 *  \~chinese
 *  大图在服务器上的 URL。
 * 
 *  接收方可通过该属性获取大图的服务器 URL。
 *
 *  \~english
 *  The URL of the large image on the server. 
 * 
 *  The recipient can get the remote URL of the large image via this property.
 */
@property (nonatomic, copy, readonly) NSString *bigImageRemotePath;
/**
 *  \~chinese
 *  大图下载状态。
 *
 *  \~english
 *  The download status of the large image.
 */
@property(nonatomic)EMDownloadStatus bigImageDownloadStatus;

/**
 *  \~chinese
 *  图片是否为 GIF 文件。
 *
 *  \~english
 *  Whether the image is a GIF file.
 */
@property (nonatomic) BOOL isGif;
/**
 *  \~chinese
 *  发送方是否发送原图。
 * 
 *  发送方可以根据该属性来决定是发送原图还是大图（压缩图）。
 * 
 *  接收方可以根据该属性来判断 `remotePath` 指向的是原图还是大图（压缩图）。
 *
 *  \~english
 *  Whether the sender sends the original image. 
 * 
 *  - `true`：The sender sends the original image.
 *  - `false`：The sender sends the large image that is a compressed image.
 * 
 *  For the sender, this property specifies whether to send the original image or large image (compressed image).
 * 
 *  For the recipient, it indicates whether remotePath refers to the original image or the large image (compressed image).
 */
@property (nonatomic) BOOL isOriginalImage;

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
               thumbnailData:(NSData *)aThumbnailData __deprecated_msg("Use -initWithLocalPath:displayName: instead");

/**
 *  \~chinese
 *  初始化 GIF 图片消息体。
 *
 *  @param aGifFilePath   GIF 图片本地路径。
 *  @param aDisplayName GIF 图片显示名称（不包含路径）。
 *
 *  @result GIF 消息体实例。
 *
 *  \~english
 *  Initializes a GIF message instance.
 *
 *  @param aLocalPath   The path of the GIF file attachment in the local device.
 *  @param aDisplayName The display name (excluding the path) of the GIF file attachment.
 *
 *  @result The GIF file message instance.
 */
- (instancetype)initWithGifFilePath:(NSString*)aGifFilePath
                        displayName:(NSString*)aDisplayName;

@end
