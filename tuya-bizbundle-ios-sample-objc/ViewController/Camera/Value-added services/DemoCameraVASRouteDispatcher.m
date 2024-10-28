//
//  DemoCameraVASRouteDispatcher.m
//  tuya-bizbundle-ios-sample-objc_Example
//
//  Created by Aaron on 2024/10/25.
//  Copyright © 2024 Tuya. All rights reserved.
//

#import "DemoCameraVASRouteDispatcher.h"

#import <ThingSmartCameraKit/ThingSmartCameraKit.h>
#import <ThingModuleManager/ThingModule.h>
#import <ThingFoundationKit/NSLocale+ThingLanguage.h>

@interface DemoCameraVASRouteDispatcher ()

@property (nonatomic, strong) ThingSmartCameraVAS *cameraVAS;

@end

@implementation DemoCameraVASRouteDispatcher

//增值服务
- (void)openCameraVASPageWithDeviceModel:(ThingSmartDeviceModel *)deviceModel categoryCode:(ThingCameraVASCategoryCode)categoryCode completion:(void(^)(NSError * _Nullable error))completion {
    ThingSmartCameraVASParams *cameraVASParams = [[ThingSmartCameraVASParams alloc] initWithSpaceId:deviceModel.homeId languageCode:Thing_SystemLanguage() hybridType:ThingCameraVASHybridTypeMiniApp categoryCode:categoryCode devId:deviceModel.devId extInfo:nil];
    [self.cameraVAS fetchValueAddedServiceUrlWithParams:cameraVASParams success:^(id<ThingSmartCameraVASResponse>_Nullable response) {
        [ThingModule.routeService openRoute:response.url withParams:nil];
        !completion ?: completion(nil);
    } failure:^(NSError * _Nullable error) {
        !completion ?: completion(error);
    }];
}

//巡检报告
- (void)openCameraInspectionDetailPageWithDeviceModel:(ThingSmartDeviceModel *)deviceModel cameraMessageModel:(ThingSmartCameraMessageModel *)cameraMessageModel completion:(void(^)(NSError * _Nullable error))completion {
    NSString *reportId = cameraMessageModel.extendParams[@"inspectionReportId"];
    ThingSmartCameraVASInspectionParams *inspectionParams = [[ThingSmartCameraVASInspectionParams alloc] initWithSpaceId:deviceModel.homeId devId:deviceModel.devId languageCode:@"zh" hybridType:ThingCameraVASHybridTypeMiniApp reportId:reportId time:cameraMessageModel.time extInfo:nil];
    [self.cameraVAS fetchInspectionDetailUrlWithParams:inspectionParams success:^(id<ThingSmartCameraVASResponse>  _Nullable response) {
        [ThingModule.routeService openRoute:response.url withParams:nil];
        !completion ?: completion(nil);
    } failure:^(NSError * _Nullable error) {
        !completion ?: completion(error);
    }];
}

- (ThingSmartCameraVAS *)cameraVAS {
    if (!_cameraVAS) {
        _cameraVAS = [[ThingSmartCameraVAS alloc] init];
    }
    return _cameraVAS;
}

@end
