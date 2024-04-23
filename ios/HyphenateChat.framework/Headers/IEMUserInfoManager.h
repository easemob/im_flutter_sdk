//
//  IEMUserInfoManager.h
//  HyphenateSDK
//
//  Created by lixiaoming on 2021/3/17.
//  Copyright © 2021 easemob.com. All rights reserved.
//

/**
 *  \~chinese
 *  @header IEMUserInfoManager.h
 *  @abstract 用户属性操作类。
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header IEMUserInfoManager.h
 *  @abstract The user information operation class.
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>
#import "EMUserInfo.h"
#import "EMError.h"

@protocol IEMUserInfoManager <NSObject>

/**
 *  \~chinese
 *  设置自己的所有用户属性。
 *
 *  @param aUserData            要设置的用户属性信息。
 *  @param aCompletionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Sets all of the user's information.
 *
 *  @param aUserData           The user information data to set.
 *  @param aCompletionBlock    The completion block, which contains the error message if the method fails.
 */
- (void)updateOwnUserInfo:(EMUserInfo*_Nonnull)aUserData
               completion:(void (^_Nullable)(EMUserInfo*_Nullable aUserInfo,EMError *_Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  设置自己的指定用户属性。
 *
 *  @param aValue        要设置的用户属性信息。
 *  @param aType         要设置的用户属性类型。
 *  @param aCompletionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Sets a specific user information of the user.
 *
 *  @param aValue       The user information data to set.
 *  @param aType         The user information type to set.
 *  @param aCompletionBlock   The completion block, which contains the error message if the method fails.
 */
- (void)updateOwnUserInfo:(NSString*_Nullable )aValue
                 withType:(EMUserInfoType)aType
               completion:(void (^_Nullable )(EMUserInfo*_Nullable aUserInfo,EMError * _Nullable aError))aCompletionBlock;

/**
 *  \~chinese
 *  根据用户 ID 获取用户属性。
 *
 *  @param aUserIds  要获取用户属性的的用户 ID 列表。
 *  @param aCompletionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Gets the user information by user ID.
 *
 *  @param aUserIds            The user ID list.
 *  @param aCompletionBlock    The completion block, which contains the error message if the method fails.
 */
- (void)fetchUserInfoById:(NSArray<NSString*>*_Nonnull)aUserIds
               completion:(void (^_Nullable)(NSDictionary*_Nullable aUserDatas,EMError *_Nullable aError))aCompletionBlock;
/**
 *  \~chinese
 *  根据用户 ID 列表及属性类型列表获取用户指定属性。
 *
 *  @param aUserIds      要获取用户属性的的用户 ID 列表。
 *  @param aType         要获取哪些类型的用户属性列表。
 *  @param aCompletionBlock     该方法完成调用的回调。如果该方法调用失败，会包含调用失败的原因。
 *
 *  \~english
 *  Gets the specific user information by user ID.
 *
 *  @param aUserIds              The user ID list.
 *  @param aType                 The user information type list.
 *  @param aCompletionBlock      The completion block, which contains the error message if the method fails.
 */
- (void)fetchUserInfoById:(NSArray<NSString*>* _Nonnull)aUserIds
                     type:(NSArray<NSNumber*>*_Nonnull)aType
               completion:(void (^_Nullable)(NSDictionary*_Nullable aUserDatas,EMError *_Nullable aError))aCompletionBlock;
@end

