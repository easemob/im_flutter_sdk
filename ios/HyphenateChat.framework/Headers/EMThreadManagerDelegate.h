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
@protocol EMThreadManagerDelegate <NSObject>

@optional
/*!
 *  \~chinese
 *  创建子区后收到的回调
 *  @param event EMThreadEvent对象，包含子区信息
 *  \~english
 *  Callback received after subsection is created
 *  @param event EMThreadEvent对象，包含子区信息
 */
- (void)onChatThreadCreate:(EMChatThreadEvent *)event;
/*!
 *  \~chinese
 *  更新子区后收到的回调（包括更新子区最后一条消息，更新子区名称，撤回子区消息）
 *  @param event EMThreadEvent对象，包含子区信息
 *  \~english
 *  The callback received after updating the sub-area (including updating the last message of the sub-area, updating the sub-area name, and withdrawing the sub-area message)
 *  @param event EMThreadEvent对象，包含子区信息
 */
- (void)onChatThreadUpdate:(EMChatThreadEvent *)event;
/*!
 *  \~chinese
 *  销毁子区后收到的回调
 *  @param event EMThreadEvent对象，包含子区信息
 *  \~english
 *  The callback received after destroying the subsection
 *  @param event EMThreadEvent对象，包含子区信息
 */
- (void)onChatThreadDestroy:(EMChatThreadEvent *)event;
/*!
 *  \~chinese
 *  用户被踢出子区后收到的回调
 *  @param event EMThreadEvent对象，包含子区信息
 *  \~english
 *  Callback received after user is kicked out of subsection
 *  @param event EMThreadEvent对象，包含子区信息
 */
- (void)onUserKickOutOfChatThread:(EMChatThreadEvent *)event;
//MARK: - 自己离开子区可以在UI处理，多设备事件可以通过多设备代理中回调子区的代理处理（例如在线离开）
//MARK: - Leaving the sub-area by yourself can be handled in the UI, and multi-device events can be handled by the agent of the callback sub-area in the multi-device proxy (for example, leaving online)
@end

NS_ASSUME_NONNULL_END

#endif /* EMThreadManagerDelegate_h */
