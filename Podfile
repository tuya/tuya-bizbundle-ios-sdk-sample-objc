source "https://github.com/TuyaInc/TuyaPublicSpecs.git"
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

platform :ios, '11.0'
inhibit_all_warnings!

target 'tuya-bizbundle-ios-sample-objc_Example' do
  pod 'SVProgressHUD'
  pod 'TuyaSmartHomeKit'
  pod 'TuyaSmartActivatorBizBundle'
  pod 'TuyaSmartCameraPanelBizBundle'
  pod 'TuyaSmartCameraRNPanelBizBundle'
  pod 'TuyaSmartCameraSettingBizBundle'
  pod 'TuyaSmartCloudServiceBizBundle'
  pod 'TuyaSmartDeviceDetailBizBundle'
  pod 'TuyaSmartFamilyBizBundle'
  pod 'TuyaSmartHelpCenterBizBundle'
  pod 'TuyaSmartMallBizBundle'
  pod 'TuyaSmartMessageBizBundle'
  pod 'TuyaSmartOTABizBundle'
  pod 'TuyaSmartPanelBizBundle'
  pod 'TuyaSmartSceneBizBundle'
  pod 'TuyaSmartSkillQuickBindBizBundle'
end
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # 消除文档警告
      config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
    end
  end
end
