//
//  EMGroupManagerWrapper.h
//  FlutterTest
//
//  Created by 杜洁鹏 on 2019/10/17.
//  Copyright © 2019 Easemob. All rights reserved.
//

#import "EMWrapper.h"
#import "EMClientWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface EMGroupManagerWrapper : EMWrapper
@property (nonatomic, weak) EMClientWrapper *clientWrapper;
@end

NS_ASSUME_NONNULL_END
