//
//  DeviceListTableViewController.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DeviceListType) {
    DeviceListTypeDeviceDetail,
    DeviceListTypeDevicePanel,
    DeviceListTypeDeviceOTA,
    DeviceListTypeIPCPanel,
    DeviceListTypeCameraPlayBackPanel,
    DeviceListTypeCameraCloudStoragePanel,
    DeviceListTypeCameraMessageCenterPanel,
    DeviceListTypeCameraPhotoLibraryPanel
    
};

@interface DeviceListTableViewController : UITableViewController
@property (assign, nonatomic) DeviceListType deviceListType;
@end

NS_ASSUME_NONNULL_END
