//
//  LightSceneListTableViewController.m
//  tuya-bizbundle-ios-sample-objc_Example
//
//  Created by fiteen on 2022/8/30.
//  Copyright © 2022 Tuya. All rights reserved.
//

#import "LightSceneListTableViewController.h"
#import "Home.h"
#import "Alert.h"
#import <TYModuleServices/TYModuleServices.h>
#import <TuyaSmartBizCore/TuyaSmartBizCore.h>
#import <TuyaSmartDeviceKit/TuyaSmartDeviceKit.h>
#import <TuyaLightSceneKit/TuyaLightSceneModel.h>

@interface LightSceneListTableViewController ()
@property (strong, nonatomic) TuyaSmartHome *home;
@property (strong, nonatomic) NSArray *lightSceneList;
@end

@implementation LightSceneListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([Home getCurrentHome]) {
        self.home = [TuyaSmartHome homeWithHomeId:[Home getCurrentHome].homeId];
        [self updateHomeDetail];
        [[TuyaSmartBizCore sharedInstance] registerService:@protocol(TYFamilyProtocol) withInstance:self];
        [[TuyaSmartBizCore sharedInstance] registerService:@protocol(TYSmartHomeDataProtocol) withInstance:self];
        [[TuyaSmartBizCore sharedInstance] registerService:@protocol(TYSmartHouseIndexProtocol) withInstance:self];
        
        // 监听到灯光场景变化，通知刷新列表
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadLightSceneList) name:@"kNotificationLightSceneListUpdate" object:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.alpha = 1;
    [self.navigationController.navigationItem setHidesBackButton:NO];
    [self.navigationItem setHidesBackButton:NO];
    [self.navigationController.navigationBar.backItem setHidesBackButton:NO];
}

- (void)loadLightSceneList {
    id<TYLightSceneBizProtocol> impl = [[TuyaSmartBizCore sharedInstance] serviceOfProtocol:@protocol(TYLightSceneBizProtocol)];
    [impl getLightSceneListWithSuccess:^(NSArray<TuyaLightSceneModel *> * _Nonnull scenes) {
        self.lightSceneList = scenes;
        [self.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"get light scene list failure: %@", error);
    }];
}

- (BOOL)homeAdminValidation {
    return YES;
}

- (TuyaSmartHome *)getCurrentHome {
    return self.home;
}

- (long long)currentFamilyId {
    return self.home.homeModel.homeId;
}

- (void)updateHomeDetail {
    [self.home getHomeDataWithSuccess:^(TuyaSmartHomeModel *homeModel) {
        [self loadLightSceneList];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:self withTitle:NSLocalizedString(@"Failed to Fetch Home", @"") message:error.localizedDescription];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lightSceneList?self.lightSceneList.count:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"light-scene-list-cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"light-scene-list-cell"];
    }
    cell.textLabel.text = ((TuyaLightSceneModel *)self.lightSceneList[indexPath.row]).name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TuyaLightSceneModel *scene = self.lightSceneList[indexPath.row];
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Choose an Action", @"") message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *executeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Execute the Lighting Scenario", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        id<TYLightSceneBizProtocol> impl = [[TuyaSmartBizCore sharedInstance] serviceOfProtocol:@protocol(TYLightSceneBizProtocol)];
        [impl executeLightScene:scene success:^(BOOL success) {
            [Alert showBasicAlertOnVC:[UIApplication sharedApplication].keyWindow.rootViewController withTitle:NSLocalizedString(@"Successfully Executed", @"") message:@""];
        } failure:^(NSError * _Nonnull error) {
            [Alert showBasicAlertOnVC:[UIApplication sharedApplication].keyWindow.rootViewController withTitle:NSLocalizedString(@"Failed Executed", @"") message:error.localizedDescription];
        }];
    }];
    UIAlertAction *detailAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Edit the Lighting Scenario", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        id<TYLightSceneProtocol> impl = [[TuyaSmartBizCore sharedInstance] serviceOfProtocol:@protocol(TYLightSceneProtocol)];
        [impl editLightScene:self.lightSceneList[indexPath.row]];
    }];
    [alertC addAction:executeAction];
    [alertC addAction:detailAction];
    [self presentViewController:alertC animated:YES completion:nil];
}

- (NSArray *)lightSceneList {
    if (!_lightSceneList) {
        _lightSceneList = [[NSArray alloc] init];
    }
    return _lightSceneList;
}

@end
