//
//  DemoBaseTableViewController.h
//  tuya-bizbundle-ios-sample-objc_Example
//
//  Created by 尼奥 on 2024/3/27.
//  Copyright © 2024 Tuya. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ACTION_NULL ACTION(nil)
#define ACTION(sel) [NSValue valueWithPointer:(sel)]

NS_ASSUME_NONNULL_BEGIN

@interface DemoBaseTableViewController : UITableViewController

/*
 self.actionMapping = @[
     @[ACTION(@selector(gotoFamilyManagement)), ACTION_NULL, ACTION(@selector(logoutTapped:))],
     @[ACTION(@selector(gotoCategoryViewController))],
     @[ACTION_NULL],
 ];
 */
@property (nonatomic, strong) NSArray<NSArray<NSValue *> *> *actionMapping;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
