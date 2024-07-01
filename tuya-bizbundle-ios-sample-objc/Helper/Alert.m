//
//  Alert.m
//  tuya-bizbundle-ios-sample-objc
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "Alert.h"

@implementation Alert

+ (void)showBasicAlertOnVC:(UIViewController *)vc withTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController;
    alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:action];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [vc presentViewController:alertController animated:true completion:nil];
    });
}

@end
