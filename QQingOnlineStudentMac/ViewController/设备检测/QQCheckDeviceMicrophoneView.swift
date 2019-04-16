//
//  QQCheckDeviceEarphoneView.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/2/25.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Cocoa
import AgoraRtcEngineKit

class QQCheckDeviceMicrophoneView: NSView,QQNibLoadProtocol,AgoraManagerProtocol {

    @IBOutlet weak var progressView: QQCheckDeviceProgressView!
    @IBOutlet weak var micphoneListButton: NSPopUpButton!
    var canHearBlock:Block?
    var cannotHearBlock:Block?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.setAgoraManagerDelegate()
    }
    
    //枚举麦克风设备
    func listMicrophoneDevices() {
        GCDQueue.global()?.queue({
            let micphoenDevices = AgoraManager.sharedInstance.getVoiceRecordingDevices()
            var micphoneDevicesNameArray:[String] = []
            for device in micphoenDevices {
                micphoneDevicesNameArray.append((device as? AgoraRtcDeviceInfo)?.deviceName ?? "")
            }
            GCDQueue.main()?.queue({
                self.micphoneListButton.removeAllItems()
                self.micphoneListButton.addItems(withTitles: micphoneDevicesNameArray)
            })
        })
    }
    
    func setAgoraManagerDelegate() {
        AgoraManager.sharedInstance.delegate = self
    }

}

//MARK: IBAction
extension QQCheckDeviceMicrophoneView {
    
    @IBAction func didClickOnStartCheckButton(_ sender: Any) {
        AgoraManager.sharedInstance.checkMicPhone()
    }

    @IBAction func didClickOnCanHearButton(_ sender: Any) {
        self.canHearBlock?()
    }
    
    @IBAction func didClickOnCannotHearButton(_ sender: Any) {
        self.cannotHearBlock?()
    }

}

extension QQCheckDeviceMicrophoneView {
    func speakerVolume(volume: Float) {
        self.progressView.setProgress(progress:volume)
    }
}
