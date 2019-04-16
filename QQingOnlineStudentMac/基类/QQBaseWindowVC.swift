//
//  QQBaseWindowVC.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/1/3.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Cocoa

class QQBaseWindowVC: NSWindowController {
//    [[NSNotificationCenter defaultCenter] addObserver:window
//    selector:@selector(windowDidResize:)
//    name:NSWindowDidResizeNotification
    
    override func windowDidLoad() {
        super.windowDidLoad()
//        NotificationCenter.default.addObserver(self.window,
//                                               selector: #selector(windowDidResize(notification:)),
//                                               name: Notification.Name(rawValue: "NSWindowDidResizeNotification"),
//                                               object: nil)
    }
    
    @objc func windowDidResize(notification:NSNotification) {
        print("fsfsdfsd")
    }
    
     
    
    
//    -(NSSize)windowWillResize:(NSWindow *)sender
//    toSize:(NSSize)frameSize
//    {
//    frameSize.width = frameSize.height*2;
//    return frameSize;
//
//    ---------------------
//    作者：黄权浩
//    来源：CSDN
//    原文：https://blog.csdn.net/quanhaoH/article/details/86496635
//    版权声明：本文为博主原创文章，转载请附上博文链接！
    
}
