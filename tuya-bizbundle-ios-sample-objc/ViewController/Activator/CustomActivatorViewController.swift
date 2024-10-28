//
//  CustomActivatorViewController.swift
//  tuya-bizbundle-ios-sample-objc_Example
//
//  Created by huangjj on 2024/8/8.
//  Copyright © 2024 Tuya. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

@objc class CustomActivatorViewController: UIViewController {
    
    
    let requestService = ThingSmartActivatorDiscoveryRequest()
    
    lazy var cameraView: UIView = {
        let view = UIView(frame: CGRectZero)
        view.backgroundColor = UIColor.white
        view.layer.borderWidth = 1;
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var cameraImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRectZero)
        imageView.image = UIImage(named: "camera" )
        return imageView
    }()
    
    lazy var cameraLable: UILabel = {
        let label = UILabel(frame: CGRectZero)
        label.textAlignment = .left
        label.textColor = UIColor(red: 136.0/255.0, green: 200.0/255.0, blue: 225.0/255.0, alpha: 1.0)
        label.font = UIFont.systemFont(ofSize: 15,weight: .bold)
        label.text = "Intelligent PTZ camera"
        return label
    }()
    
    lazy var cameraButton: UIButton = {
        let button = UIButton(frame: CGRectZero)
        button.backgroundColor = UIColor(red: 136.0/255.0, green: 200.0/255.0, blue: 225.0/255.0, alpha: 1.0)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.setTitle("Add Device", for: UIControl.State.normal)
        button.addTarget(self, action: #selector(addDevice(sender:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: - lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.title = "Add Device"
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.alpha = 1.0
        self.navigationItem.setHidesBackButton(false, animated: false)
        self.navigationController?.navigationBar.backItem?.setHidesBackButton(false, animated: false)
        
        self.view.addSubview(self.cameraView)
        self.cameraView.addSubview(self.cameraImageView)
        self.cameraView.addSubview(self.cameraLable)
        self.cameraView.addSubview(self.cameraButton)
        
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        self.cameraView.snp.makeConstraints { make in
            make.centerX.equalToSuperview() // 居中对齐
            make.width.equalTo(isPad ? 375 : UIScreen.main.bounds.width - 40) // 条件判断宽度
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(100)
            make.height.equalTo(220)
        }
        
        self.cameraImageView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(160)
        }
        
        self.cameraLable.snp.makeConstraints { make in
            make.top.equalTo(180)
            make.left.equalTo(10)
            make.height.equalTo(20)
        }
        
        self.cameraButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.cameraLable)
            make.right.equalTo(-10)
            make.height.equalTo(35)
        }
        
    }
    
    func getProductData () {
        let requestData =  ThingActivatorCategoryDetailRequestData()
        requestData.bizType = 1
        requestData.bizValue = "rj74cnjwwsste1g6"
        requestService.requestCategoryDetail(withParam: requestData) { result in
            let impl = ThingSmartBizCore.sharedInstance().service(of: ThingActivatorProtocol.self)
            (impl as AnyObject).gotoAcvitavor(with: result, userInfo: [:])
        } failure: { error in
            
        }
            
    }
    
    @objc func addDevice(sender: UISwitch) {
        getProductData()
    }
    
}
