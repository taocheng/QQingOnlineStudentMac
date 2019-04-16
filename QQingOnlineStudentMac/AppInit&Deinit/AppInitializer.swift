//
//  AppInitializer.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/1/18.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Foundation

class AppInitializer: NSObject {
    
    var webview:WKWebView?

    
    //单利初始化
    static let sharedInstance = AppInitializer()
    private override init() {}
}

extension AppInitializer {
    
    //启动前初始化本地
    func initiateBeforeLaunching() {
        
        //log日志启动
        LogFileManager.sharedInstance()
        
        //启动时删除QQingDownloadManagerCache路径资源（主要存音频、课件image）
        QQingDownloadManager.sharedInstance()?.deleteAllFile()
        
        //优先初始化数据库
        MagicalRecord.setShouldDeleteStoreOnModelMismatch(true)
        MagicalRecord.setSpecifiedBundle(QQBundle.qqingMomBundle())
        MagicalRecord.setupCoreDataStack(withAutoMigratingSqliteStoreNamed: "qqing.sqlite")
        
        //网络相关配置初始化
        SignalFromRequest.sharedInstance()?.delegate = AppDeInitializer.sharedInstance
        FARequestFormer.shared()?.delegate = AppDeInitializer.sharedInstance
        SignalFromRequest.sharedInstance()?.pbResponseHandleDelegate  = BasicErrorHandler.sharedInstance()
        
        //修改useragent
        self.changeUserAgentForWebView()

    }
    
    //启动初始化app
    func initiateAppBegingLaunching() {
        
        //启动获取服务器时间
        TimeService.sharedInstance()?.requestServerTime()
        
        //启动第一步时间
        AppDelegate.sharedInstance()?.launchTimeDic["step1"] = NSNumber.init(value: NSDate().timeIntervalSinceNow)
        
    }
    
    //启动后获取配置等信息
    func initiateAppAfterLaunching(block:@escaping BOOLBlock) {

        let sig:NSMutableArray = NSMutableArray()
        sig.addObjects(from: [StudentInfoModel.sig_studentBaseInfo(),
                              StudentInfoModel.sig_courseGradeListInfo(),
                              AppServerConfig.sharedInstance().sig_appConfig(),
                              AgoraManager.sharedInstance.sig_getAgoraAppID(),
                              LogFileManager.sharedInstance()?.sig_checkIsNeedUploadlogs() ?? RACSignal()])
        
        RACSignal<AnyObject>.combineLatest(sig).onMainThread().subscribeNext({ (ddd) in
            QQSocketIOManager.sharedInstance()?.sig_getSocketConnectInfo(withQQingLiveOrderCourseID: nil, withCheckService: false)?.onMainThread()?.subscribeNext({ (response) in
                block(true)
            }, error: { (error) in
                block(false)
                BasicErrorHandler.showToast(withAllError: error)
            })
        }) { (error) in
            block(false)
        }
    }
    
    //检测版本升级
    func checkUpdate(completeBlock:@escaping BOOLBlock) {
        let request = GPBUpgradeCheckRequest()
        request.appType = GPBAppType.qingqingLiveCourseStudent
        request.platformType = GPBPlatformType.ipad
        request.currentVersion = QQUtils.version()
        request.deviceId = FCUUID.uuidForDevice()
        
        let former = FARequestFormer.shared()
        let operation = former?.operation(withApiPath: kClient_CheckUpgradeURLString,
                                          start: nil,
                                          completionBlock: { (response) in
                                            if let responseData = response as? Data {
                                                do {
                                                    let res = try GPBUpgradeCheckResponse.parse(from: responseData)
                                                    if res.response.errorCode == 1000 {
                                                        //                                                        self.up?
                                                        if res.upgradeType == GPBUpgradeType.qingqingForce {
                                                            //强制更新
                                                            let alert = NSAlert.init()
                                                            alert.messageText = "您当前使用版本过旧，\n请下载最新的版本以保证上课体验"
                                                            alert.addButton(withTitle: "确定")
                                                            alert.beginSheetModal(for: NSApp.mainWindow!, completionHandler: { (returnCode) in
                                                                //打开升级链接，todo:tc
                                                                //                                                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:upgradeUrl]];
                                                                //                                                                [[AppDelegate sharedAppDelegate] exitApplication];
                                                                
                                                            })
                                                            completeBlock(true)
                                                        } else if (res.upgradeType == GPBUpgradeType.qingqingRecommend || res.upgradeType == GPBUpgradeType.userOptional) {
                                                            //可选升级
                                                            completeBlock(false)
                                                        } else {
                                                            //其他类型
                                                            completeBlock(false)
                                                        }
                                                    } else {
                                                        completeBlock(false)
                                                    }
                                                } catch {
                                                    completeBlock(false)
                                                }
                                            } else {
                                                completeBlock(false)
                                            }
        }, errorBlock: { (error) in
            completeBlock(false)
        })
        operation?.submitAsync()
    }
    
    func whiteListCheckUpdate(orderCourseID:String,completeBlock:@escaping BOOLBlock) {
        let message = GPBLiveUpgradeCheckRequest()
        message.appType = GPBAppType.qingqingLiveCourseStudent
        message.platformType = GPBPlatformType.ipad
        message.currentVersion = QQUtils.version()
        message.qingqingLiveOrderCourseId = orderCourseID
        
        let former = FARequestFormer.shared()
        let operation = former?.operation(withApiPath: kClient_WhiteListCheckUpgradeURLString,
                                          start: nil,
                                          completionBlock: { (response) in
                                            if let responseData = response as? Data {
                                                do {
                                                    let res = try GPBUpgradeCheckResponse.parse(from: responseData)
                                                    if res.response.errorCode == 1000 {
                                                        //                                                        self.up?
                                                        if res.upgradeType == GPBUpgradeType.qingqingForce {
                                                            //强制更新
                                                            let alert = NSAlert.init()
                                                            alert.messageText = "您当前使用版本过旧，\n请下载最新的版本以保证上课体验"
                                                            alert.addButton(withTitle: "确定")
                                                            alert.beginSheetModal(for: NSApp.mainWindow!, completionHandler: { (returnCode) in
                                                                //打开升级链接，todo:tc
                                                                //                                                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:upgradeUrl]];
                                                                //                                                                [[AppDelegate sharedAppDelegate] exitApplication];
                                                                
                                                            })
                                                            completeBlock(true)
                                                        } else if (res.upgradeType == GPBUpgradeType.qingqingRecommend || res.upgradeType == GPBUpgradeType.userOptional) {
                                                            //可选升级
                                                            completeBlock(false)
                                                        } else {
                                                            //其他类型
                                                            completeBlock(false)
                                                        }
                                                    } else {
                                                        completeBlock(false)
                                                    }

                                                } catch {
                                                    completeBlock(false)
                                                }
                                            } else {
                                                completeBlock(false)
                                            }
        }, errorBlock: { (error) in
            completeBlock(false)
        })
        operation?.submitAsync()
    }
    
    //修改useragent
    func changeUserAgentForWebView () {
        GCDQueue.main()?.queue({
//            let currentUserAgent = NSString.currentAppName() + "/mac/" + NSString.currentBundleVersion()
            let currentUserAgent = "studentOnlineMac" + "/Mac/" + NSString.currentBundleVersion()
            self.webview = WKWebView.init(frame: CGRect.zero)
            self.webview?.evaluateJavaScript("navigator.userAgent", completionHandler: { (result, err) in
                let oldAgent = result
                let key:String = "UserAgent"
                let value = currentUserAgent + (oldAgent as?String ?? "")
                
                let key2 = "User-Agent"
                
                
//                let dic = [key:(currentUserAgent + " " + (oldAgent as? String))]
                let dic = [key:value,key2:value]
                UserDefaults.standard.register(defaults: dic)
                UserDefaults.standard.synchronize()
//                self.webview = WKWebView.init(frame: CGRect.zero)
                
                    self.webview?.customUserAgent = value
                
            })
//            self.webview = IMYWebView.init(frame: CGRect.zero)
//
//            self.webview?.evaluateJavaScript("navigator.userAgent", completionHandler: { (result, err) in
//                var oldAgent = result
//                if let error = err {
//
//                    oldAgent = WKWebView.init()
//
//                }
//
//
//            })
        })
    }
}
