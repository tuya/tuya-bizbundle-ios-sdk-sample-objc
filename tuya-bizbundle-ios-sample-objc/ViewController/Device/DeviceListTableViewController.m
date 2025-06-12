//
//  DeviceListTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "DeviceListTableViewController.h"
#import "Home.h"
#import "Alert.h"
#import <ThingSmartBizCore/ThingSmartBizCore.h>
#import <ThingModuleServices/ThingModuleServices.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "DemoCameraVASRouteDispatcher.h"
#import <ThingSmartBusinessLibrary/UINavigationController+ThingTransation.h>

@interface DeviceListTableViewController () <ThingSmartHomeDelegate>
@property (strong, nonatomic) ThingSmartHome *home;
@property (strong, nonatomic) DemoCameraVASRouteDispatcher *VASRouteDispatcher;

@end

@implementation DeviceListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([Home getCurrentHome]) {
        self.home = [ThingSmartHome homeWithHomeId:[Home getCurrentHome].homeId];
        self.home.delegate = self;
        [self updateHomeDetail];
        [[ThingSmartBizCore sharedInstance] registerService:@protocol(ThingSmartHomeDataProtocol) withInstance:self];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.alpha = 1;
    [self.navigationController.navigationBar setBarTintColor:UIColor.whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationItem setHidesBackButton:NO];
    [self.navigationItem setHidesBackButton:NO];
    [self.navigationController.navigationBar.backItem setHidesBackButton:NO];
}

- (void)updateHomeDetail {
    [self.home getHomeDataWithSuccess:^(ThingSmartHomeModel *homeModel) {
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:self withTitle:NSLocalizedString(@"Failed to Fetch Home", @"") message:error.localizedDescription];
    }];
}

- (ThingSmartHome *)getCurrentHome {
    return self.home;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.home?self.home.deviceList.count:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"device-list-cell" forIndexPath:indexPath];
    ThingSmartDeviceModel *deviceModel = self.home.deviceList[indexPath.row];
    cell.textLabel.text = deviceModel.name;
    cell.detailTextLabel.text = deviceModel.isOnline ? NSLocalizedString(@"Online", @"") : NSLocalizedString(@"Offline", @"");
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ThingSmartDeviceModel *deviceModel = self.home.deviceList[indexPath.row];
    if (self.deviceListType == DeviceListTypeDeviceDetail) {
        [self gotoDeviceDetailDetailViewControllerWithDevice:deviceModel];
    } else if (self.deviceListType == DeviceListTypeDevicePanel) {
        [self getPanelViewControllerWithDeviceModel:deviceModel];
    } else if (self.deviceListType == DeviceListTypeDeviceOTA) {
        [self checkFirmwareUpgrade:deviceModel];
    } else if (self.deviceListType == DeviceListTypeIPCPanel) {
        [self cameraRNPanelViewControllerWithDeviceId:deviceModel];
    } else if (self.deviceListType == DeviceListTypeCameraPlayBackPanel) {
        [self deviceGotoCameraNewPlayBackPanel:deviceModel];
    } else if (self.deviceListType == DeviceListTypeCameraCloudStoragePanel) {
        [self deviceGotoCameraCloudStoragePanel:deviceModel];
    } else if (self.deviceListType == DeviceListTypeCameraMessageCenterPanel) {
        [self deviceGotoCameraMessageCenterPanel:deviceModel];
    } else if (self.deviceListType == DeviceListTypeCameraPhotoLibraryPanel) {
        [self deviceGotoPhotoLibrary:deviceModel];
    } else if (self.deviceListType == DeviceListTypeCameraVAS) {
        [self deviceGotoCameraVAS:deviceModel categoryCode:ThingCameraVASCategoryCodeCloud];
    }
}

- (void)gotoDeviceDetailDetailViewControllerWithDevice:(ThingSmartDeviceModel *)deviceModel {
    id<ThingDeviceDetailProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingDeviceDetailProtocol)];
    [impl gotoDeviceDetailDetailViewControllerWithDevice:deviceModel group:nil];
}

- (void)getPanelViewControllerWithDeviceModel:(ThingSmartDeviceModel *)deviceModel {
    id<ThingPanelProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingPanelProtocol)];
    [impl gotoPanelViewControllerWithDevice:deviceModel group:nil initialProps:nil contextProps:nil completion:^(NSError * _Nullable error) {
        NSLog(@"Error occurred while goto panel: %@", error.localizedDescription);
    }];
}

- (void)checkFirmwareUpgrade:(ThingSmartDeviceModel *)deviceModel {
    id<ThingOTAGeneralProtocol> otaImp = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingOTAGeneralProtocol)];
        
    if ([otaImp isSupportUpgrade:deviceModel]) {
        [otaImp checkFirmwareUpgrade:deviceModel isManual:YES theme:ThingOTAControllerWhiteTheme];
    } else {
        [Alert showBasicAlertOnVC:self withTitle:@"" message:NSLocalizedString(@"Already the latest version", nil)];
    }
}

- (void)cameraRNPanelViewControllerWithDeviceId:(ThingSmartDeviceModel *)deviceModel {
//    if (!deviceModel.isIPCDevice) {
//        [self showIsNotIpcAlert];
//        return;
//    }
    
    id<ThingPanelProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingPanelProtocol)];
    [impl getPanelViewControllerWithDeviceModel:deviceModel initialProps:nil contextProps:nil completionHandler:^(__kindof UIViewController * _Nullable panelViewController, NSError * _Nullable error) {
        [self.navigationController thing_pushViewController:panelViewController animated:YES];
    }];
}

- (void)deviceGotoCameraNewPlayBackPanel:(ThingSmartDeviceModel *)deviceModel {
//    if (!deviceModel.isIPCDevice) {
//        [self showIsNotIpcAlert];
//        return;
//    }
    
    id<ThingCameraProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingCameraProtocol)];
    [impl deviceGotoCameraNewPlayBackPanel:deviceModel];
}

- (void)deviceGotoCameraCloudStoragePanel:(ThingSmartDeviceModel *)deviceModel {
//    if (!deviceModel.isIPCDevice) {
//        [self showIsNotIpcAlert];
//        return;
//    }
    
    id<ThingCameraProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingCameraProtocol)];
    [impl deviceGotoCameraCloudStoragePanel:deviceModel];
}

- (void)deviceGotoCameraMessageCenterPanel:(ThingSmartDeviceModel *)deviceModel {
//    if (!deviceModel.isIPCDevice) {
//        [self showIsNotIpcAlert];
//        return;
//    }
    
    id<ThingCameraProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingCameraProtocol)];
    [impl deviceGotoCameraMessageCenterPanel:deviceModel];
}

- (void)deviceGotoPhotoLibrary:(ThingSmartDeviceModel *)deviceModel {
//    if (!deviceModel.isIPCDevice) {
//        [self showIsNotIpcAlert];
//        return;
//    }
    
    id<ThingCameraProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingCameraProtocol)];
    [impl deviceGotoPhotoLibrary:deviceModel];
}

- (void)deviceGotoCameraVAS:(ThingSmartDeviceModel *)deviceModel categoryCode:(ThingCameraVASCategoryCode)categoryCode {
    [SVProgressHUD showWithStatus:@""];
    [self.VASRouteDispatcher openCameraVASPageWithDeviceModel:deviceModel categoryCode:categoryCode completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

- (void)showIsNotIpcAlert {
    [Alert showBasicAlertOnVC:self withTitle:@"" message:NSLocalizedString(@"This is not a IPC device", @"")];
}

- (void)homeDidUpdateInfo:(ThingSmartHome *)home {
    [self.tableView reloadData];
}

-(void)home:(ThingSmartHome *)home didAddDeivice:(ThingSmartDeviceModel *)device {
    [self.tableView reloadData];
}

-(void)home:(ThingSmartHome *)home didRemoveDeivice:(NSString *)devId {
    [self.tableView reloadData];
}

-(void)home:(ThingSmartHome *)home deviceInfoUpdate:(ThingSmartDeviceModel *)device {
    [self.tableView reloadData];
}

-(void)home:(ThingSmartHome *)home device:(ThingSmartDeviceModel *)device dpsUpdate:(NSDictionary *)dps {
    [self.tableView reloadData];
}


- (DemoCameraVASRouteDispatcher *)VASRouteDispatcher {
    if (!_VASRouteDispatcher) {
        _VASRouteDispatcher = [[DemoCameraVASRouteDispatcher alloc] init];
    }
    return _VASRouteDispatcher;
}

@end
