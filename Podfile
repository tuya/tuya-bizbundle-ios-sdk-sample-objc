source 'https://github.com/tuya/tuya-pod-specs.git'
source 'https://registry.code.tuya-inc.top/tuyaIOS/tuyabusinessspecs'
source "https://github.com/TuyaInc/TuyaPublicSpecs.git"
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

platform :ios, '11.0'
inhibit_all_warnings!

target 'tuya-bizbundle-ios-sample-objc_Example' do
  pod 'SVProgressHUD'
  pod 'ThingSmartHomeKit'
  #pod 'ThingSmartActivatorBizBundle'
  #pod 'ThingSmartCameraPanelBizBundle'
  #pod 'ThingSmartCameraRNPanelBizBundle'
  #pod 'ThingSmartCameraSettingBizBundle'
  #pod 'ThingSmartCloudServiceBizBundle'
  #pod 'ThingSmartDeviceDetailBizBundle'
  pod 'ThingSmartFamilyBizBundle'
  pod 'ThingUIKit', '1.19.0-anonymize2.3'
  pod 'ThingFoundationKit', '1.18.11-remove-reachability.1'
  #pod 'ThingSmartHelpCenterBizBundle'
  #pod 'ThingSmartMallBizBundle'
  #pod 'ThingSmartMessageBizBundle'
  #pod 'ThingSmartOTABizBundle'
  #pod 'ThingSmartPanelBizBundle'
  #pod 'ThingSmartSceneBizBundle'
  #pod 'ThingSmartSkillQuickBindBizBundle'
  #pod 'ThingSmartLightSceneBizBundle', '5.0.0-rc.3.10'
end
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # 消除文档警告
      config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
      # iOS 模拟器去除 arm64
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
end
