//
//  ServiceListViewController.m
//  tuya-bizbundle-ios-sample-objc_Example
//
//  Created by 尼奥 on 2025/4/7.
//  Copyright © 2025 Tuya. All rights reserved.
//

#import "ServiceListViewController.h"
#import <ThingModuleServices/ThingActivatedValueAddedServiceProtocol.h>
#import <ThingSmartBizCore/ThingSmartBizCore.h>

/*
 It is necessary to first depend on ThingAdvancedFunctionsBizBundle in the Podfile
*/

@interface ServiceListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<ThingValueAddedServiceModel *> *services;
@property (nonatomic, strong) id<ThingActivatedValueAddedServiceProtocol> serviceManager;

@end

@implementation ServiceListViewController

- (id<ThingActivatedValueAddedServiceProtocol>)serviceManager {
    if (!_serviceManager) {
        id<ThingActivatedValueAddedServiceProtocol> valueAdded = [ThingSmartBizCore.sharedInstance serviceOfProtocol:@protocol(ThingActivatedValueAddedServiceProtocol)];
        NSAssert(valueAdded != nil, @"serviceManager should not be nil");
        _serviceManager = valueAdded;
    }
    return _serviceManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Value-Added Services Demo";
    [self setupUI];
    [self loadServices];
}

- (void)setupUI {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ServiceCell"];
    [self.view addSubview:self.tableView];
}

- (void)loadServices {
    // First try to load cached services
    self.services = [self.serviceManager loadCachedService];
    [self.tableView reloadData];
    
    // Then fetch from server
    [self.serviceManager fetchServiceWithSuccess:^(NSArray<ThingValueAddedServiceModel *> *services) {
        self.services = services;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                     message:error.localizedDescription
                                                              preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.services.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ServiceCell" forIndexPath:indexPath];
    
    ThingValueAddedServiceModel *service = self.services[indexPath.row];
    cell.textLabel.text = service.name;
    cell.detailTextLabel.text = service.desc;
    NSURL *imageURL = [NSURL URLWithString:service.pictureUrlString];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession]
                                  dataTaskWithURL:imageURL
                                  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            UIImage *downloadedImage = [UIImage imageWithData:data];
            if (downloadedImage) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Ensure the cell is still visible before updating the image.
                    UITableViewCell *updateCell = [tableView cellForRowAtIndexPath:indexPath];
                    if (updateCell) {
                        updateCell.imageView.image = downloadedImage;
                        [updateCell setNeedsLayout];
                    }
                });
            }
        }
    }];
    [task resume];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ThingValueAddedServiceModel *service = self.services[indexPath.row];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Open Service"
                                                                 message:@"Choose presentation style"
                                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Push" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.serviceManager openServiceWithModel:service isPush:YES];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Present" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.serviceManager openServiceWithModel:service isPush:NO];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
