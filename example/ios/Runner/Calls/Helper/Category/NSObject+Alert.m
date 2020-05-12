//
//  NSObject+Alert.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/22.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "NSObject+Alert.h"
#import <UIKit/UIKit.h>

@implementation NSObject (Alert)

- (void)_showAlertController:(UIAlertController *)aAlert
{
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [aAlert addAction:okAction];
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *rootViewController = window.rootViewController;
    aAlert.modalPresentationStyle = 0;
    [rootViewController presentViewController:aAlert animated:YES completion:nil];
}

- (void)showAlertWithMessage:(NSString *)aMsg
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"o(TωT)o" message:aMsg preferredStyle:UIAlertControllerStyleAlert];
    [self _showAlertController:alertController];
}

- (void)showAlertWithTitle:(NSString *)aTitle
                   message:(NSString *)aMsg
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:aTitle message:aMsg preferredStyle:UIAlertControllerStyleAlert];
    [self _showAlertController:alertController];
}

@end
