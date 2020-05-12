//
//  ConfInviteUsersViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/20.
//  Copyright © 2018 XieYajie. All rights reserved.
//

//#import "EMRefreshViewController.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef enum {
    ConfInviteTypeUser = 0,
    ConfInviteTypeGroup,
    ConfInviteTypeChatroom,
} ConfInviteType;

@interface ConfInviteUsersViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray *dataArray;

@property (copy) void (^doneCompletion)(NSArray *aInviteUsers);

- (instancetype)initWithType:(ConfInviteType)aType
                    isCreate:(BOOL)aIsCreate
                excludeUsers:(NSArray *)aExcludeUsers
           groupOrChatroomId:(NSString *)aGorcId;

@end
