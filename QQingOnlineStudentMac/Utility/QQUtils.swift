//
//  QQUtils.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/1/21.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Foundation

class QQUtils: NSObject {
    
    //初始化单利
    static let sharedInstance = QQUtils()
    private override init() { }
}

extension QQUtils {
    
    // 获取版本号
    public static func version()->String {
        let plistPath:String = Bundle.main.path(forSoundResource: NSSound.Name(rawValue: "info.plist")) ?? ""
        let plistDic = NSMutableDictionary.init(contentsOfFile: plistPath)
        let version = plistDic?["CFBundleShortVersionString"] as?String ?? ""
        return version
    }
}
