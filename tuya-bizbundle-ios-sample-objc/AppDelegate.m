//
//  AppDelegate.m
//  tuya-bizbundle-ios-sample-objc
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <ThingSmartBizCore/ThingSmartBizCore.h>
#import <ThingModuleServices/ThingSocialProtocol.h>

#import <SVProgressHUD/SVProgressHUD.h>
#import "AppDelegate.h"
#import "AppKey.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Initialize TuyaSmartSDK
    [[ThingSmartSDK sharedInstance] startWithAppKey:APP_KEY secretKey:APP_SECRET_KEY];
    
    // Enable debug mode, which allows you to see logs.
    #ifdef DEBUG
    [[ThingSmartSDK sharedInstance] setDebugMode:YES];
    #else
    #endif
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.frame = [[UIScreen mainScreen] bounds];
    
    if ([ThingSmartUser sharedInstance].isLogin) {
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


#pragma mark - URL Scheme 

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    id<ThingSocialProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingSocialProtocol)];
    [impl application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if ([[url scheme] hasPrefix:@"wx"]) {
        id<ThingSocialProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingSocialProtocol)];
        return [impl application:app openURL:url options:options];
    }
    return YES;
}

@end
