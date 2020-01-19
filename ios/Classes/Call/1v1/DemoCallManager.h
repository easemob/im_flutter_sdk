//
//  DemoCallManager.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 22/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Hyphenate/Hyphenate.h>

@interface DemoCallManager : NSObject

+ (instancetype)sharedManager;

- (void)answerCall:(NSString *)aCallId;

- (void)endCallWithId:(NSString *)aCallId
               reason:(EMCallEndReason)aReason;

- (void)saveCallOptions;

- (void)_makeCallWithUsername:(NSString *)aUsername
             type:(EMCallType)aType
           record:(BOOL)isRecord
      mergeStream:(BOOL)isMerge
              ext:(NSString *)ext
isCustomVideoData:(BOOL)aIsCustomVideo
       completion:(void(^)(EMCallSession *aCallSession, EMError *aError))aCompletion;

@end
