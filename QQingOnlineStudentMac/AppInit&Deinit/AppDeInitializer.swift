//
//  AppDeInitializer.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/1/18.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Foundation

class AppDeInitializer: NSObject {
    
    
    //单利初始化
    static let sharedInstance = AppDeInitializer()
    private override init() {}
}

//MARK: - NetworkModuleDelegate

extension AppDeInitializer:NetworkModuleDelegate {
    
    func isLoggedin() -> Bool {
        return StudentInfoModel.sharedInstance().isLoggedin ?? false
    }
    
    func cleanUpWhenSessionInvalid() {
        
        self.cleanUpCommonPart()
        GCDQueue.main()?.queue({
            //"您的账号已在别处登录"todo:tc
            AppDelegate.loadLoginWindow()
        })
    }
    
    func cleanUpWhenTokenInvalid() {
        FARequestSerialization.sharedInstance()?.setToken(nil)
        self.cleanUpCommonPart()
        GCDQueue.main()?.queue({
            AppDelegate.loadLoginWindow()
        })
    }
}

//MARK: - Private Method

extension AppDeInitializer {
    private func cleanUpCommonPart () {
        GCDQueue.main()?.queue({
            //todo:tc
        })
    }
}
