//
//  QQCheckDevicePrepareView.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/2/25.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Cocoa

class QQCheckDevicePrepareView: NSView,QQNibLoadProtocol {

    var preparedBlock:Block?
    var closeBlock:Block?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.white.cgColor
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
}

extension QQCheckDevicePrepareView {
    
    @IBAction func didClickOnPrepareSuccessButton(_ sender: Any) {
        self.preparedBlock?()
    }
    
    @IBAction func didClickOnCloseButton(_ sender: Any) {
        self.closeBlock?()
    }

}
