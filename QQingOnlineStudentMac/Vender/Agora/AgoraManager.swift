//
//  AgoraManager.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/3/4.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Cocoa
import Foundation
import AgoraRtcEngineKit


class AgoraManager: NSObject {
    
    //agoraID
    var agoraAppID: String?
    var agoraKit: AgoraRtcEngineKit!
    var timerForSpeaker: Timer?
    var remoteVideoView: NSView?
    var localVideoView: NSView?

    
    
    @objc weak var delegate:AgoraManagerProtocol?
    
    //单利初始化""
    static let sharedInstance = AgoraManager()
    private override init() {
        super.init()
    }
}

//MARK: -

extension AgoraManager {
    
    //启动agora服务
    func startAgoraService () {
        self.agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: self.agoraAppID ?? "", delegate: self)
        self.agoraKit.setChannelProfile(AgoraChannelProfile.communication)
        self.agoraKit.enableVideo()
//        self.agoraKit.enableAudio()
//        self.agoraKit.enableAudioVolumeIndication(1000, smooth: 5)
        let configuration = AgoraVideoEncoderConfiguration(size: AgoraVideoDimension320x240,
                                                           frameRate: .fps15,
                                                           bitrate: AgoraVideoBitrateStandard,
                                                           orientationMode: .adaptative)
        self.agoraKit.setVideoEncoderConfiguration(configuration)
    }
    
    //请求 - 获取agoraID
    func sig_getAgoraAppID() -> RACSignal<AnyObject> {
        return RACSignal.createSignal({ (subscriber) -> RACDisposable? in
            SignalFromRequest.signalFromPBRequest(withApiPath: kClient_GetAgoraAppIDURLString,
                                                  pbMessage: nil,
                                                  responseClass: GPBAgoraConfigResponse.self,
                                                  errorDomain: kErrorDomainPB_RequestCommon)?.onMainThread().subscribeNext({ [weak self] (response) in
                                                    guard let `self` = self else { return }
                                                    
                                                    if let res = response as? GPBAgoraConfigResponse {
                                                        self.agoraAppID = res.appId
                                                        self.startAgoraService()
                                                    }
                                                    subscriber.sendNext(nil)
                                                    subscriber.sendCompleted()
                                                    }, error: { (error) in
                                                        subscriber.sendError(error)
                                                  })
            return nil
        })
    }
    
    //加入频道
    func joinChannel(channelID:String?,localVideo:NSView,remoteVideo:NSView,completeBlock:BOOLBlock) {
        
        if let channel = channelID {
            let videoCanvas = AgoraRtcVideoCanvas()
            videoCanvas.uid = UInt(channel) ?? 0
            videoCanvas.view = localVideo
            videoCanvas.renderMode = .hidden
            agoraKit.setupLocalVideo(videoCanvas)
            self.localVideoView = localVideo
            self.remoteVideoView = remoteVideo
            agoraKit.joinChannel(byToken: nil, channelId: channel, info:nil, uid:0) { (sid, uid, elapsed) -> Void in
                
            }
        }
    }
    
    //离开频道
    func leaveChannel() {
        agoraKit.leaveChannel(nil)
        agoraKit.setupLocalVideo(nil)
        self.remoteVideoView?.removeFromSuperview()
        self.localVideoView?.removeFromSuperview()
//        delegate?.VideoChatNeedClose(self)
        agoraKit = nil
//        view.window!.close()
    }

}

//MARK: 设备检测
extension AgoraManager {
    
    //枚举麦克风设备
    func getVoiceRecordingDevices() -> NSArray {
        return self.agoraKit.enumerateDevices(AgoraMediaDeviceType.audioRecording) as NSArray? ?? NSArray()
    }
    
    //枚举扬声器设备
    func getVoiceAudioPlayDevices() -> NSArray {
        return self.agoraKit.enumerateDevices(AgoraMediaDeviceType.audioPlayout) as NSArray? ?? NSArray()
    }
    
    //枚举摄像头设备
    func getCameraDevices() -> NSArray {
        return self.agoraKit.enumerateDevices(AgoraMediaDeviceType.videoCapture) as NSArray? ?? NSArray()
    }
    
    
    //检测扬声器
    func checkAudioPlayDevice() {
        if let filePath = Bundle.main.path(forResource: "guide", ofType: "wav") {
            self.agoraKit.startPlaybackDeviceTest(filePath)
        }
    }
    //关闭扬声器检测
    func endCheckAudioPlayDevice() {
        self.agoraKit.stopPlaybackDeviceTest()
    }
    
    
    //检测麦克风
    func checkMicPhone() {
        self.agoraKit.startEchoTest { (channel, uid, elapsed) in
            print(channel)
        }
//        self.agoraKit.startRecordingDeviceTest(200)
    }
    //关闭麦克风检测
    func endCheckMicphone() {
        self.agoraKit.stopEchoTest()
    }
    
    
    //检测摄像头
    func checkCamera(view:NSView) {
        self.agoraKit.startCaptureDeviceTest(view)
    }
    //关闭摄像头检测
    func endCheckCamera() {
        self.agoraKit.stopCaptureDeviceTest()
    }
    
    //检测网络
    func checkNetwork() {
        self.agoraKit.enableLastmileTest()
    }
    //关闭网络检测
    func endCheckNetwork() {
        self.agoraKit.disableLastmileTest()
    }
    
    
    @objc func getSpeakerVolume() {
        let volume = Float(self.agoraKit.getDeviceVolume(AgoraMediaDeviceType.audioPlayout))
        self.delegate?.speakerVolume?(volume: volume/255)
    }

}

@objc protocol AgoraManagerProtocol:NSObjectProtocol {
    @objc optional func speakerVolume(volume:Float)
    @objc optional func lastmileQuality(quality: AgoraNetworkQuality)
}

extension AgoraManager: AgoraRtcEngineDelegate {
    
    //网络质量
    func rtcEngine(_ engine: AgoraRtcEngineKit, lastmileQuality quality: AgoraNetworkQuality) {
        self.delegate?.lastmileQuality?(quality: quality)
        self.endCheckNetwork()
    }
    
    //语音大小
    func rtcEngine(_ engine: AgoraRtcEngineKit, reportAudioVolumeIndicationOfSpeakers speakers: [AgoraRtcAudioVolumeInfo], totalVolume: Int) {
        self.delegate?.speakerVolume?(volume: Float(totalVolume)/255)
    }
    
    //第一帧视频
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid:UInt, size:CGSize, elapsed:Int) {
        
        self.remoteVideoView?.isHidden = false
        
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = self.remoteVideoView
        videoCanvas.renderMode = .hidden
        agoraKit.setupRemoteVideo(videoCanvas)
    }
    
    //用户离线
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid:UInt, reason:AgoraUserOfflineReason) {
        self.remoteVideoView?.isHidden = true
    }
    
//    //
//    func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoMuted muted:Bool, byUid:UInt) {
//        remoteVideo.isHidden = muted
//        remoteVideoMutedIndicator.isHidden = !muted
//    }

}

