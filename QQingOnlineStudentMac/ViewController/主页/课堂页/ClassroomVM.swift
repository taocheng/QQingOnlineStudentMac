//
//  ClassroomVM.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/3/5.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Cocoa

class ClassroomVM: NSObject {
    
    //课程ID
    var qqingLiveOrderCourseID:String? = nil
    //课程信息
    var liveOrderCourseInfo:GPBLiveOrderCourseInfoResponse? = nil
    //学生信息
    var studentInfoArray:NSArray? = nil
    //点赞个数
    var appraiseCount = 0

}

extension ClassroomVM {
    static func enterClassroom(liveOrderCourseID:String) {
        
        if let registerSuccess = QQSocketIOManager.sharedInstance()?.registerSuccess,registerSuccess {
            
            QQProgressUtils.showLoadingView()
            
            let classroomVM = ClassroomVM()
            classroomVM.qqingLiveOrderCourseID = liveOrderCourseID
            
            //检查全局升级
            AppInitializer.sharedInstance.checkUpdate { (needUpdate) in
                if needUpdate {
                    //需要升级
                    QQProgressUtils.hideLoadingView()
                } else {
                    //不需要升级,检查白名单
                    AppInitializer.sharedInstance.whiteListCheckUpdate(orderCourseID: liveOrderCourseID, completeBlock: { (whiteListNeedUpdate) in
                        if whiteListNeedUpdate {
                            //需要升级
                            QQProgressUtils.hideLoadingView()
                        } else {
                            //不需要升级，获取当前房间机房
                            QQSocketIOManager.sharedInstance()?.sig_getSocketConnectInfo(withQQingLiveOrderCourseID: liveOrderCourseID, withCheckService: false)?.subscribeNext({ (isCloseCurrentConnect) in
                                
                                //一直等待新机房连接成功
                                if let isCloseCurrentConnect = isCloseCurrentConnect as? NSNumber,isCloseCurrentConnect.boolValue {
                                    while (!(QQSocketIOManager.sharedInstance()?.registerSuccess)!){}
                                }
                                
                                //进入房间
                                classroomVM.sig_enterClassroom(qqingRoomID: liveOrderCourseID).flattenMap { (value) -> RACSignal<AnyObject>? in
                                    //获取课程详情
                                    return classroomVM.sig_getLiveOrderCourseInfo(liveOrderCourseID: liveOrderCourseID)
                                }.flattenMap { (value) -> RACSignal<AnyObject>? in
                                    //获取互动详情
                                    return classroomVM.sig_getLiveOrderCourseInteractionInfo(liveOrderCourseID: liveOrderCourseID)
                                }.onMainThread()?.subscribeNext({ (response) in
                                    QQProgressUtils.hideLoadingView()
                                    //进入课堂
                                    AppDelegate.loadClassroomWindowVC(classroomVM: classroomVM)
                                }, error: { (error) in
                                    QQProgressUtils.hideLoadingView()
                                })
                                
                            }, error: { (error) in
                                //                                                                                    [[GCDQueue mainQueue] queueBlock:^{
                                //                                                                                        [Utils hideLoadingView];
                                //                                                                                        ShowToastWithAllError(error);
                                //                                                                                        [MetricDataCollectionService sharedInstance].courseID = nil;
                                //                                                                                        [QQingClassInfoColectionService sharedInstance].courseID = nil;
                                //                                                                                        [QQSocketIOManager sharedInstance].qqingLiveOrderCourseID = nil;
                                //                                                                                        }];
                            })
                        }
                    })
                }
            }
        } else {
            QQProgressUtils.showToast(withText: "白板链接失败，请稍后重试")
        }
    }
}

//MARK:request
extension ClassroomVM {
    
    //进入房间
    func sig_enterClassroom(qqingRoomID:String) ->RACSignal<AnyObject> {
        return RACSignal.createSignal({ (subscriber) -> RACDisposable? in
            
            let request = GPBUserEnterRoomRequest()
            request.qingqingRoomId = qqingRoomID
            request.qingqingUserId = StudentInfoModel.sharedInstance().qqUserID
            request.clientId = QQSocketIOManager.sharedInstance()?.connectInfo.clientId
            SignalFromRequest.signalFromPBRequest(withApiPath: kClient_EnterClassRoomURLString,
                                                  pbMessage: request,
                                                  responseClass: GPBSimpleResponse.self,
                                                  errorDomain: kErrorDomainPB_OnlineClassEnterClassroomRequest)?.subscribeNext({ (response) in
                                                        subscriber.sendNext(response)
                                                        subscriber.sendCompleted()
                                                  }, error: { (error) in
                                                        subscriber.sendError(error)
                                                  })
            
            return nil
        })
    }
    
    //获取当前这节课的socket链接信息
    func sig_getSocketConnectInfo(qqLiveOrderCourseID:String? = nil) -> RACSignal<AnyObject> {
        return RACSignal.createSignal({ (subscriber) -> RACDisposable? in
            let request = GPBQueryClientConnectionRequest()
            request.platformType = GPBPlatformType.ipad
            request.deviceId = FCUUID.uuidForDevice()
            if let qqCourseID = qqLiveOrderCourseID {
                request.qingqingLiveOrderCourseId = qqCourseID
            }
            SignalFromRequest.signalFromPBRequest(withApiPath: kClient_GetSocketConnectInfoURLString,
                                                  pbMessage: request,
                                                  responseClass: GPBQueryClientConnectionResponse.self,
                                                  errorDomain: kErrorDomainPB_RequestCommon)?.subscribeNext({ (response) in
                                                        subscriber.sendNext(response)
                                                        subscriber.sendCompleted()
                                                  }, error: { (error) in
                                                        subscriber.sendError(error)
                                                  })
            
            return nil
        })
    }
    
    //获取教室信息
    func sig_getLiveOrderCourseInfo(liveOrderCourseID:String) ->RACSignal<AnyObject> {
        return RACSignal.createSignal({ (subscribe) -> RACDisposable? in
            let request = GPBSimpleQingqingOrderCourseIdRequest()
            request.qingqingOrderCourseId = liveOrderCourseID
            SignalFromRequest.signalFromPBRequest(withApiPath: kClient_OnlineCourseInfoURLString,
                                                  pbMessage: request,
                                                  responseClass: GPBLiveOrderCourseInfoResponse.self,
                                                  errorDomain: kErrorDomainPB_RequestCommon)?.subscribeNext({[weak self] (response) in
                                                        guard let `self` = self else { return }

                                                        self.liveOrderCourseInfo = response as? GPBLiveOrderCourseInfoResponse
                                                        self.studentInfoArray = self.liveOrderCourseInfo?.liveOrderCourseV2.studentInfoArray;
                                                        subscribe.sendNext(response)
                                                        subscribe.sendCompleted()
                                                  }, error: { (error) in
                                                        subscribe.sendError(error)
                                                  })
            
            return nil
        })
    }
    
    //获取互动详情
    func sig_getLiveOrderCourseInteractionInfo(liveOrderCourseID:String) ->RACSignal<AnyObject> {
        return RACSignal.createSignal({ (subscribe) -> RACDisposable? in
            let request = GPBTeacherStudentInteractionCountRequest()
            request.qingqingLiveOrderCourseId = liveOrderCourseID
            let interactionTypeArray = GPBEnumArray.init()
            interactionTypeArray.addValue(GPBInteractionType.thumbUpInteractionType.rawValue)
            request.interactionTypeArray = interactionTypeArray
            SignalFromRequest.signalFromPBRequest(withApiPath: kClient_OnlineCourseInteractionInfoURLString,
                                                  pbMessage: request,
                                                  responseClass: GPBTeacherStudentInteractionCountResponse.self,
                                                  errorDomain: kErrorDomainPB_RequestCommon)?.subscribeNext({[weak self] (response) in
                                                    
                                                    guard let `self` = self else { return }

                                                        if let responseData = response as? GPBTeacherStudentInteractionCountResponse {
                                                            for (_,value) in responseData.userItemsArray.enumerated() {
                                                                if let item = value as? GPBUserInteractionCountItem {
                                                                    if item.user.qingqingUserId == StudentInfoModel.sharedInstance().qqUserID {
                                                                        for (_,value) in item.itemsArray.enumerated() {
                                                                            if let interactionCountItem = value as? GPBInteractionCountItem,interactionCountItem.interactionType == GPBInteractionType.thumbUpInteractionType {
                                                                                self.appraiseCount = Int(interactionCountItem.interactionTypeCount)
                                                                            }
                                                                        }
                                                                    }
                                                                }
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
