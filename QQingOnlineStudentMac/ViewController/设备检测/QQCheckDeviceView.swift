//
//  QQCheckDeviceView.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/2/20.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Cocoa

class QQCheckDeviceView: NSView,QQNibLoadProtocol {

    @IBOutlet weak var closeButton: NSButton!
    
    var checkDevicePrepareView:QQCheckDevicePrepareView?
    var checkDeviceEarphoneAndSpeakerView:QQCheckDeviceEarphoneAndSpeakerView?
    var checkDeviceCameraView:QQCheckDeviceCameraView?
    var checkDeviceMicrophoneView:QQCheckDeviceMicrophoneView?
    var checkDeviceNetworkView:QQCheckDeviceNetworkView?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.white.cgColor
        
        //准备页面
        self.checkDevicePrepareView = QQCheckDevicePrepareView.loadNib(QQCheckDevicePrepareView.classNameString())
        self.checkDevicePrepareView?.preparedBlock = {
            self.checkDevicePrepareView?.removeFromSuperview()
            self.addSubview(self.checkDeviceEarphoneAndSpeakerView!, positioned: .below, relativeTo: self.closeButton)
            self.checkDeviceEarphoneAndSpeakerView?.mas_makeConstraints({ (make) in
                make?.edges.equalTo()
            })
            //打开扬声器检测
            AgoraManager.sharedInstance.checkAudioPlayDevice()
        }
        self.checkDevicePrepareView?.closeBlock = {
            QQProgressUtils.dismissPopup()
        }
        
        //扬声器检测页面
        self.checkDeviceEarphoneAndSpeakerView = QQCheckDeviceEarphoneAndSpeakerView.loadNib(QQCheckDeviceEarphoneAndSpeakerView.classNameString())
        self.checkDeviceEarphoneAndSpeakerView?.canHearBlock = {
            self.checkDeviceEarphoneAndSpeakerView?.removeFromSuperview()
            self.addSubview(self.checkDeviceCameraView!, positioned: .below, relativeTo: self.closeButton)
            self.checkDeviceCameraView?.mas_makeConstraints({ (make) in
                make?.edges.equalTo()
            })
            //结束扬声器检测
            AgoraManager.sharedInstance.endCheckAudioPlayDevice()
            //打开摄像头检测
            self.checkDeviceCameraView?.checkCamera()
            //枚举摄像头列表
            self.checkDeviceCameraView?.listCameraDevices()
        }
        self.checkDeviceEarphoneAndSpeakerView?.cannotHearBlock = {
            self.checkDeviceEarphoneAndSpeakerView?.removeFromSuperview()
            self.addSubview(self.checkDeviceCameraView!, positioned: .below, relativeTo: self.closeButton)
            self.checkDeviceCameraView?.mas_makeConstraints({ (make) in
                make?.edges.equalTo()
            })
            //结束扬声器检测
            AgoraManager.sharedInstance.endCheckAudioPlayDevice()
            //打开摄像头检测
            self.checkDeviceCameraView?.checkCamera()
            //枚举摄像头列表
            self.checkDeviceCameraView?.listCameraDevices()
        }

        //摄像头检测
        self.checkDeviceCameraView = QQCheckDeviceCameraView.loadNib(QQCheckDeviceCameraView.classNameString())
        self.checkDeviceCameraView?.canSeeBlock = {
            self.checkDeviceCameraView?.removeFromSuperview()
            self.addSubview(self.checkDeviceMicrophoneView!, positioned: .below, relativeTo: self.closeButton)
            self.checkDeviceMicrophoneView?.mas_makeConstraints({ (make) in
                make?.edges.equalTo()
            })
            //结束摄像头检测
            AgoraManager.sharedInstance.endCheckCamera()
//            //打开麦克风检测
//            AgoraManager.sharedInstance.checkMicPhone()
            //枚举麦克风列表
            self.checkDeviceMicrophoneView?.listMicrophoneDevices()
        }
        self.checkDeviceCameraView?.cannotSeeBlock = {
            self.checkDeviceCameraView?.removeFromSuperview()
            self.addSubview(self.checkDeviceMicrophoneView!, positioned: .below, relativeTo: self.closeButton)
            self.checkDeviceMicrophoneView?.mas_makeConstraints({ (make) in
                make?.edges.equalTo()
            })
            //结束摄像头检测
            AgoraManager.sharedInstance.endCheckCamera()
//            //打开麦克风检测
//            AgoraManager.sharedInstance.checkMicPhone()
            //枚举麦克风列表
            self.checkDeviceMicrophoneView?.listMicrophoneDevices()
        }

        //麦克风检测
        self.checkDeviceMicrophoneView = QQCheckDeviceMicrophoneView.loadNib(QQCheckDeviceMicrophoneView.classNameString())
        self.checkDeviceMicrophoneView?.canHearBlock = {
            self.checkDeviceMicrophoneView?.removeFromSuperview()
            self.addSubview(self.checkDeviceNetworkView!, positioned: .below, relativeTo: self.closeButton)
            self.checkDeviceNetworkView?.mas_makeConstraints({ (make) in
                make?.edges.equalTo()
            })
            //结束麦克风检测
            AgoraManager.sharedInstance.endCheckMicphone()
            //打开网络检测
            AgoraManager.sharedInstance.checkNetwork()
        }
        self.checkDeviceMicrophoneView?.cannotHearBlock = {
            self.checkDeviceMicrophoneView?.removeFromSuperview()
            self.addSubview(self.checkDeviceNetworkView!, positioned: .below, relativeTo: self.closeButton)
            self.checkDeviceNetworkView?.mas_makeConstraints({ (make) in
                make?.edges.equalTo()
            })
            //结束麦克风检测
            AgoraManager.sharedInstance.endCheckMicphone()
            //打开网络检测
            AgoraManager.sharedInstance.checkNetwork()
        }
        
        //网络检测
        self.checkDeviceNetworkView = QQCheckDeviceNetworkView.loadNib(QQCheckDeviceNetworkView.classNameString())
        self.checkDeviceNetworkView?.ignoreBlock = {
            //结束网络检测
            AgoraManager.sharedInstance.endCheckNetwork()
            QQProgressUtils.dismissPopup()
        }
        self.checkDeviceNetworkView?.knownBlock = {
            //结束网络检测
            AgoraManager.sharedInstance.endCheckNetwork()
            QQProgressUtils.dismissPopup()
        }
        
        //显示准备页面
        self.addSubview(self.checkDevicePrepareView!, positioned: .below, relativeTo: self.closeButton)
        self.checkDevicePrepareView?.mas_makeConstraints({ (make) in
            make?.edges.equalTo()
        })
    }
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
}

//MARK:IBAction
extension QQCheckDeviceView {
    
    @IBAction func didClickOnCloseButton(_ sender: Any) {
        AgoraManager.sharedInstance.endCheckAudioPlayDevice()
        AgoraManager.sharedInstance.endCheckCamera()
        AgoraManager.sharedInstance.endCheckMicphone()
        AgoraManager.sharedInstance.endCheckNetwork()
        QQProgressUtils.dismissPopup()
    }

}

