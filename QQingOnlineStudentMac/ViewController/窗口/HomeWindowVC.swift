//
//  HomeWindowVC.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/1/4.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Cocoa

//MARK: - Life Cycle

class HomeWindowVC: QQBaseWindowVC {

    override func windowDidLoad() {
        super.windowDidLoad()
        self.initUI()
        self.initContentVC()
    }
    
}

extension HomeWindowVC {
    
    func initUI () {
        // 1. 设置点击内容视图时可移动窗口
        window?.isMovableByWindowBackground = true
        // 2 .设置窗口背景色为白色
        window?.backgroundColor = NSColor.white
        
    }
    
    func initContentVC() {
        let homeVC = HomeVC()
        self.contentViewController = homeVC
        
        print("")
    }
    
}

