//
//  QQHeadVideoView.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/3/5.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Cocoa

class QQHeadVideoView: NSView,QQNibLoadProtocol {
    
    //一对一
    @IBOutlet weak var singleClassStudentVideoView: NSView!
    @IBOutlet weak var singleClassTeacherVideoView: NSView!
    @IBOutlet weak var singleClassContentView: NSView!
    
    //一对多
    @IBOutlet weak var groupClassContentView: NSView!
    @IBOutlet weak var groupClassTeacherVideoView: NSView!
    @IBOutlet weak var groupClassStudentVideoView: NSView!
    
    @IBOutlet weak var groupClassOtherStudent5VideoView: NSView!
    @IBOutlet weak var groupClassOtherStudent4VideoView: NSView!
    @IBOutlet weak var groupClassOtherStudent3VideoView: NSView!
    @IBOutlet weak var groupClassOtherStudent2VideoView: NSView!
    @IBOutlet weak var groupClassOtherStudent1VideoView: NSView!
    
    //底部控制栏
    @IBOutlet weak var networkStatusImageView: NSImageView!
    @IBOutlet weak var networkStatusLabel: NSTextField!
    @IBOutlet weak var currentLineLabel: NSTextField!
    @IBOutlet weak var classTimeLabel: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

//MARK:一对一
extension QQHeadVideoView {
    
}

//MARK:一对多
extension QQHeadVideoView {
    
}

//MARK:底部控制栏
extension QQHeadVideoView {
    
    //扬声器
    @IBAction func didClickOnSpeakerButton(_ sender: Any) {
        
    }
    
    //麦克风
    @IBAction func didClickOnMicphoneButton(_ sender: Any) {
        
    }
    
    //离开教室
    @IBAction func didClickOnLeaveClassButton(_ sender: Any) {
        
    }

}



