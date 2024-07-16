//
//  ThemeManagerViewController.h
//  tuya-bizbundle-ios-sample-objc_Example
//
//  Created by wzm on 2024/7/16.
//  Copyright © 2024 Tuya. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ThingThemeManagerProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface ThemeManagerViewController : UIViewController
- (instancetype)initWithThemeImpl:(id<ThingThemeManagerProtocol>)themeImpl;
@end

NS_ASSUME_NONNULL_END
