//
//  HomeVC.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/1/4.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Cocoa


//MARK: - Life Cycle

class HomeVC: QQBaseVC {

    @IBOutlet weak var toolbarView: NSView!
    @IBOutlet weak var titlebarBottomLineGrayView: NSView!
    
    var settingListView: SettingListView?
    var courselistWebVC:QQCourselistWebVC?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.addCourselistVC()
    }
    
    override func viewDidAppear() {
        (self.view.window as?QQBaseWindow)?.qqDelegate = self
    }
    
}

//MARK: - View

extension HomeVC {
    
    func initUI () {
        self.titlebarBottomLineGrayView.wantsLayer = true
        self.titlebarBottomLineGrayView.layer?.backgroundColor = NSColor.gray.cgColor
    }
    
    func addCourselistVC() {
        self.courselistWebVC = QQCourselistWebVC()
        self.addChildViewController(self.courselistWebVC!)
        self.view.addSubview(self.courselistWebVC!.view, positioned: NSWindow.OrderingMode.below, relativeTo: self.toolbarView)
        self.courselistWebVC?.view.mas_makeConstraints { (make) in
            make?.edges.equalTo()
        }
    }
}

//MARK: - Action

extension HomeVC {
    
    //设置按钮点击事件
    @IBAction func didClickOnSettingButton(_ sender: Any) {
//        view.window?.toggleFullScreen(nil)
//        view.window?.standardWindowButton(NSWindow.ButtonType.zoomButton)?.isHidden = true
        
        if let settingListView = self.settingListView,settingListView.isShowed {
            self.settingListView?.removeFromSuperview()
            self.settingListView?.isShowed = false
        } else {
            self.settingListView = SettingListView.loadNib(SettingListView.classNameString())
            self.settingListView?.delegate = self
            self.settingListView?.frame = self.view.bounds
            self.settingListView?.isShowed = true
            self.view.addSubview(self.settingListView!)
        }
    }
    
    //刷新按钮点击事件
    @IBAction func didClickOnRefreshButton(_ sender: Any) {
        self.courselistWebVC?.requestWebview()
    }
    
    //帮助按钮点击事件
    @IBAction func didClickOnHelpButton(_ sender: Any) {
        view.window?.close()
        //切换到课堂页
//        AppDelegate.loadClassroomWindowVC()
    }
    
    //头像按钮点击事件
    @IBAction func didClickOnHeadButton(_ sender: Any) {
        
    }
}

//MARK: Protocol

extension HomeVC:SettingListViewProtocol {
    
    //检测设备
    func checkDevice() {
        let qqcheckDeviceView = QQCheckDeviceView.loadNib(QQCheckDeviceView.classNameString())
        QQProgressUtils.showPopup(qqcheckDeviceView)
        
        self.settingListView?.removeFromSuperview()
        self.settingListView?.isShowed = false
        
    }
    
    //学习锁
    func studyLock() {
        
    }
    
    //检测升级
    func checkUpdate() {
        
    }
    
    //关于
    func about() {
        
    }
}

extension HomeVC:QQBaseWindowProtocol {
    
    //window尺寸变化
    func windowWillResize(size: NSSize) {
        self.settingListView?.frame = NSRect(x: 0,
                                             y: 0,
                                             width: size.width,
                                             height: size.height)
    }
}
