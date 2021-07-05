//
//  SceneListTableViewController.m
//  tuya-bizbundle-ios-sample-objc_Example
//
//  Created by Gino on 2021/3/5.
//  Copyright © 2021 Tuya. All rights reserved.
//

#import "SceneListTableViewController.h"
#import "Home.h"
#import "Alert.h"
#import <TuyaSmartBizCore/TuyaSmartBizCore.h>
#import <TYModuleServices/TYModuleServices.h>
#import <TuyaSmartBizCore/TuyaSmartBizCore.h>
#import <TuyaSmartDeviceKit/TuyaSmartDeviceKit.h>

@interface SceneListTableViewController ()
@property (strong, nonatomic) TuyaSmartHome *home;
@property (strong, nonatomic) NSArray *sceneList;
@end

@implementation SceneListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([Home getCurrentHome]) {
        self.home = [TuyaSmartHome homeWithHomeId:[Home getCurrentHome].homeId];
        [self updateHomeDetail];
        [[TuyaSmartBizCore sharedInstance] registerService:@protocol(TYFamilyProtocol) withInstance:self];
        [[TuyaSmartBizCore sharedInstance] registerService:@protocol(TYSmartHomeDataProtocol) withInstance:self];
        [[TuyaSmartBizCore sharedInstance] registerService:@protocol(TYSmartHouseIndexProtocol) withInstance:self];
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

- (void)loadSceneList {
    id<TYSmartSceneBizProtocol> impl = [[TuyaSmartBizCore sharedInstance] serviceOfProtocol:@protocol(TYSmartSceneBizProtocol)];
    [impl getSceneListWithHomeId:[Home getCurrentHome].homeId withSuccess:^(NSArray<TuyaSmartSceneModel *> * _Nonnull scenes) {
        self.sceneList = scenes;
        [self.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"get scene list failure: %@", error);
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
    [self.home getHomeDetailWithSuccess:^(TuyaSmartHomeModel *homeModel) {
        [self loadSceneList];
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
    return self.sceneList?self.sceneList.count:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"scene-list-cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"scene-list-cell"];
    }
    cell.textLabel.text = ((TuyaSmartSceneModel *)self.sceneList[indexPath.row]).name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id<TYSmartSceneProtocol> impl = [[TuyaSmartBizCore sharedInstance] serviceOfProtocol:@protocol(TYSmartSceneProtocol)];
    [impl editScene:self.sceneList[indexPath.row]];
}

- (NSArray *)sceneList {
    if (!_sceneList) {
        _sceneList = [[NSArray alloc] init];
    }
    return _sceneList;
}
@end
