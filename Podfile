source 'https://github.com/tuya/tuya-pod-specs.git'
source "https://github.com/TuyaInc/TuyaPublicSpecs.git"
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
use_modular_headers!

platform :ios, '11.0'
inhibit_all_warnings!

target 'tuya-bizbundle-ios-sample-objc_Example' do
  pod 'SVProgressHUD'
  pod 'ThingSmartHomeKit', '~> 5.14.0'
  pod 'ThingSmartActivatorBizBundle', '~> 5.14.0'
  pod 'ThingSmartCameraPanelBizBundle', '~> 5.14.0'
  pod 'ThingSmartCameraRNPanelBizBundle', '~> 5.14.0'
  pod 'ThingSmartCameraSettingBizBundle', '~> 5.14.0'
  pod 'ThingSmartCloudServiceBizBundle', '~> 5.14.0'
  pod 'ThingSmartDeviceDetailBizBundle', '~> 5.14.0'

  # Family
  pod 'ThingSmartFamilyBizBundle', '~> 5.14.0'
  
  # Help
  pod 'ThingSmartHelpCenterBizBundle', '~> 5.14.0'

  # Message Center
  pod 'ThingSmartMessageBizBundle', '~> 5.14.0'

  # Required for WeChat sharing (optional)
  # pod 'ThingSocialWeChat', '~> 5.14.0.0'
  # Required for QQ sharing (optional)
  # pod 'ThingSocialQQ', '~> 5.14.0.0'
  # Social Sharing Business Bundle
  pod 'ThingSmartShareBizBundle', '~> 5.14.0'

  # pod 'ThingSmartOTABizBundle'
  # pod 'ThingSmartPanelBizBundle'
  # pod 'ThingSmartSceneBizBundle'
  # pod 'ThingSmartSkillQuickBindBizBundle'
  # pod 'ThingSmartLightSceneBizBundle'
  
  # Build and obtain ThingSmartCryption from iot.tuya.com
  # After purchasing the official version, you need to rebuild the SDK on the IoT platform and reintegrate it
  # ./ represents the directory where `ios_core_sdk.tar.gz` is extracted to the same level as the `podfile`
  # If you store it in a custom directory, you can modify `path` to the custom directory level
  pod 'ThingSmartCryption', :path => './ios_core_sdk'
  # Mini Program Business Bundle
  pod "ThingSmartMiniAppBizBundle", '~> 5.14.0'
  pod 'ThingSmartBaseKitBizBundle', '~> 5.14.0'
  pod 'ThingSmartBizKitBizBundle', '~> 5.14.0'
  pod 'ThingSmartDeviceKitBizBundle', '~> 5.14.0'
  
  # Marketing BizBundle
  pod 'ThingSmartMarketingBizBundle', '~> 5.14.0'
  pod 'ThingSmartMallBizBundle', '~> 5.14.0'
  pod 'ThingSmartThemeManagerBizBundle', '~> 5.14.0'

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
