//
//  QQBaseWebviewVC.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/3/18.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Cocoa

class QQBaseWebviewVC: NSViewController,IMYWebViewDelegate,QQJSExternalDelegate {
    
    var webHolder:EasyJSWebView?
    var notifyJSMethod:String?
    var url:String?
    
    init(url : String) {
        super.init(nibName: nil, bundle: nil)
        self.url = url
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.initData()
        self.requestWebview()
    }
    
}

//MARK: UI & Data Init
extension QQBaseWebviewVC {
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
            make?.top.equalTo()(self.view)?.with()?.offset()(40)
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
        if let url = URL.init(string:self.url ?? "") {
            let request = NSMutableURLRequest.init(url: url, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 10)
            let domainRequest = HTTPDomainServer.shared()?.getDomainPackingRequest(with: request)
            let realRequest = URLRequest.init(url: (domainRequest?.url)!, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 10)
            self.webHolder?.load(realRequest)
        }
    }
}


extension QQBaseWebviewVC {
    
    func qqJSCallBack(withContent content: String!, withMethodName methodName: String!) {
        //        print(content)
        //        do {
        //            let content =  try JSONSerialization.jsonObject(with:content.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.allowFragments)
        //            if let contentDic = content as? Dictionary<String, Any> {
        //                if let url = contentDic["url"] {
        //
        //                }
        //            }
        //        } catch{}
    }
    
}

//MARK:IMYWebViewDelegate
extension QQBaseWebviewVC {
    
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

