source 'https://github.com/tuya/tuya-pod-specs.git'
source "https://github.com/TuyaInc/TuyaPublicSpecs.git"
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
use_modular_headers!

platform :ios, '11.0'
inhibit_all_warnings!

target 'tuya-bizbundle-ios-sample-objc_Example' do
  pod 'SVProgressHUD'

  # Build and obtain ThingSmartCryption from iot.tuya.com
  # After purchasing the official version, SDK needs to be rebuilt on the IoT platform and integrated again
  # ./ denotes the directory where `ios_core_sdk.tar.gz` is located after extraction, at the same level as `podfile`
  # If a custom storage directory is used, `path` can be modified to reflect the custom directory hierarchy
  pod 'ThingSmartCryption', :path => './ios_core_sdk'

  # SDK 
  pod 'ThingSmartHomeKit', '~> 5.15.0'
  pod 'ThingSmartMatterKit', '~> 5.11.0'
  pod 'ThingSmartMatterExtensionKit', '~> 5.0.0'
  pod 'ThingSmartAppleDeviceKit', '~> 5.2.0'
  pod 'ThingSmartCameraKit', '~> 5.15.0'
  pod 'ThingSmartOutdoorKit', '~> 5.4.0'
  pod 'ThingSmartSweeperKit', '~> 5.0.0'
  pod 'ThingSmartLockKit', '~> 5.5.0'
  pod 'ThingSmartBusinessExtensionKit', '~> 5.15.0'
  pod 'ThingSmartBusinessExtensionKitBLEExtra','~> 5.15.0'
  pod 'ThingSmartBusinessExtensionKitMatterExtra','~> 5.15.0'

  # UI Biz 
  pod 'ThingSmartDeviceDetailBizBundle','~> 5.14.0'
  pod 'ThingSmartSkillQuickBindBizBundle','~> 5.14.0'
  pod 'ThingSmartHelpCenterBizBundle','~> 5.14.0'
  pod 'ThingSmartActivatorBizBundle','~> 5.14.0'
  pod 'ThingSmartMessageBizBundle','~> 5.14.0'
  pod 'ThingSmartSceneBizBundle','~> 5.14.0'
  pod 'ThingSmartMallBizBundle','~> 5.14.0'
  pod 'ThingAdvancedFunctionsBizBundle','~> 5.14.0'
  pod 'ThingSmartMarketingBizBundle','~> 5.14.0'
  pod 'ThingSmartGroupHandleBizBundle','~> 5.14.0'
  pod 'ThingSmartDeviceSyncBizBundle','~> 5.14.0'
  pod 'ThingSmartPanelBizBundle','~> 5.14.0'
  pod 'ThingSmartLightSceneBizBundle','~> 5.14.0'
  pod 'ThingSmartShareBizBundle','~> 5.14.0'
  pod 'ThingSmartCameraRNPanelBizBundle','~> 5.14.0'
  pod 'ThingSmartCameraPanelBizBundle','~> 5.14.0'
  pod 'ThingSmartLangsExtraBizBundle','~> 5.14.0'
  pod 'ThingSmartFamilyBizBundle','~> 5.14.0'
  pod 'ThingSmartOTABizBundle','~> 5.14.0'
  pod 'ThingSmartCameraSettingBizBundle','~> 5.14.0'
  pod 'ThingSmartCloudServiceBizBundle','~> 5.14.0'
  pod 'ThingSmartActivatorExtraBizBundle','~> 5.14.0'
  pod 'ThingSmartThemeManagerBizBundle','~> 5.14.0'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|

      config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "11.0"
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"

      # replace to your teamid
      config.build_settings["DEVELOPMENT_TEAM"] = "your teamid"
      
      
      
    end
  end
end
