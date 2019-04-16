//
//  ClassroomVC.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/3/5.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Cocoa

class ClassroomVC: NSViewController {

    @IBOutlet weak var titlebarBottomLineGrayView: NSView!
    @IBOutlet weak var toolbarView: NSView!
    @IBOutlet weak var headContentVideoView: QQHeadVideoView!
    var headVideoView:QQHeadVideoView?
    var whiteboardWebVC:QQWhiteboardWebVC?
    var classroomVM:ClassroomVM?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.addWhiteboardView()
        self.addHeadVideoView()
        self.joinHeadVideo()
//        self.headContentVideoView.wantsLayer = true
//        self.headContentVideoView.layer?.backgroundColor = NSColor.red.cgColor
        
        

    }
    
    
}

extension ClassroomVC {
    
    func initUI() {
        self.titlebarBottomLineGrayView.wantsLayer = true
        self.titlebarBottomLineGrayView.layer?.backgroundColor = NSColor.gray.cgColor
    }

    func addWhiteboardView() {
        self.whiteboardWebVC = QQWhiteboardWebVC()
        self.addChildViewController(self.whiteboardWebVC!)
        self.view.addSubview(self.whiteboardWebVC!.view, positioned: NSWindow.OrderingMode.below, relativeTo: self.toolbarView)
        self.whiteboardWebVC?.view.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.view)
            make?.top.equalTo()(self.toolbarView.mas_bottom)
            make?.bottom.equalTo()(self.view)
            make?.right.equalTo()(self.view)?.offset()(-300)
        }
    }
    
    func addHeadVideoView() {
        self.headVideoView = QQHeadVideoView.loadNib(QQHeadVideoView.classNameString())
        self.view.addSubview(self.headVideoView!)
        self.headVideoView!.mas_makeConstraints { (make) in
            make?.right.equalTo()(self.view)
            make?.bottom.equalTo()(self.view)
            make?.top.equalTo()(self.toolbarView.mas_bottom)
            make?.width.equalTo()(300)
        }
        
    }
    
}

//MARK:- Head Video
extension ClassroomVC {
    
    //加入实时音视频
    func joinHeadVideo() {
        QQHeadVideoSwitchManager.sharedInstance.sig_getHeadVideoLine(liveOrderCourseID: self.classroomVM?.qqingLiveOrderCourseID ?? "").onMainThread()?.subscribeNext({ (response) in
            QQHeadVideoSwitchManager.sharedInstance.joinHeadVideo(headVideoView: self.headVideoView!, completeBlock: {

            }, failedBlock: {

            })
        }, error: { (error) in
            BasicErrorHandler.showToast(withAllError: error)
        })
    }
    
}

