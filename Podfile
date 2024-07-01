source 'https://github.com/tuya/tuya-pod-specs.git'
source "https://github.com/TuyaInc/TuyaPublicSpecs.git"
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
use_modular_headers!

platform :ios, '11.0'
inhibit_all_warnings!

target 'tuya-bizbundle-ios-sample-objc_Example' do
  pod 'SVProgressHUD'
  pod 'ThingSmartHomeKit', '~> 5.8.0'
  #pod 'ThingSmartActivatorBizBundle'
  #pod 'ThingSmartCameraPanelBizBundle'
  #pod 'ThingSmartCameraRNPanelBizBundle'
  #pod 'ThingSmartCameraSettingBizBundle'
  #pod 'ThingSmartCloudServiceBizBundle'
  #pod 'ThingSmartDeviceDetailBizBundle'

  # 家庭
  pod 'ThingSmartFamilyBizBundle', '~> 5.8.0'
  
  # 帮助
  pod 'ThingSmartHelpCenterBizBundle', '~> 5.8.0'

  # 消息中心
  pod 'ThingSmartMessageBizBundle', '~> 5.8.0'

  # 微信分享需引入（可选）
  # pod 'ThingSocialWeChat', '~> 5.0.0'
  # QQ 分享需引入（可选）
  # pod 'ThingSocialQQ', '~> 5.0.0'
  # 社交分享业务包
  pod 'ThingSmartShareBizBundle', '~> 5.8.0'

  #pod 'ThingSmartOTABizBundle'
  #pod 'ThingSmartPanelBizBundle'
  #pod 'ThingSmartSceneBizBundle'
  #pod 'ThingSmartSkillQuickBindBizBundle'
  #pod 'ThingSmartLightSceneBizBundle'
  
  # 从 iot.tuya.com 构建和获取 ThingSmartCryption
  #  购买正式版后，需重新在 IoT 平台构建 SDK 并重新集成
  # ./ 代表将 `ios_core_sdk.tar.gz` 解压之后所在目录与 `podfile` 同级
  # 若自定义存放目录，可以修改 `path` 为自定义目录层级
  pod 'ThingSmartCryption', :path => './ios_core_sdk'
  # 小程序业务包
    pod "ThingSmartMiniAppBizBundle"
    pod 'ThingSmartBaseKitBizBundle'
    pod 'ThingSmartBizKitBizBundle'
    pod 'ThingSmartDeviceKitBizBundle'
  
  # Marketing BizBundle
  pod 'ThingSmartMarketingBizBundle'

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
