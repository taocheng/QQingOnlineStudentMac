//
//  QQCheckDeviceProgressView.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/2/26.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Cocoa

class QQCheckDeviceProgressView: NSView {

    var lineViewArray:[NSView]?
    
    static let kLineWidth = CGFloat(5.0)
    static let kLineHeight = CGFloat(27.0)
    static let kLineInserts = CGFloat(9.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupSubviews()
    }
    
    func setupSubviews() {
        
        self.lineViewArray = Array()
        
        let length = self.frame.size.width
        let number = Int(length/(QQCheckDeviceProgressView.kLineWidth+QQCheckDeviceProgressView.kLineInserts))
        
        for index in 1...number {
            let lineView = NSView.init(frame: CGRect(x: CGFloat(index-1)*(QQCheckDeviceProgressView.kLineWidth+QQCheckDeviceProgressView.kLineInserts),
                                                     y: 0,
                                                     width: QQCheckDeviceProgressView.kLineWidth,
                                                     height: QQCheckDeviceProgressView.kLineHeight))
            lineView.wantsLayer = true
            lineView.layer?.backgroundColor = NSColor.gray.cgColor
            self.addSubview(lineView)
            self.lineViewArray?.append(lineView)
        }
    }
    
    func setProgress(progress:Float) {
        if let lineViewArray = self.lineViewArray {
            for index in 0 ..< lineViewArray.count {
                let lineView:NSView = lineViewArray[index]
                if Float(index)/Float(lineViewArray.count) > progress {
                    lineView.layer?.backgroundColor = NSColor.gray.cgColor
                } else {
                    lineView.layer?.backgroundColor = NSColorFromRGB(color_vaule: 0x0AC373).cgColor
                }
            }
        }
    }
}
