//
//  MarketingDemoHomeViewController.m
//  tuya-bizbundle-ios-sample-objc_Example
//
//  Created by 尼奥 on 2024/3/27.
//  Copyright © 2024 Tuya. All rights reserved.
//

#import "MarketingDemoHomeViewController.h"
#import "DemoBaseTableViewController.h"

#import <ThingSmartBizCore/ThingSmartBizCore.h>
#import <UserNotifications/UserNotifications.h>
#import <ThingModuleServices/ThingSmartMarketingServiceProtocol.h>
@import ThingModuleServices;

@interface MarketingDemoHomeViewController ()<ThingSmartMarketingBannerDelegate>

@property (nonatomic, strong) id<ThingSmartMarketingServiceProtocol> impl;

@property (nonatomic, strong) UIViewController<ThingMarketingBannerViewControllerProtocol> *bannerVC;
@property (nonatomic, strong) UIViewController<ThingSmartSplashViewControllerProtocol> *splashVC;

/// Represents the currently selected tab, similar to a tab selection in UITabBarController.
@property (nonatomic, assign) ThingMarketingNativePage seletedPage;

@end

@implementation MarketingDemoHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.actionMapping = @[
        @[
            ACTION(@selector(obtainPermission)),
            ACTION(@selector(denyPermission)),
            ACTION(@selector(grantPermission)),
            ACTION(@selector(startFetch)),
            ACTION(@selector(endFetch)),
        ],
        @[
            ACTION(@selector(selectedPage)),
            ACTION(@selector(showPopover)),
            ACTION(@selector(showBanner)),
            ACTION(@selector(showSplash)),
            ACTION(@selector(showNotification)),
            ACTION(@selector(showInvite)),
        ],
    ];
    
    self.title = @"Home Page";
    
    self.impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingSmartMarketingServiceProtocol)];
    NSAssert(self.impl != nil, @"add `ThingSmartMarketingBizBundle` to Podfile fisrt.");
    
    ThingSmartMarketingServiceConfig *config = [ThingSmartMarketingServiceConfig sdkConfig];
    config.forceDataAuthorization = NO;
    config.shouldStartFetchDataImmediately = NO;
    self.seletedPage = config.defaultPage;
    [self.impl prepareWithConfig:config];
    
    [self tryFetch];
}

#pragma mark - Data

- (void)obtainPermission {
    [self.impl getAuthorityManagementStatusWithCompletion:^(BOOL success, NSError *_Nullable error, ThingSmartMarketingAuthority *authority) {
        NSLog(@"obtainPermission authority:%d", authority.isAuthorized);
        if (error) {
            [self alertFailWithError:error];
        }
        else {
            [self alertSuccessWithMessage:[NSString stringWithFormat:@"authority:%@", authority.isAuthorized ? @"Grant" : @"Deny"]];
        }
    }];
}

- (void)denyPermission {
    __weak typeof(self) weakSelf = self;
    [self.impl setAuthorityManagementStatusWithDataAuthorization:[ThingSmartMarketingAuthority deny] completion:^(BOOL success, NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        [self.impl getAuthorityManagementStatusWithCompletion:^(BOOL success, NSError *_Nullable error, ThingSmartMarketingAuthority *authority) {
            NSLog(@"denyPermission authority:%d", authority.isAuthorized);
            if (error) {
                [self alertFailWithError:error];
            }
            else {
                [self alertSuccessWithMessage:@"Deny"];
            }
        }];
    }];
}

- (void)grantPermission {
    __weak typeof(self) weakSelf = self;
    [self.impl setAuthorityManagementStatusWithDataAuthorization:[ThingSmartMarketingAuthority grant] completion:^(BOOL success, NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        [self.impl getAuthorityManagementStatusWithCompletion:^(BOOL success, NSError *_Nullable error, ThingSmartMarketingAuthority *authority) {
            NSLog(@"grantPermission authority:%d", authority.isAuthorized);
            if (error) {
                [self alertFailWithError:error];
            }
            else {
                [self alertSuccessWithMessage:@"Grant"];
            }
        }];
    }];
}

- (void)tryFetch {
    __weak typeof(self) weakSelf = self;
    [self.impl getAuthorityManagementStatusWithCompletion:^(BOOL success, NSError *_Nullable error, ThingSmartMarketingAuthority *authority) {
        NSLog(@"authority authority:%d", authority.isAuthorized);
        
        __strong typeof(weakSelf) self = weakSelf;
        if (!success) {
            [self alertFailWithError:error];
            return;
        }
        
        if (authority.isAuthorized) {
            [self startFetch];
        }
        else {
            [self alertAuthorityManagement];
        }
    }];
}

- (void)startFetch {
    __weak typeof(self) weakSelf = self;
    [self.impl startFetchDataWithCompletion:^(BOOL success, NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (success) {
            [self alertSuccessWithMessage:@"Fetched"];
        }
        else {
            [self alertFailWithError:error];
        }
    }];
}

- (void)endFetch {
    [self.impl endFetchData];
}

- (void)alertSuccessWithMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
        
    }];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)alertFailWithError:(NSError *_Nullable)error {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Fail"
                                                                             message:error ? [error description]: @"Unknow"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
        
    }];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)alertAuthorityManagement {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please Allow Data Access"
                                                                             message:@"Event tracking and marketing campaign activation require `dataAuthorization` to be enabled.\n\nOpt-in to `marketingPush` is necessary to receive marketing push notifications."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *grantedAction = [UIAlertAction actionWithTitle:@"Granted"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
        __weak typeof(self) weakSelf = self;
        [self.impl setAuthorityManagementStatusWithDataAuthorization:[ThingSmartMarketingAuthority grant] completion:^(BOOL success, NSError * _Nullable error) {
            __strong typeof(weakSelf) self = weakSelf;
            if (success) {
                [self alertSuccessWithMessage:@"Granted"];
                [self startFetch];
            }
            else {
                [self alertFailWithError:error];
            }
        }];
    }];
    [alertController addAction:grantedAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction *action) {
        
    }];
    
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UI

- (void)selectedPage {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Choose Page"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    NSArray *titles = @[@"Home", @"Mine", @"LeaveHomeOrMine"];
    for (NSString *title in titles) {
        [alertController addAction:[UIAlertAction actionWithTitle:title
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
            ThingMarketingNativePage selectedPage = [self pageForTitle:title];
            self.seletedPage = selectedPage;
            [self.impl togglesSelectedPage:selectedPage];
            self.title = [NSString stringWithFormat:@"%@ Page ✅", title];
        }]];
    }

    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (ThingMarketingNativePage)pageForTitle:(NSString *)title {
    if ([title isEqualToString:@"Home"]) {
        return ThingMarketingNativePageHome;
    } else if ([title isEqualToString:@"Mine"]) {
        return ThingMarketingNativePageMine;
    } else if ([title isEqualToString:@"LeaveHomeOrMine"]) {
        
        UIAlertController *alertController = [UIAlertController
        alertControllerWithTitle:@"Leave Home Page or Mine Page"
        message:@"Will not receive any marketing activity."
        preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
        return ThingMarketingNativePageNone;
    }
    else {
        NSAssert(NO, @"not support");
        return ThingMarketingNativePageNone;
    }
}

#pragma mark Popover

- (void)showPopover {    
    UIAlertController *alertController = [UIAlertController
    alertControllerWithTitle:@"How to display popover view ?"
    message:@"After calling startFetchDataWithCompletion:, the popover will be displayed automatically."
    preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark Banner

- (CGRect)bannerViewFrame {
    CGRect viewRect = self.view.bounds;
    CGFloat width = viewRect.size.width - 16 * 2;
    CGFloat height = 100;
    CGFloat x = 16;
    CGFloat y = (viewRect.size.height - height) / 2;
    return CGRectMake(x, y, width, height);
}

- (CGRect)hideBannerButtonFrame {
    CGRect bannerRect = [self bannerViewFrame];
    return CGRectMake(bannerRect.origin.x + bannerRect.size.width/3, bannerRect.size.height + bannerRect.origin.y + 30, bannerRect.size.width/3, 44);
}

- (void)showBanner {
    NSArray<id<ThingSmartMarketingSourceProtocol>> *_Nullable bannerDatas = [self.impl getBannerModelListWithShowPage:self.seletedPage limitCount:6];
    NSLog(@"banner datas count %ld", bannerDatas.count);
    if (bannerDatas.count == 0) {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Error"
                                              message: @"The banner has not been configured."
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    UIViewController<ThingMarketingBannerViewControllerProtocol> * bannerViewController = [self.impl getBannerViewController];
    /// 1. Add the child view controller to the parent view controller.
    [self addChildViewController:bannerViewController];
    
    UIView<ThingSmartMarketingBannerProtocol> * bannerView = [bannerViewController marketingBanner];
    bannerView.layer.cornerRadius = 12;
    bannerView.layer.masksToBounds = YES;
    bannerView.delegate = self;
    /// 2. Set the child view controller's view size and position.
    bannerView.frame = [self bannerViewFrame];
    [bannerView reloadDataList:bannerDatas];
    self.bannerVC = bannerViewController;
    
    /// 3. Add the child view controller's view to the parent view controller's view hierarchy.
    [self.view addSubview:bannerView];
    
    /// 4. Notify the child view controller that it has been added to the parent view controller.
    [bannerViewController didMoveToParentViewController:self];
        
    UIButton *removeBannerButton;
    removeBannerButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [removeBannerButton setTitle:@"Hide Banner" forState:UIControlStateNormal];
    [removeBannerButton setBackgroundColor:[UIColor lightGrayColor]];
    removeBannerButton.frame = [self hideBannerButtonFrame];
    [removeBannerButton addTarget:self action:@selector(hideBannerClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:removeBannerButton];
}

- (void)hideBannerClick:(UIButton *)sender {
    /// Remove the child view controller's view from the parent view controller's view hierarchy if it's added as a subview.
    [self.bannerVC.view removeFromSuperview];

    /// Remove the child view controller from the parent view controller.
    [self.bannerVC removeFromParentViewController];
    
    self.bannerVC = nil;
    [sender removeFromSuperview];
}

#pragma mark Banner - ThingSmartMarketingBannerDelegate

- (void)bannerView:(id)bannerView didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"didSelectItemAtIndex:%ld", index);
}

- (void)bannerViewDidClose {
    NSLog(@"bannerViewDidClose");
}

#pragma mark Splash

- (void)showSplash {
    id<ThingSmartMarketingSourceProtocol> splashData = [self.impl getSplashModel];
    if (splashData == nil) {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Error"
                                              message: @"The splash has not been configured."
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    UIViewController<ThingSmartSplashViewControllerProtocol> * splashVC = [self.impl getSplashViewControllerWithModel:splashData completion:^(BOOL isCanceled) {
        __strong typeof(weakSelf) self = weakSelf;
        [self.splashVC dismissViewControllerAnimated:YES completion:nil];
        self.splashVC = nil;
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Finish"
                                              message: isCanceled ? @"Splash is canceled.":@"Splash is clicked."
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    splashVC.modalPresentationStyle = UIModalPresentationFullScreen;
    self.splashVC = splashVC;
    [self presentViewController:splashVC animated:YES completion:nil];
}

#pragma mark Push

- (void)showNotification {
    /*
     Here's a draft of the help documentation that you can provide to your users on how to enable and display push notifications using the provided demo code:

     ---

     ## How to Enable and Display Push Notifications

     To ensure that your app can receive and display push notifications, please follow these steps:

     ### Step 1: Upload Your Push Certificate
     Before you can receive push notifications, you need to upload your Push.p12 certificate to the IoT platform at iot.tuya.com. This certificate is essential for the secure delivery of notifications to your device.

     ### Step 2: Enable Push Notifications in Xcode
     1. Open your project settings in Xcode.
     2. Select your App Target.
     3. Navigate to the "Capabilities" tab.
     4. Turn on the "Push Notifications" feature by toggling the switch to the ON position.

     ### Step 3: Register for Push Notifications
     Call the `registPush:` method within your app to register for push notifications. This method requests the user's permission to receive notifications and registers the app with APNs (Apple Push Notification service) if permission is granted.

     ```objc
     - (void)registPush:(UIApplication *)application {
         // Code to request authorization and register for remote notifications
     }
     ```

     ### Step 4: Register the Device Token
     When the `application:didRegisterForRemoteNotificationsWithDeviceToken:` callback is triggered, it means that the device has successfully registered with APNs. In this method, you should save the provided `deviceToken` to ensure that the device can receive push notifications.

     ```objc
     - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
         // Code to handle the registration of the device token
     }
     ```

     ### Step 5: Receive and Display Push Notifications
     When a push notification arrives, the `application:didReceiveRemoteNotification:fetchCompletionHandler:` callback is called. Inside this method, you can handle the received notification and present it to the user.

     ```objc
     - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
         // Code to handle the reception of a remote notification
     }
     ```

     By following these steps and using the provided demo code, your app will be able to register for, receive, and display push notifications to your users. Make sure to test the functionality to confirm that notifications are working as expected.

     ---

     Feel free to adjust the wording and the technical details to better fit the actual implementation and user interface of your app.
     */
    UIAlertController *alertController = [UIAlertController
    alertControllerWithTitle:@"How to display notification ?"
    message:@"See the implementation of registPush: in AppDelege."
    preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark Invite

- (void)showInvite {
    UIAlertController *alertController = [UIAlertController
    alertControllerWithTitle:@"How to display invite view ?"
    message:@"After calling startFetchDataWithCompletion:, the invite will be displayed automatically."
    preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}


@end
