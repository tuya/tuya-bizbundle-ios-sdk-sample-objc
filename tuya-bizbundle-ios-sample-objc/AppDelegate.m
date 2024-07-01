//
//  AppDelegate.m
//  tuya-bizbundle-ios-sample-objc
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <ThingSmartBizCore/ThingSmartBizCore.h>
#import <ThingModuleServices/ThingSocialProtocol.h>
#import <UserNotifications/UserNotifications.h>
#import <ThingModuleServices/ThingSmartMarketingServiceProtocol.h>

#import <SVProgressHUD/SVProgressHUD.h>
#import "AppDelegate.h"
#import "AppKey.h"


@interface AppDelegate () <UINavigationControllerDelegate>

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
    
    [self registPush:application];
    
    if (@available(iOS 13, *)) {
        // If you are developing an app based on UIScene, you need to call [[ThingSmartBizCore sharedInstance] enableWithUIScene:scene]; in SceneDelegate scene:willConnectToSession:options: .
    }
    else {
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
    }
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
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

#pragma mark - Push

- (void)registPush:(UIApplication *)application {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
     [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert)
                           completionHandler:^(BOOL granted, NSError * _Nullable error) {
         if (!error) {
             NSLog(@"Request authorization succeeded!");
             [application registerForRemoteNotifications];
         }
     }];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [ThingSmartSDK sharedInstance].deviceToken = deviceToken;
    NSLog(@"set deviceToken:%@ ", deviceToken);
}

- (NSString * _Nullable)convertToJSON:(NSDictionary * _Nonnull)userInfo {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo
                                                       options:NSJSONWritingPrettyPrinted // This option makes the JSON string pretty-printed for readability
                                                         error:&error];
    
    // Check if the conversion was successful
    if (!jsonData) {
        NSLog(@"Failed to convert NSDictionary to JSON: %@", error);
        return nil;
    } else {
        // Convert JSON data to NSString
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"JSON string: %@", jsonString);
        return jsonString;
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    /*
     {
       "msgClassification" : "system_notification",
       "pushMsgTypeEnum" : "MARKETING",
       "clientId" : "mkuv8ajta7yshhqc9jwy",
       "uid" : "ay16812871762796dAB6",
       "baseLineVersion" : "3.0-IOS",
       "pkid" : 981912270,
       "link" : "testlool:\/\/tuyaweb?url=https%3A%2F%2Fwww.baidu.com&category=2&msgId=fd136886-1fc0-4f47-b7b1-d7bc9effccf3",
       "appId" : 815467959,
       "pushSign" : "b50b05e655843654ee3de0a51a6215eb",
       "pushRecordId" : "fd136886-1fc0-4f47-b7b1-d7bc9effccf3",
       "bizType" : 618091,
       "aps" : {
         "mutable-content" : 1,
         "alert" : {
           "title" : "xxx",
           "body" : "xxx"
         },
         "pic" : {
           "encrypted" : 0,
           "type" : "common",
           "thumbnail" : "",
           "bigImage" : ""
         },
         "tracking" : {
           "activity_name" : "pushxxx",
           "activity_id" : 162250
         },
         "sound" : "default"
       },
       "pushSerialNum" : "S1780506737397202944",
       "ts" : 1713340861068
     }
     */
    NSString *JSONString = [self convertToJSON:userInfo];
    
    id<ThingSmartMarketingServiceProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingSmartMarketingServiceProtocol)];
    if (impl) {
        [impl trackPushNotificationClickWithUserInfo:userInfo];
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Push Message" message:JSONString preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];

    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

@end
