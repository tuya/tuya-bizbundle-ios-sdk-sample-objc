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
#import <ThingSmartBizCore/ThingSmartBizCore.h>
#import <ThingModuleServices/ThingModuleServices.h>
#import <ThingSmartBizCore/ThingSmartBizCore.h>
#import <ThingSmartDeviceKit/ThingSmartDeviceKit.h>

@interface SceneListTableViewController ()
@property (strong, nonatomic) ThingSmartHome *home;
@property (strong, nonatomic) NSArray *sceneList;
@end

@implementation SceneListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([Home getCurrentHome]) {
        self.home = [ThingSmartHome homeWithHomeId:[Home getCurrentHome].homeId];
        [self updateHomeDetail];
        [[ThingSmartBizCore sharedInstance] registerService:@protocol(ThingFamilyProtocol) withInstance:self];
        [[ThingSmartBizCore sharedInstance] registerService:@protocol(ThingSmartHomeDataProtocol) withInstance:self];
        [[ThingSmartBizCore sharedInstance] registerService:@protocol(ThingSmartHouseIndexProtocol) withInstance:self];
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
    id<ThingSmartSceneBizProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingSmartSceneBizProtocol)];
    [impl getSceneListWithHomeId:[Home getCurrentHome].homeId withSuccess:^(NSArray<ThingSmartSceneModel *> * _Nonnull scenes) {
        self.sceneList = scenes;
        [self.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"get scene list failure: %@", error);
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
    cell.textLabel.text = ((ThingSmartSceneModel *)self.sceneList[indexPath.row]).name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id<ThingSmartSceneProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingSmartSceneProtocol)];
    [impl editScene:self.sceneList[indexPath.row]];
}

- (NSArray *)sceneList {
    if (!_sceneList) {
        _sceneList = [[NSArray alloc] init];
    }
    return _sceneList;
}
@end
