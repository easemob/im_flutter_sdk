//
//  EMGroupManagerWrapper.h
//  FlutterTest
//
//  Created by 杜洁鹏 on 2019/10/17.
//  Copyright © 2019 Easemob. All rights reserved.
//

#import "Wrapper.h"
#import "ClientWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupManagerWrapper : Wrapper
@property (nonatomic, weak) ClientWrapper *clientWrapper;
@end

NS_ASSUME_NONNULL_END
