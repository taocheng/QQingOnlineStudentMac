//
//  QQMainWindow.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/1/2.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Cocoa

class QQBaseWindow: NSWindow {

    weak var qqDelegate: QQBaseWindowProtocol?
    
    override var canBecomeKey: Bool{
//        self.delegate = self
        return true
    }
}

extension QQBaseWindow:NSWindowDelegate {
    
    //window尺寸变化
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        if let delegate = self.qqDelegate,delegate.responds(to: #selector(QQBaseWindowProtocol.windowWillResize(size:))) {
            delegate.windowWillResize(size: frameSize)
        }
        return frameSize
    }
    
    func windowDidResize(_ notification: Notification) {
        
    }
}

@objc protocol QQBaseWindowProtocol:NSObjectProtocol {
    @objc func windowWillResize(size:NSSize);
}


