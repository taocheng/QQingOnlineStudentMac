//
//  AppUpdateConfig.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/1/21.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Foundation

class AppUpdateConfig: NSObject {
    
    var upgradeCheckResponse:GPBUpgradeCheckResponse?
    
    //初始化单利
    static let sharedInstance = AppUpdateConfig()
    private override init() {}
}

extension AppUpdateConfig {
    
    //全局检测升级
    func checkGlobleUpdate(completeBlock:@escaping BOOLBlock) {
        let request = GPBUpgradeCheckRequest()
        request.appType = GPBAppType.qingqingLiveCourseStudent
        request.platformType = GPBPlatformType.ipad//todo:tc
        request.currentVersion = QQUtils.version()
        request.deviceId = FCUUID.uuidForDevice()
        let former = FARequestFormer.shared()
        let operation:FANetworkOperation? = former?.operation(withApiPath: kClient_CheckUpgradeURLString,
                                                              pbMessage: request,
                                                              start: nil,
                                                              completionBlock: { [weak self] (responseData) in
            guard let `self` = self else { return }

            if let res = responseData as?NSData {
                
                do {
                    let response:GPBUpgradeCheckResponse = try GPBUpgradeCheckResponse.parse(from: res as Data)
                    if ( response.response.errorCode == 1000 ) {
                        self.upgradeCheckResponse = response
                        
                        if (response.upgradeType == GPBUpgradeType.qingqingForce) {
                            //强制升级

                            //发送页面埋点
                            MetricDataCollectionService.sendPageData(withEventCode: "update", appendDict: nil)
                            //todo:tc QQAlertView "您当前使用版本过旧" let updateUrl = response.downloadURL

                            //返回
                            completeBlock(true)
                        } else {
                            //返回
                            completeBlock(false)
                        }
                    }
                } catch {
                    //返回
                    completeBlock(false)
                }
            }
        }, errorBlock: { (error) in
            //返回
            completeBlock(false)
        })
        operation?.submitAsync()
    }
    
    //白名单检测升级
    func checkWhitelistUpdate(ordercourseID:String, completeBlock:BOOLBlock? = nil) {
        let request = GPBLiveUpgradeCheckRequest()
        request.appType = GPBAppType.qingqingLiveCourseStudent
        request.platformType = GPBPlatformType.ipad
        request.currentVersion = QQUtils.version()
        request.qingqingLiveOrderCourseId = ordercourseID
        
        let former = FARequestFormer.shared()
        let res:FANetworkOperation? = former?.operation(withApiPath: kClient_WhiteListCheckUpgradeURLString,
                                    pbMessage: request,
                                    start: nil,
                                    completionBlock: { [weak self] (responseData) in
                                        guard let `self` = self else { return }
                                        
                                        if let response = responseData as?NSData {
                                            do {
                                                let res = try GPBUpgradeCheckResponse.parse(from: response as Data)
                                                if res.response.errorCode == 1000 {
                                                    self.upgradeCheckResponse = res
                                                    if ( res.upgradeType == GPBUpgradeType.qingqingForce ||
                                                        res.upgradeType == GPBUpgradeType.qingqingWhitelist) {
                                                        //强制升级
                                                        let upgradeUrl = self.upgradeCheckResponse?.downloadURL
                                                        let upgradeVersion = self.upgradeCheckResponse?.upgradeVersion
                                                        let key = "NoUpgradeTip" + (upgradeVersion ?? "")
                                                        if (UserDefaults.standard.bool(forKey: key) == false) {
                                                            //todo:tc
                                                        } else {
                                                            if let complete:BOOLBlock = completeBlock {
                                                                complete(false)
                                                            }
                                                        }
                                                    } else {
                                                        if let complete:BOOLBlock = completeBlock {
                                                            complete(false)
                                                        }
                                                    }
                                                }
                                            } catch {
                                                if let complete:BOOLBlock = completeBlock {
                                                    complete(false)
                                                }
                                            }
                                        }
        }, errorBlock: { (error) in
            if let complete:BOOLBlock = completeBlock {
                complete(false)
            }
        })
        res?.submitAsync()
    }
}
