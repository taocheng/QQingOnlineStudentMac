//
//  QQNibLoadProtocol.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/2/20.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Cocoa

protocol QQNibLoadProtocol {
    
}

extension QQNibLoadProtocol where Self : NSView{
    static func loadNib(_ nibNmae :String? = nil) -> Self {
        var topLevelObjects : NSArray?
        if Bundle.main.loadNibNamed(NSNib.Name(rawValue: nibNmae ?? "\(self)"), owner: nil, topLevelObjects: &topLevelObjects) {
            return (topLevelObjects!.first(where: { $0 is NSView }) as? NSView as! Self)
        }
        return Self()
    }
}
