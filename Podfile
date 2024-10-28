source 'https://github.com/tuya/tuya-pod-specs.git'
source "https://github.com/TuyaInc/TuyaPublicSpecs.git"
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
use_modular_headers!

platform :ios, '11.0'
inhibit_all_warnings!

target 'tuya-bizbundle-ios-sample-objc_Example' do
  pod 'SVProgressHUD'
  pod 'SnapKit'

  #################
  # Commonly Used
  #################
  
  # Secret key
  # Build and obtain ThingSmartCryption from iot.tuya.com
  # After purchasing the official version, you need to rebuild the SDK on the IoT platform and reintegrate it
  # ./ represents the directory where `ios_core_sdk.tar.gz` is extracted to the same level as the `podfile`
  # If you store it in a custom directory, you can modify `path` to the custom directory level
  pod 'ThingSmartCryption', :path => './ios_core_sdk'
  
  # Family
  pod 'ThingSmartFamilyBizBundle', '~> 5.17.0'
  
  # Device pairing
  pod 'ThingSmartActivatorBizBundle', '~> 5.17.0'
  
  # Device Panel (RN)
  pod 'ThingSmartPanelBizBundle', '~> 5.17.0'
  
  # Device Panel (Mini Program)
  pod "ThingSmartMiniAppBizBundle", '~> 5.17.0'
  pod 'ThingSmartBaseKitBizBundle', '~> 5.17.0'
  pod 'ThingSmartBizKitBizBundle', '~> 5.17.0'
  pod 'ThingSmartDeviceKitBizBundle', '~> 5.17.0'
  
  # Device detail
  pod 'ThingSmartDeviceDetailBizBundle', '~> 5.17.0'
  
  # Device OTA
  pod 'ThingSmartOTABizBundle', '~> 5.17.0'
  
  # Scene
  pod 'ThingSmartSceneBizBundle', '~> 5.17.0'
  
  # Message Center
  pod 'ThingSmartMessageBizBundle', '~> 5.17.0'
  
  # Camera
  pod 'ThingSmartCameraPanelBizBundle', '~> 5.17.0'
  pod 'ThingSmartCameraRNPanelBizBundle', '~> 5.17.0'
  pod 'ThingSmartCameraSettingBizBundle', '~> 5.17.0'
  pod 'ThingSmartCloudServiceBizBundle', '~> 5.17.0'
  
  # Help
  pod 'ThingSmartHelpCenterBizBundle', '~> 5.17.0'

  # Theme
  pod 'ThingSmartThemeManagerBizBundle', '~> 5.17.0'
  
  
  #################
  # Advanced Used
  #################

  # Voice Skill
  pod 'ThingSmartSkillQuickBindBizBundle', '~> 5.17.0'
  
  # Light Secene
  pod 'ThingSmartLightSceneBizBundle', '~> 5.17.0'

  # Marketing
  pod 'ThingSmartMarketingBizBundle', '~> 5.17.0'
  
  # Mall
  pod 'ThingSmartMallBizBundle', '~> 5.17.0'
  
  # Value-added services
  pod 'ThingAdvancedFunctionsBizBundle', '~> 5.17.0'

  # Required for WeChat sharing (optional)
  # pod 'ThingSocialWeChat', '~> 5.17.0.0'
  # Required for QQ sharing (optional)
  # pod 'ThingSocialQQ', '~> 5.17.0.0'
  # Social Sharing Business Bundle
  pod 'ThingSmartShareBizBundle', '~> 5.17.0'
  
  
  #################
  # SDK
  #################
  
  # [Required] Basic
  pod 'ThingSmartHomeKit', '~> 5.17.0'
  pod 'ThingSmartBusinessExtensionKit', '~> 5.17.0'
  
  # [Optional] Bluetooth
  pod 'ThingSmartBusinessExtensionKitBLEExtra','~> 5.17.0'
  
  # [Optional] Matter
  pod 'ThingSmartMatterKit', '~> 5.17.0'
  pod 'ThingSmartMatterExtensionKit', '~> 5.17.0'
  pod 'ThingSmartBusinessExtensionKitMatterExtra','~> 5.17.0'
  
  # [Optional] HomeKit Device
  pod 'ThingSmartAppleDeviceKit', '~> 5.17.0'
  
  # [Optional] Special category
  pod 'ThingSmartCameraKit', '~> 5.17.0'
  pod 'ThingSmartOutdoorKit', '~> 5.17.0'
  pod 'ThingSmartSweeperKit', '~> 5.0.0'
  pod 'ThingSmartLockKit', '~> 5.5.0'
  
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
