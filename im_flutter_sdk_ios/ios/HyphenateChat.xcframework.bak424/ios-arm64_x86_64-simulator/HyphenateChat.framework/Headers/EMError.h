/**
 *  \~chinese
 *  @header EMError.h
 *  @abstract SDK 定义的错误类。
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header EMError.h
 *  @abstract The SDK defined error.
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#import "EMErrorCode.h"

/**
 *  \~chinese 
 *  SDK 定义的错误类。
 *
 *  \~english 
 *  The error defined by the SDK.
 */
@interface EMError : NSObject

/**
 *  \~chinese 
 *  错误码。
 *
 *  \~english 
 *  The error code.
 */
@property (nonatomic) EMErrorCode code;

/**
 *  \~chinese 
 *  错误描述。
 *
 *  \~english 
 *  The error description.
 */
@property (nonatomic, copy) NSString *errorDescription;


#pragma mark - Internal SDK

/**
 *  \~chinese 
 *  初始化错误实例。
 *
 *  @param aDescription  错误描述。
 *  @param aCode         错误码。
 *
 *  @result 错误实例。
 *
 *  \~english
 *  Initializes an error instance.
 *
 *  @param aDescription  The Error description.
 *  @param aCode         The Error code.
 *
 *  @result The Error instance.
 */
- (instancetype)initWithDescription:(NSString *)aDescription
                               code:(EMErrorCode)aCode;

/**
 *  \~chinese 
 *  创建错误实例。
 *
 *  @param aDescription  错误描述。
 *  @param aCode         错误码。
 *
 *  @result 错误实例。
 *
 *  \~english
 *  Creates an error instance.
 *
 *  @param aDescription  The Error description.
 *  @param aCode         The Error code.
 *
 *  @result The Error instance.
 */
+ (instancetype _Nonnull)errorWithDescription:(NSString * _Nullable)aDescription
                                         code:(EMErrorCode)aCode;

@end
