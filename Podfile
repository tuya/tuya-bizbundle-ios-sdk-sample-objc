source 'https://github.com/tuya/tuya-pod-specs.git'
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
use_modular_headers!

platform :ios, '12.0'
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
  pod 'ThingSmartFamilyBizBundle', '~> 6.2.0'
  
  # Device pairing
  pod 'ThingSmartActivatorBizBundle', '~> 6.2.0'
  
  # Device panel (RN)
  pod 'ThingSmartPanelBizBundle', '~> 6.2.0'
  pod 'ThingSmartSpeakExtendBizBundle', '~> 6.2.0'
  pod 'ThingSmartSceneExtendBizBundle', '~> 6.2.0'
  pod 'ThingSmartSweeperExtendBizBundle', '~> 6.2.0'
  pod 'ThingSmartHealthExtendBizBundle', '~> 6.2.0'
  pod 'ThingSmartLangsExtraBizBundle', '~> 6.2.0'
  
  # Device panel (Miniapp)
  pod "ThingSmartMiniAppBizBundle", '~> 6.2.0'
  pod 'ThingSmartBaseKitBizBundle', '~> 6.2.0'
  pod 'ThingSmartBizKitBizBundle', '~> 6.2.0'
  pod 'ThingSmartDeviceKitBizBundle', '~> 6.2.0'
  
  # Device details
  pod 'ThingSmartDeviceDetailBizBundle', '~> 6.2.0'
  
  # Device OTA updates
  pod 'ThingSmartOTABizBundle', '~> 6.2.0'
  
  # Scene
  pod 'ThingSmartSceneBizBundle', '~> 6.2.0'
  
  # Message center
  pod 'ThingSmartMessageBizBundle', '~> 6.2.0'
  
  # Camera
  pod 'ThingSmartCameraPanelBizBundle', '~> 6.2.0'
  pod 'ThingSmartCameraRNPanelBizBundle', '~> 6.2.0'
  pod 'ThingSmartCameraSettingBizBundle', '~> 6.2.0'
  pod 'ThingSmartCloudServiceBizBundle', '~> 6.2.0'
  
  # Help
  pod 'ThingSmartHelpCenterBizBundle', '~> 6.2.0'

  # Theme
  pod 'ThingSmartThemeManagerBizBundle', '~> 6.2.0'

  # Settings
  pod 'ThingSmartSettingBizBundle', '~> 6.2.0'
  
  #################
  # Advanced features
  #################

  # Voice skill
  pod 'ThingSmartSkillQuickBindBizBundle', '~> 6.2.0'
  
  # Light scene
  pod 'ThingSmartLightSceneBizBundle', '~> 6.2.0'

  # Marketing
  pod 'ThingSmartMarketingBizBundle', '~> 6.2.0'

  # Mall
  pod 'ThingSmartMallBizBundle', '~> 6.2.0'

  # Value-added services
  pod 'ThingAdvancedFunctionsBizBundle', '~> 6.2.0'
  
  
  #################
  # SDK
  #################
  
  # [Required] Basic
  pod 'ThingSmartHomeKit', '~> 6.2.0'
  pod 'ThingSmartBusinessExtensionKit', '~> 6.2.0'
  
  # [Optional] Bluetooth
  pod 'ThingSmartBusinessExtensionKitBLEExtra','~> 6.2.0'
  
  # [Optional] Matter
  pod 'ThingSmartMatterKit', '~> 5.20.0'
  pod 'ThingSmartMatterExtensionKit', '~> 5.17.0'
  pod 'ThingSmartBusinessExtensionKitMatterExtra','~> 6.2.0'
  
  # [Optional] HomeKit device
  pod 'ThingSmartAppleDeviceKit', '~> 6.2.0'
  
  # [Optional] Special category
  pod 'ThingSmartCameraKit', '~> 6.2.0'
  pod 'ThingSmartOutdoorKit', '~> 6.2.0'
  pod 'ThingSmartSweeperKit', '~> 6.2.0'
  pod 'ThingSmartLockKit', '~> 6.2.0'
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|

      config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "11.0"
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      
    end
  end
end
