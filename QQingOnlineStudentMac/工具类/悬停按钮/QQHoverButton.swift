//
//  QQHoverButton.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/1/3.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Cocoa

//MARK: - Life Cycle

class QQHoverButton: NSButton {
    
    var normalImage: NSImage?
    var hoverImage: NSImage?
    
}

//MARK: - Override Function

extension QQHoverButton {
    
    //鼠标移入
    override func mouseEntered(with event: NSEvent) {
        self.image = normalImage
    }
    
    //鼠标移出
    override func mouseExited(with event: NSEvent) {
        self.image = hoverImage
    }
}

//MARK: - Public Function

extension QQHoverButton {
    func addHover(normalImageName: String, hoverImageName: String ) {
        let trackArea = NSTrackingArea(rect: bounds, options: [.activeInActiveApp,.mouseEnteredAndExited], owner: self, userInfo: nil)
        addTrackingArea(trackArea)
        normalImage = NSImage(named: NSImage.Name(normalImageName))
        hoverImage = NSImage(named: NSImage.Name(hoverImageName))
    }
}
