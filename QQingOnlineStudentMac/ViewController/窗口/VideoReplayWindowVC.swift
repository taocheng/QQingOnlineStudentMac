//
//  VideoReplayWindowVC.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/3/18.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Cocoa

class VideoReplayWindowVC: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        self.initUI()
    }
    
}

extension VideoReplayWindowVC {
    
    func initUI () {
        // 1. 设置点击内容视图时可移动窗口
        window?.isMovableByWindowBackground = true
        // 2 .设置窗口背景色为白色
        window?.backgroundColor = NSColor.white
        
    }
    
    func initContentVC(url:String) {
        let replayWebVC = QQBaseWebviewVC.init(url: url)

        self.contentViewController = replayWebVC
    }
    
}

