//
//  MainTableViewController.m
//  tuya-bizbundle-ios-sample-objc_Example
//
//  Created by Gino on 2021/3/3.
//  Copyright © 2021 Tuya. All rights reserved.
//

#import "MainTableViewController.h"
#import "Alert.h"
#import "Home.h"
#import <ThingModuleServices/ThingModuleServices.h>
#import <ThingSmartBizCore/ThingSmartBizCore.h>
#import "DeviceListTableViewController.h"

@interface MainTableViewController () <ThingSmartHomeManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UILabel *currentHomeLabel;

@property (strong, nonatomic) ThingSmartHomeManager *homeManager;

@end

@implementation MainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initiateCurrentHome];
    [[ThingSmartBizCore sharedInstance] registerService:@protocol(ThingSmartHomeDataProtocol) withInstance:self];
    [[ThingSmartBizCore sharedInstance] registerService:@protocol(ThingSmartHouseIndexProtocol) withInstance:self];
}

- (void)viewDidAppear:(BOOL)animated {
    if ([Home getCurrentHome]) {
        self.currentHomeLabel.text = [Home getCurrentHome].name;
    }
}

- (void)initiateCurrentHome {
    self.homeManager.delegate = self;
    [self.homeManager getHomeListWithSuccess:^(NSArray<ThingSmartHomeModel *> *homes) {
        if (homes && homes.count > 0) {
            [Home setCurrentHome:homes.firstObject];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (ThingSmartHome *)getCurrentHome {
    if (![Home getCurrentHome]) {
        return  nil;
    }
    
    ThingSmartHome *home = [ThingSmartHome homeWithHomeId:[Home getCurrentHome].homeId];
    return home;
}

- (BOOL)homeAdminValidation {
    return YES;
}

- (void)homeManager:(ThingSmartHomeManager *)manager didAddHome:(ThingSmartHomeModel *)homeModel {
    if (homeModel.dealStatus <= ThingHomeStatusPending && homeModel.name.length > 0) {
        UIAlertController *alertController;
        alertController = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Invite you to join the family", @""), homeModel.name] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Join" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ThingSmartHome *home = [ThingSmartHome homeWithHomeId:homeModel.homeId];
            [home joinFamilyWithAccept:YES success:^(BOOL result) {} failure:^(NSError *error) {}];
        }];
        
        UIAlertAction *refuseAction = [UIAlertAction actionWithTitle:@"Refuse" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ThingSmartHome *home = [ThingSmartHome homeWithHomeId:homeModel.homeId];
            [home joinFamilyWithAccept:NO success:^(BOOL result) {} failure:^(NSError *error) {}];
        }];
        [alertController addAction:action];
        [alertController addAction:refuseAction];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController presentViewController:alertController animated:true completion:nil];
        });
    }
}

#pragma mark - IBAction

- (IBAction)logoutTapped:(UIButton *)sender {
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"You're going to log out this account.", @"User tapped the logout button.") preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Logout", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[ThingSmartUser sharedInstance] loginOut:^{
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *nav = [mainStoryboard instantiateInitialViewController];
            [UIApplication sharedApplication].keyWindow.rootViewController = nav;
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:self withTitle:@"Failed to Logout." message:error.localizedDescription];
        }];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
    
    alertViewController.popoverPresentationController.sourceView = sender;
    [alertViewController addAction:logoutAction];
    [alertViewController addAction:cancelAction];
    [self.navigationController presentViewController:alertViewController animated:YES completion:nil];
}


#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [self gotoFamilyManagement];
                    break;
                case 2:
                    [self logoutTapped:self.logoutButton];
                    break;
                default:
                    break;
            }
            break;
        case 1:
            [self gotoCategoryViewController];
            break;
        case 5:
            switch (indexPath.row) {
                case 0:
                    [self gotoAddScene];
                    break;
                default:
                    break;
            }
            break;
        case 6:
            [self gotoMessageCenterViewControllerWithAnimated];
            break;
        case 7:
            [self gotoHelpCenter];
            break;
        case 8:
            [self requestMallPage];
            break;
        case 10:
            [self gotoAmazonAlexa];
            break;
        case 11:
            switch (indexPath.row) {
                case 0:
                    [self gotoAddLightScene];
                    break;
                default:
                    break;
            }
            break;
        case 12:// share
            switch (indexPath.row) {
                case 0:
                    [self gotoShare];
                    break;
                default:break;
            }
            break;
        default:
            break;
    }
}

- (void)gotoFamilyManagement {
    id<ThingFamilyProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingFamilyProtocol)];
    [impl gotoFamilyManagement];
}

- (void)gotoCategoryViewController {
    id<ThingActivatorProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingActivatorProtocol)];
    [impl gotoCategoryViewController];
  
    [impl activatorCompletion:ThingActivatorCompletionNodeNormal customJump:NO completionBlock:^(NSArray * _Nullable deviceList) {
        NSLog(@"deviceList: %@",deviceList);
    }];
}

- (void)gotoAddScene {
    id<ThingSmartSceneProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingSmartSceneProtocol)];
    [impl addAutoScene:^(ThingSmartSceneModel *secneModel, BOOL addSuccess) {
            
    }];
}

- (void)gotoMessageCenterViewControllerWithAnimated {
    id<ThingMessageCenterProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingMessageCenterProtocol)];
    [impl gotoMessageCenterViewControllerWithAnimated:YES];
}

- (void)gotoHelpCenter {
    id<ThingHelpCenterProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingHelpCenterProtocol)];
    [impl gotoHelpCenter];
}

- (void)requestMallPage {
    id<ThingMallProtocol> mallImpl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingMallProtocol)];
    [mallImpl checkIfMallEnableForCurrentUser:^(BOOL enable, NSError *error) {
      if (error) {
          [Alert showBasicAlertOnVC:self withTitle:@"" message:error.description];
      } else {
          // if enable is true
          if (enable) {
              [mallImpl requestMallPage:ThingMallPageTypeHome completionBlock:^(__kindof UIViewController *page, NSError *error) {
                  [self.navigationController pushViewController:page animated:YES];
              }];
          } else {
              [Alert showBasicAlertOnVC:self withTitle:@"" message:NSLocalizedString(@"Mall is Unavailable", nil)];
          }
      }
    }];
}

- (void)gotoAmazonAlexa {
    id<ThingValueAddedServiceProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingValueAddedServiceProtocol)];

    // 跳转到 Alexa 快绑页面
    [impl goToAmazonAlexaLinkViewControllerSuccess:^(BOOL result) {
        // 可以做 loading 操作
    } failure:^(NSError * _Nonnull error) {
        // 可以做 loading 操作
    }];
}

- (void)gotoAddLightScene {
    id<ThingLightSceneProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingLightSceneProtocol)];
    [impl createNewLightScene];
}

- (void)gotoShare {

    id<ThingSocialProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingSocialProtocol)];

    static dispatch_once_t onceToken;
    dispatch_once (&onceToken, ^{
        [impl registerWithType:ThingSocialWechat appKey:@"wx90d34ffcd1b02f8e" appSecret:@"af87ac9961130297bed2ba8436be5b7e" universalLink:@"https://tuyaSmart.app.tuya.com"];
    });

    /// 分享文本
    if ([impl avaliableForType:ThingSocialWechat]) {
        ThingSocialShareModel *shareModel = [[ThingSocialShareModel alloc] initWithShareType:ThingSocialWechat];
        shareModel.content = @"content";
        shareModel.mediaType = ThingSocialShareContentText;
        [impl shareTo:ThingSocialWechat shareModel:shareModel success:^{

        } failure:^{

        }];
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"show-device-list-detail"] && [segue.destinationViewController isKindOfClass:[DeviceListTableViewController class]]) {
        ((DeviceListTableViewController*)(segue.destinationViewController)).deviceListType = DeviceListTypeDeviceDetail;
    }
    
    if ([segue.identifier isEqualToString:@"show-device-list-panel"] && [segue.destinationViewController isKindOfClass:[DeviceListTableViewController class]]) {
        ((DeviceListTableViewController*)(segue.destinationViewController)).deviceListType = DeviceListTypeDevicePanel;
    }
    
    if ([segue.identifier isEqualToString:@"show-device-list-ota"] && [segue.destinationViewController isKindOfClass:[DeviceListTableViewController class]]) {
        ((DeviceListTableViewController*)(segue.destinationViewController)).deviceListType = DeviceListTypeDeviceOTA;
    }
    
    if ([segue.identifier isEqualToString:@"show-ipc-panel"] && [segue.destinationViewController isKindOfClass:[DeviceListTableViewController class]]) {
        ((DeviceListTableViewController*)(segue.destinationViewController)).deviceListType = DeviceListTypeIPCPanel;
    }
    
    if ([segue.identifier isEqualToString:@"show-camera-playback-panel"] && [segue.destinationViewController isKindOfClass:[DeviceListTableViewController class]]) {
        ((DeviceListTableViewController*)(segue.destinationViewController)).deviceListType = DeviceListTypeCameraPlayBackPanel;
    }
    
    if ([segue.identifier isEqualToString:@"show-camera-cloud-storage-panel"] && [segue.destinationViewController isKindOfClass:[DeviceListTableViewController class]]) {
        ((DeviceListTableViewController*)(segue.destinationViewController)).deviceListType = DeviceListTypeCameraCloudStoragePanel;
    }
    
    if ([segue.identifier isEqualToString:@"show-camera-message-center-panel"] && [segue.destinationViewController isKindOfClass:[DeviceListTableViewController class]]) {
        ((DeviceListTableViewController*)(segue.destinationViewController)).deviceListType = DeviceListTypeCameraMessageCenterPanel;
    }
    
    if ([segue.identifier isEqualToString:@"show-camera-photo-library-panel"] && [segue.destinationViewController isKindOfClass:[DeviceListTableViewController class]]) {
        ((DeviceListTableViewController*)(segue.destinationViewController)).deviceListType = DeviceListTypeCameraPhotoLibraryPanel;
    }
}

- (ThingSmartHomeManager *)homeManager {
    if (!_homeManager) {
        _homeManager = [[ThingSmartHomeManager alloc] init];
    }
    return _homeManager;
}

@end
