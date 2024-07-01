//
//  DemoBaseTableViewController.m
//  tuya-bizbundle-ios-sample-objc_Example
//
//  Created by 尼奥 on 2024/3/27.
//  Copyright © 2024 Tuya. All rights reserved.
//

#import "DemoBaseTableViewController.h"

@interface DemoBaseTableViewController ()

@end

@implementation DemoBaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];

    if (indexPath.section < self.actionMapping.count
        && indexPath.row < self.actionMapping[indexPath.section].count) {
        SEL selector = [self.actionMapping[indexPath.section][indexPath.row] pointerValue];
        if (selector && [self respondsToSelector:selector]) {
            [self performSelector:selector withObject:nil afterDelay:0];
        }
    }
}

@end
