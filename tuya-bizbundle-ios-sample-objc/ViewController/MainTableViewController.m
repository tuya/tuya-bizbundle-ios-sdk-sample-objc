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
#import <TYModuleServices/TYModuleServices.h>
#import <TuyaSmartBizCore/TuyaSmartBizCore.h>
#import "DeviceListTableViewController.h"

@interface MainTableViewController () <TuyaSmartHomeManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UILabel *currentHomeLabel;

@property (strong, nonatomic) TuyaSmartHomeManager *homeManager;

@end

@implementation MainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initiateCurrentHome];
    [[TuyaSmartBizCore sharedInstance] registerService:@protocol(TYSmartHomeDataProtocol) withInstance:self];
    [[TuyaSmartBizCore sharedInstance] registerService:@protocol(TYSmartHouseIndexProtocol) withInstance:self];
}

- (void)viewDidAppear:(BOOL)animated {
    if ([Home getCurrentHome]) {
        self.currentHomeLabel.text = [Home getCurrentHome].name;
    }
}

- (void)initiateCurrentHome {
    self.homeManager.delegate = self;
    [self.homeManager getHomeListWithSuccess:^(NSArray<TuyaSmartHomeModel *> *homes) {
        if (homes && homes.count > 0) {
            [Home setCurrentHome:homes.firstObject];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (TuyaSmartHome *)getCurrentHome {
    if (![Home getCurrentHome]) {
        return  nil;
    }
    
    TuyaSmartHome *home = [TuyaSmartHome homeWithHomeId:[Home getCurrentHome].homeId];
    return home;
}

- (BOOL)homeAdminValidation {
    return YES;
}

- (void)homeManager:(TuyaSmartHomeManager *)manager didAddHome:(TuyaSmartHomeModel *)homeModel {
    if (homeModel.dealStatus <= TYHomeStatusPending && homeModel.name.length > 0) {
        UIAlertController *alertController;
        alertController = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Invite you to join the family", @""), homeModel.name] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Join" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            TuyaSmartHome *home = [TuyaSmartHome homeWithHomeId:homeModel.homeId];
            [home joinFamilyWithAccept:YES success:^(BOOL result) {} failure:^(NSError *error) {}];
        }];
        
        UIAlertAction *refuseAction = [UIAlertAction actionWithTitle:@"Refuse" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            TuyaSmartHome *home = [TuyaSmartHome homeWithHomeId:homeModel.homeId];
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
        [[TuyaSmartUser sharedInstance] loginOut:^{
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
        default:
            break;
    }
}

- (void)gotoFamilyManagement {
    id<TYFamilyProtocol> impl = [[TuyaSmartBizCore sharedInstance] serviceOfProtocol:@protocol(TYFamilyProtocol)];
    [impl gotoFamilyManagement];
}

- (void)gotoCategoryViewController {
    id<TYActivatorProtocol> impl = [[TuyaSmartBizCore sharedInstance] serviceOfProtocol:@protocol(TYActivatorProtocol)];
    [impl gotoCategoryViewController];
  
    [impl activatorCompletion:TYActivatorCompletionNodeNormal customJump:NO completionBlock:^(NSArray * _Nullable deviceList) {
        NSLog(@"deviceList: %@",deviceList);
    }];
}

- (void)gotoAddScene {
    id<TYSmartSceneProtocol> impl = [[TuyaSmartBizCore sharedInstance] serviceOfProtocol:@protocol(TYSmartSceneProtocol)];
    [impl addAutoScene:^(TuyaSmartSceneModel *secneModel, BOOL addSuccess) {
            
    }];
}

- (void)gotoMessageCenterViewControllerWithAnimated {
    id<TYMessageCenterProtocol> impl = [[TuyaSmartBizCore sharedInstance] serviceOfProtocol:@protocol(TYMessageCenterProtocol)];
    [impl gotoMessageCenterViewControllerWithAnimated:YES];
}

- (void)gotoHelpCenter {
    id<TYHelpCenterProtocol> impl = [[TuyaSmartBizCore sharedInstance] serviceOfProtocol:@protocol(TYHelpCenterProtocol)];
    [impl gotoHelpCenter];
}

- (void)requestMallPage {
    id<TYMallProtocol> mallImpl = [[TuyaSmartBizCore sharedInstance] serviceOfProtocol:@protocol(TYMallProtocol)];
    [mallImpl checkIfMallEnableForCurrentUser:^(BOOL enable, NSError *error) {
      if (error) {
          [Alert showBasicAlertOnVC:self withTitle:@"" message:error.description];
      } else {
          // if enable is true
          if (enable) {
              [mallImpl requestMallPage:TYMallPageTypeHome completionBlock:^(__kindof UIViewController *page, NSError *error) {
                  [self.navigationController pushViewController:page animated:YES];
              }];
          } else {
              [Alert showBasicAlertOnVC:self withTitle:@"" message:NSLocalizedString(@"Mall is Unavailable", nil)];
          }
      }
    }];
}

- (void)gotoAmazonAlexa {
    id<TYValueAddedServiceProtocol> impl = [[TuyaSmartBizCore sharedInstance] serviceOfProtocol:@protocol(TYValueAddedServiceProtocol)];

    // 跳转到 Alexa 快绑页面
    [impl goToAmazonAlexaLinkViewControllerSuccess:^(BOOL result) {
        // 可以做 loading 操作
    } failure:^(NSError * _Nonnull error) {
        // 可以做 loading 操作
    }];
}

- (void)gotoAddLightScene {
    id<TYLightSceneProtocol> impl = [[TuyaSmartBizCore sharedInstance] serviceOfProtocol:@protocol(TYLightSceneProtocol)];
    [impl createNewLightScene];
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

- (TuyaSmartHomeManager *)homeManager {
    if (!_homeManager) {
        _homeManager = [[TuyaSmartHomeManager alloc] init];
    }
    return _homeManager;
}

@end
