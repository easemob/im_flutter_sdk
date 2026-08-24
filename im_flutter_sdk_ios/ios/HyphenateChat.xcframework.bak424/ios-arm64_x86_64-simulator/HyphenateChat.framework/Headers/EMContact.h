//
//  EMContact.h
//  HyphenateChat
//
//  Created by li xiaoming on 2023/8/30.
//  Copyright © 2023 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EMUserInfo;
/**
 *  \~chinese
 *  联系人信息接口。
 *
 *  \~english
 *  The contact information interface.
 */
@interface EMContact : NSObject <NSCoding>

/**
 *  \~chinese
 *  联系人用户 ID。
 *
 *  \~english
 *  The user ID of the contact.
 */
@property (nonatomic,strong,readonly) NSString* _Nonnull userId;

/**
 *  \~chinese
 *  联系人备注。
 *
 *  \~english
 *  The contact remark.
 */
@property (nonatomic,strong) NSString* _Nullable remark;

/**
 * \~chinese
 *  联系人信息对象。
 * 
 *  该对象包含联系人的用户属性，如昵称、头像等。
 *
 * \~english
 *  The contact information object.
 * 
 *  This object contains user attributes of the contact, such as the nickname and avatar.
 */
@property (nonatomic, strong, readonly) EMUserInfo *_Nullable userInfo;

/**
 * \~chinese
 * 联系人添加时间，单位为毫秒。
 *
 * \~english
 * The time (in milliseconds) when the contact was added.
 */
@property (nonatomic, assign, readonly) NSUInteger addTimestamp;
/**
 *  \~chinese
 *  初始化联系人对象。
 *
 *  @param userId  联系人用户 ID。
 *  @param remark  联系人备注。
 *  @param createAt 联系人添加时间，单位为毫秒。
 *
 *  @return 联系人对象。
 *
 *  \~english
 *  Initializes the contact object.
 *
 *  @param userId  The user ID of the contact.
 *  @param remark  The contact remark.
 *  @param createAt Contact addition time (in milliseconds).
 *  @return Contact object.
 */

- (instancetype)initWithUserId:(NSString* _Nonnull)userId remark:(NSString* _Nullable)remark createAt:(NSUInteger)createAt;
@end
