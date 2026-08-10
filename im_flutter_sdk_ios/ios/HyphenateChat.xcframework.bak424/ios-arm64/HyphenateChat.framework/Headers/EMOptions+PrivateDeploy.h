/**
 *  \~chinese
 *  @header   EMOptions+PrivateDeploy.h
 *  @abstract SDK 私有部署属性分类。
 *  @author   Hyphenate
 *  @version  3.0
 *
 *  \~english
 *  @header   EMOptions+PrivateDeploy.h
 *  @abstract The SDK setting options of private deployment.
 *  @author   Hyphenate
 *  @version  3.0
 */

#import "EMOptions.h"

@interface EMOptions (PrivateDeploy)

/**
 *  \~chinese 
 *  是否允许使用 DNS, 默认为 YES。
 *
 *  只能在 {@link EMClient initializeSDKWithOptions:} 中设置，不能在程序运行过程中动态修改。
 *
 *  \~english
 *  Whether to allow using DNS. The default value is YES.
 *
 *  Can only be set when initializing the SDK  {@link EMClient initializeSDKWithOptions:} , cannot be altered in runtime.
 */
@property (nonatomic, assign) BOOL enableDnsConfig;

/**
 *  \~chinese 
 *  Chat 服务器端口。
 *
 *  enableDnsConfig 为 NO 时有效。只能在 {@link EMClient initializeSDKWithOptions:} 中设置，不能在程序运行过程中动态修改。
 *
 *  \~english
 *  The chat server port.
 *
 *  This property is effective only when `enableDnsConfig` is `NO`.
 *  Can only be set when initializing the SDK with  {@link EMClient initializeSDKWithOptions:} , cannot be altered in runtime.
 */
@property (nonatomic, assign) int chatPort;

/**
 *  \~chinese 
 *  The chat 服务器地址。
 *
 *  enableDnsConfig 为 NO 时生效。只能在 {@link EMClient initializeSDKWithOptions:} 中设置，不能在程序运行过程中动态修改。
 *
 *  \~english
 *  The chat server.
 *
 *  This property is effective only when `enableDnsConfig` is `NO`.
 *  Can only be set when initializing the SDK with  {@link EMClient initializeSDKWithOptions:} , cannot be altered in runtime.
 */
@property (nonatomic, copy) NSString *chatServer;

/**
 *  \~chinese 
 *  REST 服务器地址。
 *
 *  enableDnsConfig 为 NO 时生效。只能在 {@link EMClient initializeSDKWithOptions:} 中设置，不能在程序运行过程中动态修改。
 *
 *  \~english
 *  The REST server.
 *
 *  This property is effective only when `enableDnsConfig` is `NO`.
 *  Can only be set when initializing the SDK with  {@link EMClient initializeSDKWithOptions:} , cannot be altered in runtime
 */
@property (nonatomic, copy) NSString *restServer;

/**
 *  \~chinese
 *  连接chatServer时，是否启用TLS加密，同时控制webSocketServer和chatServer。默认为NO。
 *
 *  enableDnsConfig 为 NO 时生效。只能在 {@link EMClient initializeSDKWithOptions:} 中设置，不能在程序运行过程中动态修改。
 *
 *  \~english
 *  Whether to enable TLS encryption when connecting to chatServer or webSocketServer.The default value is NO.
 *
 *  This property is effective only when `enableDnsConfig` is `NO`.
 *  Can only be set when initializing the SDK with  {@link EMClient initializeSDKWithOptions:} , cannot be altered in runtime
 */
@property (nonatomic, assign) BOOL enableTLSConnection;

/**
 *  \~chinese
 *  DNS URL 地址。
 *
 *  enableDnsConfig为YES时生效，只能在 {@link EMClient initializeSDKWithOptions:} 中设置，不能在程序运行过程中动态修改。
 *
 *  \~english
 *  The DNS url.
 *
 *  This property is effective only when `enableDnsConfig` is `YES`.
 *  Can only be set when initializing the SDK with  {@link EMClient initializeSDKWithOptions:} , cannot be altered in runtime.
 */
@property (nonatomic, copy) NSString *dnsURL;

/**
 *  \~chinese
 *  WebSocket 服务器地址。
 *
 *  该属性只在 `enableDnsConfig` 为 `NO` 时生效。
 * 
 *  该属性只能在 {@link EMClient initializeSDKWithOptions:} 中设置，不能在程序运行过程中动态修改。
 * 
 *  \~english
 *  The WebSocket server address
 *
 * This property takes effect only when `enableDnsConfig` is set to `NO`.
 * 
 * This property can only be set during SDK initialization via {@link EMClient initializeSDKWithOptions:} and cannot be changed dynamically during application runtime.
 */
@property (nonatomic, copy) NSString* _Nullable webSocketServer;

/**
 *  \~chinese
 *  WebSocket 服务器端口。
 * 
 *  该属性只在 `enableDnsConfig` 为 `NO` 时生效。
 * 
 *  该属性只能在 {@link EMClient initializeSDKWithOptions:} 中设置，不能在程序运行过程中动态修改。
 * 
 *  \~english
 *  The WebSocket server port.
 * 
 *  This property takes effect only when `enableDnsConfig` is set to `NO`.
 * 
 *  This property can only be set during SDK initialization via {@link EMClient initializeSDKWithOptions:} and cannot be changed dynamically during application runtime.
*/
@property (nonatomic, assign) int webSocketPort;
/**
 * \~chinese
 * 数据同步的 WebSocket 服务器地址。
 * 
 * 该属性只在 `enableDnsConfig` 为 `NO` 时生效。
 * 
 * 该属性只能在 {@link EMClient initializeSDKWithOptions:} 中设置，不能在程序运行过程中动态修改。
 *
 * \~english
 * The WebSocket server address for data synchronization.
 * 
 * This property takes effect only when `enableDnsConfig` is set to `NO`.
 * 
 * This property can only be set during SDK initialization via {@link EMClient initializeSDKWithOptions:} and cannot be changed dynamically during application runtime.
 */
@property (nonatomic, copy) NSString* _Nullable syncDataWSHost;
/**
 * \~chinese
 * 数据同步的 WebSocket 服务器端口。
 * 
 * 该属性只在 `enableDnsConfig` 为 `NO` 时生效。
 * 
 * 该属性只能在 {@link EMClient initializeSDKWithOptions:} 中设置，不能在程序运行过程中动态修改。
 *
 * \~english
 * The WebSocket server port for data synchronization.
 * 
 * This property takes effect only when `enableDnsConfig` is set to `NO`.
 * 
 * This property can only be set during SDK initialization via {@link EMClient initializeSDKWithOptions:} and cannot be changed dynamically during application runtime.
 */
@property (nonatomic, assign) int syncDataWSPort;

@end
