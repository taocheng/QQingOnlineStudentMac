//
//  QQCheckDeviceCameraView.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/2/25.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Cocoa
import AgoraRtcEngineKit

class QQCheckDeviceCameraView: NSView,QQNibLoadProtocol {
    
    @IBOutlet weak var selectCameraButton: NSPopUpButton!
    @IBOutlet weak var cameraView: NSView!
    var canSeeBlock:Block?
    var cannotSeeBlock:Block?
    
    override func awakeFromNib() {
        self.selectCameraButton.removeAllItems()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
}

//MARK: IBAction
extension QQCheckDeviceCameraView {
    
    @IBAction func canSeeButton(_ sender: Any) {
        self.canSeeBlock?()
    }
    
    @IBAction func cannotSeeButton(_ sender: Any) {
        self.cannotSeeBlock?()
    }

}

extension QQCheckDeviceCameraView {
    
    //开启摄像头检测
    func checkCamera() {
        AgoraManager.sharedInstance.checkCamera(view: self.cameraView)
    }
    
    //枚举摄像图设备
    func listCameraDevices(){
        GCDQueue.global()?.queue({
            let cameraDevices = AgoraManager.sharedInstance.getCameraDevices()
            var cameraDevicesNameArray:[String] = []
            for device in cameraDevices {
                cameraDevicesNameArray.append((device as? AgoraRtcDeviceInfo)?.deviceName ?? "")
            }
            GCDQueue.main()?.queue({
                self.selectCameraButton.addItems(withTitles: cameraDevicesNameArray)
            })
        })
    }
}
