#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <Hyphenate/Hyphenate.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
    
//    // 初始化SDK
//    EMOptions *options = [EMOptions optionsWithAppkey:@"easemob-demo#chatdemoui"];
//    options.enableConsoleLog = YES;
//    options.apnsCertName = @"ebsApnsTest";
//    [[EMClient sharedClient] initializeSDKWithOptions:options];
//
//    EMError *aError = [[EMClient sharedClient] loginWithUsername:@"fdh3333" password:@"123"];
//    if (!aError) {
//        NSLog(@"登录成功-----");
//    } else {
//        NSLog(@"登录失败----%@", aError.errorDescription);
//    }
//
//    [[EMClient sharedClient].groupManager getJoinedGroupsFromServerWithPage:0 pageSize:-1 completion:^(NSArray *aList, EMError *aError) {
//        NSArray *groups = [self EMGroupsArrayWithDictionaryArray:aList];
//        NSLog(@"groups---%@", groups);
//    }];
    
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

//- (NSDictionary *)dictionaryWithGroup:(EMGroup *)group
//{
//    EMGroupOptions *options = group.setting;
//    EMGroupStyle style = options.style;
//    NSString *groupStyle;
//    if (style == EMGroupStylePrivateOnlyOwnerInvite) {
//        groupStyle = @"PrivateOnlyOwnerInvite";
//    } else if (style == EMGroupStylePrivateMemberCanInvite) {
//        groupStyle = @"PrivateMemberCanInvite";
//    } else if (style == EMGroupStylePublicJoinNeedApproval) {
//        groupStyle = @"PublicJoinNeedApproval";
//    } else {
//        groupStyle = @"PublicOpenJoin";
//    }
//    NSDictionary *groupSettings = @{@"style":groupStyle,
//                                    @"maxUsersCount":@(options.maxUsersCount),
//                                    @"IsInviteNeedConfirm":@(options.IsInviteNeedConfirm),
//                                    @"ext":options.ext};
//
//    EMGroupPermissionType permissionType = group.permissionType;
//    NSString *type;
//    if (permissionType == EMGroupPermissionTypeNone) {
//        type = @"None";
//    } else if (permissionType == EMGroupPermissionTypeMember) {
//        type = @"Member";
//    } else if (permissionType == EMGroupPermissionTypeAdmin) {
//        type = @"Admin";
//    } else {
//        type = @"Owner";
//    }
//
//    NSDictionary *groupDict = @{@"groupId":group.groupId,
//                                @"subject":group.subject,
//                                @"description":group.description,
//                                @"announcement":group.announcement,
//                                @"setting":groupSettings,
//                                @"owner":group.owner,
//                                @"adminList":group.adminList,
//                                @"memberList":group.memberList,
//                                @"blacklist":group.blacklist,
//                                @"muteList":group.muteList,
//                                @"sharedFileList":group.sharedFileList,
//                                @"isPushNotificationEnabled":@(group.isPushNotificationEnabled),
//                                @"isPublic":@(group.isPublic),
//                                @"isBlocked":@(group.isBlocked),
//                                @"permissionType":type,
//                                @"occupants":group.occupants,
//                                @"occupantsCount":@(group.occupantsCount)};
//
//    return groupDict;
//}
//
//- (NSArray *)EMGroupsArrayWithDictionaryArray:(NSArray *)groupsArray
//{
//    NSMutableArray *groupsMutableArray = [NSMutableArray array];
//    for (EMGroup *group in groupsArray) {
//        [groupsMutableArray addObject:[self dictionaryWithGroup:group]];
//    }
//    return [NSArray arrayWithArray:groupsMutableArray];
//}

@end
