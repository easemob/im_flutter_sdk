//
//  EMThreadManagerDelegate.h
//  HyphenateSDK
//
//  Created by 朱继超 on 2022/3/1.
//  Copyright © 2022 easemob.com. All rights reserved.
//

#ifndef EMThreadManagerDelegate_h
#define EMThreadManagerDelegate_h
#import "EMChatThread.h"
#import "EMChatThreadEvent.h"
NS_ASSUME_NONNULL_BEGIN
/*!
 *  \~chinese
 *  子区事件回调协议。
 *  
 *  \~english
 *  The message thread event callback protocol.
 */
@protocol EMThreadManagerDelegate <NSObject>

@optional
/*!
 *  \~chinese
 *  子区创建回调。
 * 
 *  @param event 子区创建事件 {@link EMChatThreadEvent}，包含子区信息。
 * 
 *  \~english
 *  Occurs when a message thread is created.
 * 
 *  @param event The message thread creation event {@link EMChatThreadEvent}, which contains the message thread information.
 */
- (void)onChatThreadCreate:(EMChatThreadEvent *)event;
/*!
 *  \~chinese
 *  子区更新回调。
 * 
 * 修改子区名称或在子区中添加或撤销回复消息时触发该回调。
 * 
 *  @param event 子区更新事件 {@link EMChatThreadEvent}，包含子区信息。
 * 
 *  \~english
 * Occurs when the message thread is updated.
 * 
 * This callback is triggered when the message thread name is changed or a threaded reply is added or recalled.
 *  
 * @param event The message thread update event {@link EMChatThreadEvent}, which contains the message thread information.
 */
- (void)onChatThreadUpdate:(EMChatThreadEvent *)event;
/*!
 *  \~chinese
 *  子区解散回调。
 * 
 *  @param event 子区解散事件 {@link EMChatThreadEvent}，包含子区信息。
 * 
 *  \~english
 *  Occurs when the message thread is destroyed.
 * 
 *  @param event The message thread destruction event {@link EMChatThreadEvent}, which contains the message thread information.
 */
- (void)onChatThreadDestroy:(EMChatThreadEvent *)event;
/*!
 *  \~chinese
 *  用户被踢出子区后收到的回调。
 * 
 *  @param event 用户移除事件 {@link EMChatThreadEvent}，包含子区信息。
 * 
 *  \~english
 *  Occurs when a user is kicked out of the message thread.
 * 
 *  @param event The user removal event {@link EMChatThreadEvent}, which contains the message thread information.
 */
- (void)onUserKickOutOfChatThread:(EMChatThreadEvent *)event;

@end

NS_ASSUME_NONNULL_END

#endif /* EMThreadManagerDelegate_h */
