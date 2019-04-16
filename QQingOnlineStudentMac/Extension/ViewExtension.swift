//
//  ViewExtension.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/2/20.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Foundation

extension NSView {
    
    /************添加属性*************/
    
    struct ViewRuntimeKey {
        static let isShowedKey = UnsafeRawPointer.init(bitPattern: "JKKey".hashValue)
        /// ...其他Key声明
    }
    
    var isShowed: Bool {
        set {
            objc_setAssociatedObject(self, ViewRuntimeKey.isShowedKey!, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        
        get {
            return  objc_getAssociatedObject(self, ViewRuntimeKey.isShowedKey!) as! Bool
        }
    }
    
    /************添加方法*************/
}
