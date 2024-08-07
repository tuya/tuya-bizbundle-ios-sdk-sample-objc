//
//  ThemeManagerViewController.m
//  tuya-bizbundle-ios-sample-objc_Example
//
//  Created by wzm on 2024/7/16.
//  Copyright © 2024 Tuya. All rights reserved.
//

#import "ThemeManagerViewController.h"
#import <ThingModuleServices/ThingModuleServices.h>
#import <ThingFoundationKit/ThingFoundationKit.h>

@interface ThemeManagerViewController ()
@property (nonatomic, strong) UIView * followSystemThemeView;
@property (nonatomic, strong) UIView * blackThemeView;
@property (nonatomic, strong) id<ThingThemeManagerProtocol> themeImpl;

@property (nonatomic, strong) UISwitch * followSystemThemeSwitch;
@property (nonatomic, strong) UISwitch * openBlackModeSwitch;
@end

@implementation ThemeManagerViewController
- (instancetype)initWithThemeImpl:(id<ThingThemeManagerProtocol>)themeImpl {
    if (!themeImpl) {
        return nil;
    }
    self = [super init];
    if (self) {
        self.themeImpl = themeImpl;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBarUI];
    [self setupThemeManagerUI];
    [self updateSwitchStatus];
}

#pragma mark - Private
- (void)updateSwitchStatus {
    if (@available(iOS 13.0, *)) {
        UIUserInterfaceStyle style = [self.themeImpl currentThemeStyle];
        
        switch (style) {
            case UIUserInterfaceStyleUnspecified:
            {
                self.blackThemeView.hidden = YES;
                [self.followSystemThemeSwitch setOn:YES];
                break;
            }
            case UIUserInterfaceStyleDark:
            {
                self.blackThemeView.hidden = NO;
                [self.followSystemThemeSwitch setOn:NO];
                [self.openBlackModeSwitch setOn:YES];
                break;
            }
            default:
                self.blackThemeView.hidden = NO;
                [self.followSystemThemeSwitch setOn:NO];
                [self.openBlackModeSwitch setOn:NO];
                break;
        }
    }
}

- (void)followSystemThemeSwitchValueChanged:(UISwitch *)btn {
    if (@available(iOS 13.0, *)) {
        if (self.followSystemThemeSwitch.isOn) {
            [self.themeImpl changeThemeStyle:UIUserInterfaceStyleUnspecified];
        } else {
            [self.themeImpl changeThemeStyle:[self.themeImpl isDarkMode] ? UIUserInterfaceStyleDark : UIUserInterfaceStyleLight];
        }
        
        [self updateSwitchStatus];
    }
}

- (void)openBlackModeSwitchValueChanged:(UISwitch *)btn {
    if (@available(iOS 13.0, *)) {
        if (self.openBlackModeSwitch.isOn) {
            [self.themeImpl changeThemeStyle:UIUserInterfaceStyleDark];
        } else {
            [self.themeImpl changeThemeStyle:UIUserInterfaceStyleLight];
        }
        
        [self updateSwitchStatus];
    }
}

#pragma mark - UI
- (void)setupNavigationBarUI {
    self.view.backgroundColor = self.themeImpl.backgroundColor;
    self.title = NSLocalizedString(@"theme demo", nil);
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : self.themeImpl.headLineColor}];
}

- (void)setupThemeManagerUI {
    [self.view addSubview:self.followSystemThemeView];
    self.followSystemThemeView.backgroundColor = self.themeImpl.cardBgColor;
    self.followSystemThemeView.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGFloat statusBarHeight = 0;
    if (@available(iOS 13.0, *)) {
        statusBarHeight = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager.statusBarFrame.size.height;
    } else {
        statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    
    [self.followSystemThemeView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:statusBarHeight + self.navigationController.navigationBar.frame.size.height + 10].active = YES;
    [self.followSystemThemeView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.followSystemThemeView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    
    [self.view addSubview:self.blackThemeView];
    self.blackThemeView.backgroundColor = self.themeImpl.cardBgColor;
    self.blackThemeView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.blackThemeView.topAnchor constraintEqualToAnchor:self.followSystemThemeView.bottomAnchor constant:10].active = YES;
    [self.blackThemeView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.blackThemeView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [self.blackThemeView.heightAnchor constraintEqualToAnchor:self.followSystemThemeView.heightAnchor].active = YES;
}

- (UIView *)followSystemThemeView {
    if (!_followSystemThemeView) {
        _followSystemThemeView = [[UIView alloc] init];
        
        UILabel * title = [[UILabel alloc] init];
        title.text = NSLocalizedString(@"Follow the system", nil);
        title.font = [UIFont systemFontOfSize:16];
        title.textColor = self.themeImpl.headLineColor;
        
        UILabel * subTitle = [[UILabel alloc] init];
        subTitle.text = NSLocalizedString(@"Once turned on, it will follow the system to turn on or off dark mode.", nil);
        subTitle.font = [UIFont systemFontOfSize:16];
        subTitle.textColor = self.themeImpl.auxiLiaryColor;
        
        UISwitch * btn = [[UISwitch alloc] init];
        self.followSystemThemeSwitch = btn;
        
        [btn addTarget:self action:@selector(followSystemThemeSwitchValueChanged:) forControlEvents:(UIControlEventValueChanged)];
        
        [_followSystemThemeView addSubview:title];
        [_followSystemThemeView addSubview:subTitle];
        [_followSystemThemeView addSubview:btn];
        
        title.translatesAutoresizingMaskIntoConstraints = NO;
        [title.topAnchor constraintEqualToAnchor:_followSystemThemeView.topAnchor constant:15].active = YES;
        [title.leftAnchor constraintEqualToAnchor:_followSystemThemeView.leftAnchor constant:15].active = YES;
        [title.rightAnchor constraintEqualToAnchor:btn.leftAnchor constant:-15].active = YES;
        
        subTitle.translatesAutoresizingMaskIntoConstraints = NO;
        [subTitle.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:4].active = YES;
        [subTitle.leftAnchor constraintEqualToAnchor:title.leftAnchor].active = YES;
        [subTitle.rightAnchor constraintEqualToAnchor:title.rightAnchor].active = YES;
        [subTitle.bottomAnchor constraintEqualToAnchor:_followSystemThemeView.bottomAnchor constant:-15].active = YES;
        
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        [btn.centerYAnchor constraintEqualToAnchor:_followSystemThemeView.centerYAnchor].active = YES;
        [btn.rightAnchor constraintEqualToAnchor:_followSystemThemeView.rightAnchor constant:-15].active = YES;
    }
    return _followSystemThemeView;
}
- (UIView *)blackThemeView {
    if (!_blackThemeView) {
        _blackThemeView = [[UIView alloc] init];
        
        UILabel * title = [[UILabel alloc] init];
        title.text = NSLocalizedString(@"Turn on black mode", nil);
        title.font = [UIFont systemFontOfSize:16];
        title.textColor = self.themeImpl.headLineColor;
        
        UISwitch * btn = [[UISwitch alloc] init];
        self.openBlackModeSwitch = btn;
        
        [btn addTarget:self action:@selector(openBlackModeSwitchValueChanged:) forControlEvents:(UIControlEventValueChanged)];
        
        [_blackThemeView addSubview:title];
        [_blackThemeView addSubview:btn];
        
        title.translatesAutoresizingMaskIntoConstraints = NO;
        [title.centerYAnchor constraintEqualToAnchor:_blackThemeView.centerYAnchor].active = YES;
        [title.leftAnchor constraintEqualToAnchor:_blackThemeView.leftAnchor constant:15].active = YES;
        [title.rightAnchor constraintEqualToAnchor:btn.leftAnchor constant:-15].active = YES;
        
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        [btn.centerYAnchor constraintEqualToAnchor:_blackThemeView.centerYAnchor].active = YES;
        [btn.rightAnchor constraintEqualToAnchor:_blackThemeView.rightAnchor constant:-15].active = YES;
    }
    return _blackThemeView;
}

@end
