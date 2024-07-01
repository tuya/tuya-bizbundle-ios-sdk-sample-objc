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
#import <ThingModuleServices/ThingModuleServices.h>
#import <ThingSmartBizCore/ThingSmartBizCore.h>
#import <ThingSmartDeviceKit/ThingSmartDeviceKit.h>
//#import <ThingLightSceneKit/ThingLightSceneModel.h>

@interface LightSceneListTableViewController ()
@property (strong, nonatomic) ThingSmartHome *home;
@property (strong, nonatomic) NSArray *lightSceneList;
@end

@implementation LightSceneListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([Home getCurrentHome]) {
        self.home = [ThingSmartHome homeWithHomeId:[Home getCurrentHome].homeId];
        [self updateHomeDetail];
        [[ThingSmartBizCore sharedInstance] registerService:@protocol(ThingFamilyProtocol) withInstance:self];
        [[ThingSmartBizCore sharedInstance] registerService:@protocol(ThingSmartHomeDataProtocol) withInstance:self];
        [[ThingSmartBizCore sharedInstance] registerService:@protocol(ThingSmartHouseIndexProtocol) withInstance:self];
        
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
    id<ThingLightSceneBizProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingLightSceneBizProtocol)];
    [impl getLightSceneListWithSuccess:^(NSArray<ThingLightSceneModel *> * _Nonnull scenes) {
        self.lightSceneList = scenes;
        [self.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"get light scene list failure: %@", error);
    }];
}

- (BOOL)homeAdminValidation {
    return YES;
}

- (ThingSmartHome *)getCurrentHome {
    return self.home;
}

- (long long)currentFamilyId {
    return self.home.homeModel.homeId;
}

- (void)updateHomeDetail {
    [self.home getHomeDataWithSuccess:^(ThingSmartHomeModel *homeModel) {
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
    //cell.textLabel.text = ((ThingLightSceneModel *)self.lightSceneList[indexPath.row]).name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ThingLightSceneModel *scene = self.lightSceneList[indexPath.row];
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Choose an Action", @"") message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *executeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Execute the Lighting Scenario", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        id<ThingLightSceneBizProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingLightSceneBizProtocol)];
        [impl executeLightScene:scene success:^(BOOL success) {
            [Alert showBasicAlertOnVC:[UIApplication sharedApplication].keyWindow.rootViewController withTitle:NSLocalizedString(@"Successfully Executed", @"") message:@""];
        } failure:^(NSError * _Nonnull error) {
            [Alert showBasicAlertOnVC:[UIApplication sharedApplication].keyWindow.rootViewController withTitle:NSLocalizedString(@"Failed Executed", @"") message:error.localizedDescription];
        }];
    }];
    UIAlertAction *detailAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Edit the Lighting Scenario", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        id<ThingLightSceneProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingLightSceneProtocol)];
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
