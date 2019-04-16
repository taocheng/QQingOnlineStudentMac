//
//  SettingListView.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/2/20.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Cocoa

class SettingListView: NSView,QQNibLoadProtocol {
    
    @IBOutlet weak var backView: NSView!
    weak var delegate:SettingListViewProtocol?
    
    override func awakeFromNib() {
        self.backView.wantsLayer = true
        self.backView.layer?.borderColor = NSColor.gray.cgColor
        self.backView.layer?.borderWidth = 1
        self.backView.layer?.cornerRadius = 5
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
}

//MARK: IBAction

extension SettingListView {
    
    //设备检测按钮
    @IBAction func didClickOnCheckDeviceButton(_ sender: Any) {
        if let delegate = self.delegate,delegate.responds(to: #selector(SettingListViewProtocol.checkDevice)) {
            delegate.checkDevice()
        }
    }
    
    //学习锁按钮
    @IBAction func didClickOnStudyLockButton(_ sender: Any) {
        if let delegate = self.delegate,delegate.responds(to: #selector(SettingListViewProtocol.studyLock)) {
            delegate.studyLock()
        }
    }

    //在线升级按钮
    @IBAction func didClickOnCheckUpdateButton(_ sender: Any) {
        if let delegate = self.delegate,delegate.responds(to: #selector(SettingListViewProtocol.checkUpdate)) {
            delegate.checkUpdate()
        }
    }

    //关于按钮
    @IBAction func didClickOnAboutButton(_ sender: Any) {
        if let delegate = self.delegate,delegate.responds(to: #selector(SettingListViewProtocol.about)) {
            delegate.about()
        }
    }
}

//MARK: Protocol

@objc protocol SettingListViewProtocol: NSObjectProtocol {
    @objc func checkDevice()
    @objc func studyLock()
    @objc func checkUpdate()
    @objc func about()
}
