//
//  QQWhiteboardWebVC.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/3/5.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Cocoa

class QQWhiteboardWebVC: NSViewController,IMYWebViewDelegate,QQJSExternalDelegate {
    
    var webHolder:EasyJSWebView?
    var notifyJSMethod:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.initData()
        self.requestWebview()
        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.red.cgColor
    }
    
}

extension QQWhiteboardWebVC {
    func initUI(){
        self.initWebview()
        self.initJSExternal()
    }
    
    func initWebview(){
        self.webHolder = EasyJSWebView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        self.webHolder?.delegate = self
        self.view.addSubview(self.webHolder!)
        self.webHolder?.translatesAutoresizingMaskIntoConstraints = false
        self.webHolder?.mas_makeConstraints({ (make) in
            make?.top.equalTo()(self.view)
            make?.leading.equalTo()(self.view)
            make?.trailing.equalTo()(self.view)
            make?.bottom.equalTo()(self.view)
        })
        (self.webHolder?.realWebView as? WKWebView)?.customUserAgent = "studentOnlineMac/Mac/2.8.0 Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/605.1.15 (KHTML, like Gecko)"
    }
    
    func initJSExternal() {
        let interface = QQJSExternal()
        interface.delegate = self
        interface.webView = self.webHolder
        self.webHolder?.addJavascriptInterfaces(interface, withName: "QQJSExternal")
    }
    
    func initData() {
        
    }
    
    func requestWebview() {
//        let url = URL.init(string: "https://liveweb-tst.changingedu.com/live_course/live_course_list")
        let url = URL.init(string: "http://liveweb-tst.changingedu.com/live_course/mac_live_course/764847796060")
        let request = NSMutableURLRequest.init(url: url!, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 10)
        let domainRequest = HTTPDomainServer.shared()?.getDomainPackingRequest(with: request)
        let realRequest = URLRequest.init(url: (domainRequest?.url)!, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 10)
        self.webHolder?.load(realRequest)
    }
}

//MARK:QQJSExternalDelegate
extension QQWhiteboardWebVC {
    
    func qqJSCallBack(withContent content: String!, withMethodName methodName: String!) {
        
    }

}

//MARK:IMYWebViewDelegate
extension QQWhiteboardWebVC {
    
    func webView(_ webView: IMYWebView!, didFailLoadWithError error: Error!) {
        
    }
    
    func webView(_ webView: IMYWebView!, shouldStartLoadWith request: URLRequest!, navigationType: Int) -> Bool {
        return true
    }
    
    func webViewDidStartLoad(_ webView: IMYWebView!) {
        
    }
    
    func webViewDidFinishLoad(_ webView: IMYWebView!) {
        
    }
}

