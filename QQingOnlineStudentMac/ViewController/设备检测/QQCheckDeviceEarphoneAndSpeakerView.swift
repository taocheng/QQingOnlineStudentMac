//
//  QQCheckDeviceEarphoneAndSpeakerView.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/2/25.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Cocoa
import AgoraRtcEngineKit

class QQCheckDeviceEarphoneAndSpeakerView: NSView,QQNibLoadProtocol,AgoraManagerProtocol {
    
    @IBOutlet weak var progressView: QQCheckDeviceProgressView!
    @IBOutlet weak var selectDeviceButton: NSPopUpButton!
    
    var canHearBlock:Block?
    var cannotHearBlock:Block?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initUI()
        self.listAudioPlayDevice()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.setAgoraManagerDelegate()
    }
    
}

//MARK:
extension QQCheckDeviceEarphoneAndSpeakerView {
    
    func initUI() {
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.white.cgColor
        self.selectDeviceButton.removeAllItems()
    }
    
    func listAudioPlayDevice(){
        //枚举扬声器设备
        let audioPlayDevices = AgoraManager.sharedInstance.getVoiceAudioPlayDevices()
        var audioPlayDevicesNameArray:[String] = []
        for device in audioPlayDevices {
            audioPlayDevicesNameArray.append((device as? AgoraRtcDeviceInfo)?.deviceName ?? "")
        }
        self.selectDeviceButton.addItems(withTitles: audioPlayDevicesNameArray)
    }
    
    func setAgoraManagerDelegate() {
        AgoraManager.sharedInstance.delegate = self
    }
}

extension QQCheckDeviceEarphoneAndSpeakerView {
    func speakerVolume(volume: Float) {
        self.progressView.setProgress(progress:volume)
    }
}

//MARK: IBAction
extension QQCheckDeviceEarphoneAndSpeakerView {
    
    @IBAction func didClickOnCanHearButton(_ sender: Any) {
        self.canHearBlock?()
    }
    
    @IBAction func didClickOnCannotHearButton(_ sender: Any) {
        self.cannotHearBlock?()
    }

    @IBAction func didClickOnSelectDeviceButton(_ sender: Any) {
        print(self.selectDeviceButton.selectedItem?.title ?? "")
    }

}
