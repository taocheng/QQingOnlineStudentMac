//
//  AppServerConfig.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/1/16.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Foundation

class AppServerConfig: NSObject {
    
    //http请求重试次数，默认1次
    var httpRequestRetryCount: Int32 = 1
    
    //http请求超时时间，默认10s
    var httpRequestTimeout: Int32 = 10
    
    //在线metric打包发送时间，默认10s一次
    var onlineAllMetricSendTime: Int32 = 10

    //在线pingpong和p2p发送时间，默认10s一次
    var onlinePingpongAndP2PMetricSendTime: Int32 = 10
    
    //是否容许分批拉取历史记录
    var isAllowPullmsgSegment = false
    
    
    //单利初始化
    static let sharedInstance = AppServerConfig()
    private override init() { }
}

//MARK: - Request

extension AppServerConfig {
    
    func sig_appConfig() -> RACSignal<AnyObject> {
        return RACSignal.createSignal({ (subscriber) -> RACDisposable? in
            SignalFromRequest.signalFromPBRequest(withApiPath: kStudent_App_Config_ServerUrl,
                                                  httpMethod: HTTP_GET,
                                                  supportHttpCache: true,
                                                  pbMessage: nil,
                                                  responseClass: GPBAppConfigResponseV3.self,
                                                  errorDomain: kErrorDomain_GetAppConfig,
                                                  debugUserInfo: nil)?.subscribeNext({ [weak self] (response) in
                                                    
                                                        guard let `self` = self else { return }
                                                    
                                                        //更新配置项
                                                        if let res = response as? GPBAppConfigResponseV3 {
                                                            self.updateConfiguration(response: res)
                                                        }
                                                    
                                                        subscriber.sendNext(response)
                                                        subscriber.sendCompleted()
                                                  }, error: { (error) in
                                                        subscriber.sendError(error)
                                                  })
            
            return nil
        })
    }
}

//MARK: - Method

extension AppServerConfig {
    
    //更新配置项
    func updateConfiguration(response:GPBAppConfigResponseV3) {
        if response.isKind(of: GPBAppConfigResponseV3.self) {
            
            //解析配置项
            let configurationDict = NSMutableDictionary()
            let configItemsArray:[GPBAppConfigItem] = response.configItemsArray as? [GPBAppConfigItem] ?? []
            for configItem:GPBAppConfigItem in configItemsArray {
                configurationDict[configItem.key] = configItem.valueArray
            }
            
            //设置请求重试次数
            if let httpRequestRetryArr:[NSNumber] = configurationDict["http_request_retry_count"] as? [NSNumber],let retryCountNum = httpRequestRetryArr.first {
                self.httpRequestRetryCount = retryCountNum.int32Value
            }
            
            //设置请求超时时间
            if let httpRequestTimeoutArr:[NSNumber] = configurationDict["http_request_timeout"] as? [NSNumber],let timeoutNum = httpRequestTimeoutArr.first {
                self.httpRequestTimeout = timeoutNum.int32Value
            }
            
            //设置除pingpong和p2p外的metric打包发送时间
            if let onlineMetricSendTimeArr:[NSNumber] = configurationDict["online_all_metric_send_time"] as? [NSNumber],let metricSendTimeNum = onlineMetricSendTimeArr.first {
                self.onlineAllMetricSendTime = metricSendTimeNum.int32Value
            }

            //设置pingpong和p2p打包发送时间
            if let onlinePingpongAndP2PMetricSendTimeArr:[NSNumber] = configurationDict["online_pingpong_p2p_metric_send_time"] as? [NSNumber],let pingpongAndP2PMetricSendTimeNum = onlinePingpongAndP2PMetricSendTimeArr.first {
                self.onlinePingpongAndP2PMetricSendTime = pingpongAndP2PMetricSendTimeNum.int32Value
            }
            
            //设置请求超时时间
            if let allowPullmsgSegmentArr:[NSNumber] = configurationDict["is_allow_pullmsg_segment"] as? [NSNumber],let timeoutNum = httpRequestTimeoutArr.first {
                self.isAllowPullmsgSegment = timeoutNum.boolValue
            }
            
            //设置全局请求超时时间和重试次数
            QQUrlRequest.kTimeoutTime = self.httpRequestTimeout;
            QQUrlRequest.kRetryTime = self.httpRequestRetryCount;

            //设置备用域名列表
            if let onlineBackupHostsArray:[String] = configurationDict["hosts_backup_online"] as? [String],let onlineBackupHostsJsonStr =  onlineBackupHostsArray.first {
                let dic = NSString.dictionary(withJsonString: onlineBackupHostsJsonStr)
                HTTPDomainServer.shared()?.updateBackupDomainList(withDic: dic)
            }
            
        } else {
            #if DEBUG
                if let window = NSApp.keyWindow {
                    let alert = NSAlert()
                    alert.addButton(withTitle: "确定")
                    alert.messageText = "appconfig配置项接口有问题，快喊开发看看吧！！！"
                    alert.beginSheetModal(for: window) { (returnCode:NSApplication.ModalResponse) in
                        
                    }
                }
            #endif
        }
    }
}
