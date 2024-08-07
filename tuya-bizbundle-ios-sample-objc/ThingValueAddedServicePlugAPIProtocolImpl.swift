//
//  ThingValueAddedServicePlugAPIProtocolImpl.swift
//  ThingSmartPublic
//
//  Created by 后主 on 2024/8/5.
//  Copyright © 2024 Tuya. All rights reserved.
//

import UIKit

class ThingValueAddedServicePlugAPIProtocolImpl: NSObject {

}

extension ThingValueAddedServicePlugAPIProtocolImpl: ThingValueAddedServicePlugAPIProtocol {
    
    /// 授权前页面头部图标
    func preAuthorizationIcon(_ type: ThingVoiceServiceType) -> UIImage? {
        if (type == .amazonAlexa) {
            return UIImage(named: "icon");
        }else{
            return UIImage(named: "bannerBanner");
        }
    }
    
    
    /// 授权前页面图片
    func preAuthorizationImage(_ type: ThingVoiceServiceType) -> UIImage? {
        if (type == .amazonAlexa) {
            return UIImage(named: "banner");
        }else{
            return UIImage(named: "iconGoogle");
        }
    }
    

    /// 授权前页面提示内容
    func preAuthorizationDetail(_ type: ThingVoiceServiceType) -> String? {
        if (type == .amazonAlexa) {
            return "授权前页面提示内容 alexa";
        }else{
            return "授权前页面提示内容 google";
        }
    }
        
    
    
    

    /// 授权确认页的app图标
    func authorizationConfirmIcon(_ type: ThingVoiceServiceType) -> UIImage? {
        if (type == .amazonAlexa) {
            return UIImage(named: "icon");
        }else{
            return UIImage(named: "iconGoogle");
        }
    }

    /// 授权确认页的app名称
    func authorizationConfirmAppName(_ type: ThingVoiceServiceType) -> String? {
        if (type == .amazonAlexa) {
            return "alexa";
        }else{
            return "google";
        }
    }

    /// 授权确认页的授权标题
    func authorizationConfirmTitle(_ type: ThingVoiceServiceType) -> String? {
        if (type == .amazonAlexa) {
            return "alexa";
        }else{
            return "google";
        }
    }
    
    /// 授权确认页的授权提示标题
    func authorizationConfirmTipsTitle(_ type: ThingVoiceServiceType) -> String? {
        if (type == .amazonAlexa) {
            return "alexa tips";
        }else{
            return "google tips";
        }
    }
    
    /// 授权确认页的授权提示内容
    func authorizationConfirmTipsDetail(_ type: ThingVoiceServiceType) -> String? {
        if (type == .amazonAlexa) {
            return "alexa detail";
        }else{
            return "google detail";
        }
    }


    
    
    
    /// 已授权页面头部图标
    func didAuthorizationIcon(_ type: ThingVoiceServiceType) -> UIImage? {
        if (type == .amazonAlexa) {
            return UIImage(named: "icon");
        }else{
            return UIImage(named: "iconGoogle");
        }
    }

    /// 已授权页面的授权标题
    func didAuthorizationTitle(_ type: ThingVoiceServiceType) -> String? {
        if (type == .amazonAlexa) {
            return "alexa title";
        }else{
            return "google title";
        }
    }

    /// 已授权页面的授权提示标题
    func didAuthorizationTipsTitle(_ type: ThingVoiceServiceType) -> String? {
        if (type == .amazonAlexa) {
            return "alexa tips title";
        }else{
            return "google tips title";
        }
    }

    /// 已授权页面的授权提示内容
    func didAuthorizationTipsDetail(_ type: ThingVoiceServiceType) -> String? {
        if (type == .amazonAlexa) {
            return "alexa tips detail";
        }else{
            return "google tips detail";
        }
    }

    
    
    

    /// 授权解绑页的app图标
    func authorizationUnbindIcon(_ type: ThingVoiceServiceType) -> UIImage? {
        if (type == .amazonAlexa) {
            return UIImage(named: "icon");
        }else{
            return UIImage(named: "iconGoogle");
        }
    }

    /// 授权解绑页的授权标题
    func authorizationUnbindTitle(_ type: ThingVoiceServiceType) -> String? {
        if (type == .amazonAlexa) {
            return "alexa";
        }else{
            return "google";
        }
    }

    /// 授权解绑页的授权提示标题
    func authorizationUnbindTipsTitle(_ type: ThingVoiceServiceType) -> String? {
        if (type == .amazonAlexa) {
            return "alexaTipsTitle";
        }else{
            return "googleTipsTitle";
        }
    }

    /// 授权解绑页的授权提示内容
    func authorizationUnbindTipsDetails(_ type: ThingVoiceServiceType) -> [String]? {
        if (type == .amazonAlexa) {
            return ["authorizationUnbindTipsDetails"];
        }else{
            return ["authorizationUnbindTipsDetails", "authorizationUnbindTipsDetails"];
        }
    }

    
}
