source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/tuya/tuya-pod-specs.git'


use_modular_headers!
use_frameworks! #:linkage => :static
platform :ios, '14.0'
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
  pod 'ThingSmartFamilyBizBundle', '~> 7.11.0'
  
  # Device pairing
  pod 'ThingSmartActivatorBizBundle', '~> 7.11.0'
  
  # Device panel (RN)
  pod 'ThingSmartPanelBizBundle', '~> 7.11.0'
  pod 'ThingSmartSpeakExtendBizBundle', '~> 7.11.0'
  pod 'ThingSmartSceneExtendBizBundle', '~> 7.11.0'
  pod 'ThingSmartSweeperExtendBizBundle', '~> 7.11.0'
  pod 'ThingSmartHealthExtendBizBundle', '~> 7.11.0'
  pod 'ThingSmartLangsExtraBizBundle', '~> 7.11.0'
  
  # Device panel (Miniapp)
  pod "ThingSmartMiniAppBizBundle", '~> 7.11.0'
  pod 'ThingSmartBaseKitBizBundle', '~> 7.11.0'
  pod 'ThingSmartBizKitBizBundle', '~> 7.11.0'
  pod 'ThingSmartDeviceKitBizBundle', '~> 7.11.0'
  pod 'ThingSmartHomeKitBizBundle', '~> 7.11.0'
  pod 'ThingSmartMediaKitBizBundle', '~> 7.11.0'
  pod 'ThingSmartP2PKitBizBundle', '~> 7.11.0'
  pod 'ThingSmartIPCKitBizBundle', '~> 7.11.0'
  
  # Device details
  pod 'ThingSmartDeviceDetailBizBundle', '~> 7.11.0'
  
  # Device OTA updates
  pod 'ThingSmartOTABizBundle', '~> 7.11.0'
  
  # Scene
  pod 'ThingSmartSceneBizBundle', '~> 7.11.0'
  
  # Message center
  pod 'ThingSmartMessageBizBundle', '~> 7.11.0'
  
  # Camera
  pod 'ThingSmartCameraPanelBizBundle', '~> 7.11.0'
  pod 'ThingSmartCameraRNPanelBizBundle', '~> 7.11.0'
  pod 'ThingSmartCameraSettingBizBundle', '~> 7.11.0'
  pod 'ThingSmartCloudServiceBizBundle', '~> 7.11.0'
  
  # Help
  pod 'ThingSmartHelpCenterBizBundle', '~> 7.11.0'

  # Theme
  pod 'ThingSmartThemeManagerBizBundle', '~> 7.11.0'

  # Settings
  pod 'ThingSmartSettingBizBundle', '~> 7.11.0'
  
  #################
  # Advanced features
  #################

  # Voice skill
  pod 'ThingSmartSkillQuickBindBizBundle', '~> 7.11.0'
  
  # Light scene
  pod 'ThingSmartLightSceneBizBundle', '~> 7.11.0'

  # Marketing
  pod 'ThingSmartMarketingBizBundle', '~> 7.11.0'

  # Mall
  pod 'ThingSmartMallBizBundle', '~> 7.11.0'

  # Value-added services
  pod 'ThingAdvancedFunctionsBizBundle', '~> 7.11.0'
  
  
  #################
  # SDK
  #################
  
  # [Required] Basic
  pod 'ThingSmartHomeKit', '~> 7.11.0'
  pod 'ThingSmartBusinessExtensionKit', '~> 7.11.0'
  
  # [Optional] Device Activator
  pod 'ThingSmartActivatorExtraBizBundle', '~> 7.11.0'

  # [Optional] Bluetooth
  pod 'ThingSmartBusinessExtensionKitBLEExtra','~> 7.11.0'
  
  # [Optional] Matter
  pod 'ThingSmartMatterKit', '~> 7.11.0'
  pod 'ThingSmartMatterExtensionKit', '~> 7.11.0'
  pod 'ThingSmartBusinessExtensionKitMatterExtra','~> 7.11.0'
  
  # [Optional] HomeKit device
  pod 'ThingSmartAppleDeviceKit', '~> 7.11.0'
  
  # [Optional] Special category
  pod 'ThingSmartCameraKit', '~> 7.11.0'
  pod 'ThingSmartOutdoorKit', '~> 7.11.0'
  pod 'ThingSmartSweeperKit', '~> 7.11.0'
  pod 'ThingSmartLockKit', '~> 7.11.0'

  # [Optional] AI
  pod  'ThingSmartBusinessExtensionKitAIStreamExtra', '~> 7.11.0'
  
  # [Optional] AI Assistant
  pod 'ThingSmartAIAssistantBizBundle', '~> 7.11.0'
  
  #  # HeyTuya
  pod 'ThingAIRecomBizBundle', '~> 7.11.0'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|

      config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "14.0"
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      
    end
  end
end
