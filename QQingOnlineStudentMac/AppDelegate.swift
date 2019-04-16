//
//  AppDelegate.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2018/12/24.
//  Copyright © 2018年 陶澄. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject {
    
    //统计启动时间
    var launchTimeDic:[String:NSObject] = [String:NSObject]()
}

//MARK: - NSApplicationDelegate

extension AppDelegate:NSApplicationDelegate {
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        //保存启动时间
        self.launchTimeDic["start"] = NSNumber.init(value: NSDate().timeIntervalSinceNow)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        AppInitializer.sharedInstance.initiateBeforeLaunching()
        AppInitializer.sharedInstance.initiateAppBegingLaunching()
//        AppInitializer.sharedInstance.initiateAppAfterLaunching()
        AppDelegate.loadLoginWindow()
        //NSApp.beginModalSession(for: qqMainWindowVC.window!)
//        [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
//        let documentPath:String = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
//        print(documentPath)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        //程序和window同时关闭
        return true
    }
}

extension AppDelegate {
    
    //获取工程的appdelegate
    static func sharedInstance()->AppDelegate? {
        return NSApp.delegate as?AppDelegate
    }

    //加载登录窗口
    static func loadLoginWindow () {
        let loginWindowVC = LoginWindowVC(windowNibName: NSNib.Name(rawValue: "LoginWindowVC"))
        loginWindowVC.window?.center()
        loginWindowVC.window?.makeKey()
        loginWindowVC.window?.makeKeyAndOrderFront(nil)
        
    }
    
    //加载主窗口
    static func loadHomeWindowVC () {
        let homeWindowVC = HomeWindowVC(windowNibName: NSNib.Name(rawValue: "HomeWindowVC"))
        homeWindowVC.window?.center()
        homeWindowVC.window?.makeKey()
        homeWindowVC.window?.makeKeyAndOrderFront(nil)
    }
    
    //加载课堂窗口
    static func loadClassroomWindowVC(classroomVM:ClassroomVM) {
        let homeWindowVC = ClassroomWindowVC(windowNibName: NSNib.Name(rawValue: "ClassroomWindowVC"))
        homeWindowVC.initContentVC(classroomVM: classroomVM)
        homeWindowVC.window?.center()
        homeWindowVC.window?.makeKey()
        homeWindowVC.window?.makeKeyAndOrderFront(nil)
    }
    
    //课程回放窗口
    static func loadVideoReplayWindowVC(url:String) {
        let videoReplayWindowVC = VideoReplayWindowVC(windowNibName: NSNib.Name(rawValue: "VideoReplayWindowVC"))
        videoReplayWindowVC.initContentVC(url: url)
        videoReplayWindowVC.window?.center()
        videoReplayWindowVC.window?.makeKey()
        videoReplayWindowVC.window?.makeKeyAndOrderFront(nil)
    }
    
}

