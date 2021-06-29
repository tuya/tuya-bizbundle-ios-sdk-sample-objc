//
//  DeviceListTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "DeviceListTableViewController.h"
#import "Home.h"
#import "Alert.h"
#import <TuyaSmartBizCore/TuyaSmartBizCore.h>
#import <TYModuleServices/TYModuleServices.h>
#import <TuyaSmartCameraKit/TuyaSmartCameraKit.h>

@interface DeviceListTableViewController () <TuyaSmartHomeDelegate>
@property (strong, nonatomic) TuyaSmartHome *home;
@end

@implementation DeviceListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([Home getCurrentHome]) {
        self.home = [TuyaSmartHome homeWithHomeId:[Home getCurrentHome].homeId];
        self.home.delegate = self;
        [self updateHomeDetail];
        [[TuyaSmartBizCore sharedInstance] registerService:@protocol(TYSmartHomeDataProtocol) withInstance:self];
        [[TuyaSmartBizCore sharedInstance] registerService:@protocol(TYRNCameraProtocol) withInstance:self];
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
    [self.home getHomeDetailWithSuccess:^(TuyaSmartHomeModel *homeModel) {
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:self withTitle:NSLocalizedString(@"Failed to Fetch Home", @"") message:error.localizedDescription];
    }];
}

- (TuyaSmartHome *)getCurrentHome {
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
    TuyaSmartDeviceModel *deviceModel = self.home.deviceList[indexPath.row];
    cell.textLabel.text = deviceModel.name;
    cell.detailTextLabel.text = deviceModel.isOnline ? NSLocalizedString(@"Online", @"") : NSLocalizedString(@"Offline", @"");
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TuyaSmartDeviceModel *deviceModel = self.home.deviceList[indexPath.row];
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
    }
}

- (void)gotoDeviceDetailDetailViewControllerWithDevice:(TuyaSmartDeviceModel *)deviceModel {
    id<TYDeviceDetailProtocol> impl = [[TuyaSmartBizCore sharedInstance] serviceOfProtocol:@protocol(TYDeviceDetailProtocol)];
    [impl gotoDeviceDetailDetailViewControllerWithDevice:deviceModel group:nil];
}

- (void)getPanelViewControllerWithDeviceModel:(TuyaSmartDeviceModel *)deviceModel {
    id<TYPanelProtocol> impl = [[TuyaSmartBizCore sharedInstance] serviceOfProtocol:@protocol(TYPanelProtocol)];
    [impl getPanelViewControllerWithDeviceModel:deviceModel initialProps:nil contextProps:nil completionHandler:^(__kindof UIViewController * _Nullable panelViewController, NSError * _Nullable error) {
        [self.navigationController pushViewController:panelViewController animated:YES];
    }];
}

- (void)checkFirmwareUpgrade:(TuyaSmartDeviceModel *)deviceModel {
    id<TYOTAGeneralProtocol> otaImp = [[TuyaSmartBizCore sharedInstance] serviceOfProtocol:@protocol(TYOTAGeneralProtocol)];
        
    if ([otaImp isSupportUpgrade:deviceModel]) {
        [otaImp checkFirmwareUpgrade:deviceModel isManual:YES theme:TYOTAControllerWhiteTheme];
    } else {
        [Alert showBasicAlertOnVC:self withTitle:@"" message:NSLocalizedString(@"Already the latest version", nil)];
    }
}

- (void)cameraRNPanelViewControllerWithDeviceId:(TuyaSmartDeviceModel *)deviceModel {
    if (!deviceModel.isIPCDevice) {
        [self showIsNotIpcAlert];
        return;
    }
    
    id<TYPanelProtocol> impl = [[TuyaSmartBizCore sharedInstance] serviceOfProtocol:@protocol(TYPanelProtocol)];
    [impl getPanelViewControllerWithDeviceModel:deviceModel initialProps:nil contextProps:nil completionHandler:^(__kindof UIViewController * _Nullable panelViewController, NSError * _Nullable error) {
        [self.navigationController pushViewController:panelViewController animated:YES];
    }];
}

- (void)deviceGotoCameraNewPlayBackPanel:(TuyaSmartDeviceModel *)deviceModel {
    if (!deviceModel.isIPCDevice) {
        [self showIsNotIpcAlert];
        return;
    }
    
    id<TYCameraProtocol> impl = [[TuyaSmartBizCore sharedInstance] serviceOfProtocol:@protocol(TYCameraProtocol)];
    [impl deviceGotoCameraNewPlayBackPanel:deviceModel];
}

- (void)deviceGotoCameraCloudStoragePanel:(TuyaSmartDeviceModel *)deviceModel {
    if (!deviceModel.isIPCDevice) {
        [self showIsNotIpcAlert];
        return;
    }
    
    id<TYCameraProtocol> impl = [[TuyaSmartBizCore sharedInstance] serviceOfProtocol:@protocol(TYCameraProtocol)];
    [impl deviceGotoCameraCloudStoragePanel:deviceModel];
}

- (void)deviceGotoCameraMessageCenterPanel:(TuyaSmartDeviceModel *)deviceModel {
    if (!deviceModel.isIPCDevice) {
        [self showIsNotIpcAlert];
        return;
    }
    
    id<TYCameraProtocol> impl = [[TuyaSmartBizCore sharedInstance] serviceOfProtocol:@protocol(TYCameraProtocol)];
    [impl deviceGotoCameraMessageCenterPanel:deviceModel];
}

- (void)deviceGotoPhotoLibrary:(TuyaSmartDeviceModel *)deviceModel {
    if (!deviceModel.isIPCDevice) {
        [self showIsNotIpcAlert];
        return;
    }
    
    id<TYCameraProtocol> impl = [[TuyaSmartBizCore sharedInstance] serviceOfProtocol:@protocol(TYCameraProtocol)];
    [impl deviceGotoPhotoLibrary:deviceModel];
}

- (void)showIsNotIpcAlert {
    [Alert showBasicAlertOnVC:self withTitle:@"" message:NSLocalizedString(@"This is not a IPC device", @"")];
}

- (void)homeDidUpdateInfo:(TuyaSmartHome *)home {
    [self.tableView reloadData];
}

-(void)home:(TuyaSmartHome *)home didAddDeivice:(TuyaSmartDeviceModel *)device {
    [self.tableView reloadData];
}

-(void)home:(TuyaSmartHome *)home didRemoveDeivice:(NSString *)devId {
    [self.tableView reloadData];
}

-(void)home:(TuyaSmartHome *)home deviceInfoUpdate:(TuyaSmartDeviceModel *)device {
    [self.tableView reloadData];
}

-(void)home:(TuyaSmartHome *)home device:(TuyaSmartDeviceModel *)device dpsUpdate:(NSDictionary *)dps {
    [self.tableView reloadData];
}
@end
