//
//  DemoCameraVASRouteDispatcher.h
//  tuya-bizbundle-ios-sample-objc_Example
//
//  Created by Aaron on 2024/10/25.
//  Copyright © 2024 Tuya. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ThingSmartCameraKit/ThingSmartCameraVAS.h>

NS_ASSUME_NONNULL_BEGIN

@class ThingSmartDeviceModel,ThingSmartCameraMessageModel;
@interface DemoCameraVASRouteDispatcher : NSObject

- (void)openCameraVASPageWithDeviceModel:(ThingSmartDeviceModel *)deviceModel categoryCode:(ThingCameraVASCategoryCode)categoryCode completion:(void(^)(NSError * _Nullable error))completion;

//巡检报告
- (void)openCameraInspectionDetailPageWithDeviceModel:(ThingSmartDeviceModel *)deviceModel cameraMessageModel:(ThingSmartCameraMessageModel *)cameraMessageModel completion:(void(^)(NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
