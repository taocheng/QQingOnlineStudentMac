//
//  QQColorDefine.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/1/18.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Foundation

func NSColorFromRGB(color_vaule : UInt64 , alpha : CGFloat = 1) -> NSColor {
    let redValue = CGFloat((color_vaule & 0xFF0000) >> 16)/255.0
    let greenValue = CGFloat((color_vaule & 0xFF00) >> 8)/255.0
    let blueValue = CGFloat(color_vaule & 0xFF)/255.0
    return NSColor(red: redValue, green: greenValue, blue: blueValue, alpha: alpha)
}
