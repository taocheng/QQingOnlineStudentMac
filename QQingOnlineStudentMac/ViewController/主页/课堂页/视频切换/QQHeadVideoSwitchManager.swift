//
//  QQHeadVideoSwitchManager.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/3/19.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Cocoa

//typedef NS_ENUM(NSUInteger, QQingVideoType) {
//    QQingVideoAgora = 1,
//    QQingVideoZego  = 2,
//    QQingVideoZby   = 4,
//};

enum QQingHeadVideoType {
    case QQingVideoAgora
    case QQingVideoZego
    case QQingVideoZby
}


class QQHeadVideoSwitchManager: NSObject {

    //当前流媒体的类型
    var qqHeadVideoType:QQingHeadVideoType?
    //agora详细信息
    var agoraLiveAuthInfo:GPBAgoraLiveAuthInfo?
    //zego详细信息
    var zegoLiveAuthInfo:GPBZegoLiveAuthInfo?

    //单利
    static let sharedInstance = QQHeadVideoSwitchManager()
    private override init() {
        
    }
    
}

//MARK:- Request
extension QQHeadVideoSwitchManager {
    
    func sig_getHeadVideoLine(liveOrderCourseID:String? = nil) ->RACSignal<AnyObject> {
        return RACSignal.createSignal({ (subscribe) -> RACDisposable? in
            let request = GPBLiveCommunicationAuthInfoRequest()
            request.qingqingLiveOrderCourseId = liveOrderCourseID
            let enumarray = GPBEnumArray()
            enumarray.addValue(GPBLiveCommunicationMode.modeAgora.rawValue)
            enumarray.addValue(GPBLiveCommunicationMode.modeZego.rawValue)
            //            enumarray.addValue(GPBLiveCommunicationMode..rawValue) todo:tc 接入直播云
            request.supportedModesArray = enumarray
            
            SignalFromRequest.signalFromPBRequest(withApiPath: kClient_GetEnterRoomVideoWayInfoURLString,
                                                  pbMessage: request,
                                                  responseClass: GPBLiveCommunicationAuthInfoResponse.self,
                                                  errorDomain: kErrorDomainPB_RequestCommon)?.onMainThread()?.subscribeNext({ (response) in
                                                        if let responseData = response as? GPBLiveCommunicationAuthInfoResponse {
                                                            if responseData.communicationMode == GPBLiveCommunicationMode.modeAgora {
                                                                self.qqHeadVideoType = QQingHeadVideoType.QQingVideoAgora
                                                                self.agoraLiveAuthInfo = responseData.agoraAuthInfo
                                                            } else if responseData.communicationMode == GPBLiveCommunicationMode.modeZego {
                                                                self.qqHeadVideoType = QQingHeadVideoType.QQingVideoZego
                                                                self.zegoLiveAuthInfo = responseData.zegoAuthInfo
                                                            } else if responseData.communicationMode == GPBLiveCommunicationMode.modeZego {
                                                                self.qqHeadVideoType = QQingHeadVideoType.QQingVideoZby
                                                            } else {
                                                                QQProgressUtils.showToast(withText: "暂不支持的流类型")
                                                            }
                                                        }
                                                        subscribe.sendNext(response)
                                                        subscribe.sendCompleted()
                                                  }, error: { (error) in
                                                        subscribe.sendError(error)
                                                  })
            return nil
        })
    }
}

//MARK:-
extension QQHeadVideoSwitchManager {
    
    func joinHeadVideo(headVideoView:QQHeadVideoView,completeBlock:Block,failedBlock:Block) {
        AgoraManager.sharedInstance.startAgoraService()
        AgoraManager.sharedInstance.joinChannel(channelID: self.agoraLiveAuthInfo?.agoraAppId,
                                                localVideo: headVideoView.singleClassStudentVideoView,
                                                remoteVideo: headVideoView.singleClassTeacherVideoView) { (success) in
                                                    
        }
    }
}
