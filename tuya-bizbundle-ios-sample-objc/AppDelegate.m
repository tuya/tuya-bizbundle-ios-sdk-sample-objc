//
//  AppDelegate.m
//  tuya-bizbundle-ios-sample-objc
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "AppDelegate.h"
#import "AppKey.h"
#import "SVProgressHUD.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Initialize TuyaSmartSDK
    [[TuyaSmartSDK sharedInstance] startWithAppKey:APP_KEY secretKey:APP_SECRET_KEY];
    
    // Enable debug mode, which allows you to see logs.
    #ifdef DEBUG
    [[TuyaSmartSDK sharedInstance] setDebugMode:YES];
    #else
    #endif
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.frame = [[UIScreen mainScreen] bounds];
    
    if ([TuyaSmartUser sharedInstance].isLogin) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"TuyaSmartMain" bundle:nil];
        UINavigationController *nav = [mainStoryboard instantiateInitialViewController];
        self.window.rootViewController = nav;
    } else {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *nav = [mainStoryboard instantiateInitialViewController];
        self.window.rootViewController = nav;
    }
    [[UIApplication sharedApplication] delegate].window = self.window;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
