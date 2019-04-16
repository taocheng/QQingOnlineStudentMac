//
//  QQCourselistWebVC.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/2/27.
//  Copyright © 2019年 陶澄. All rights reserved.
//

class QQCourselistWebVC: NSViewController,IMYWebViewDelegate,QQJSExternalDelegate {
    
    
    var webHolder:EasyJSWebView?
    var notifyJSMethod:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.initData()
        self.requestWebview()
    }
    
}

//MARK: UI & Data Init
extension QQCourselistWebVC {
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
        let url = URL.init(string: "https://liveweb-tst.changingedu.com/live_course/live_course_list")
        let request = NSMutableURLRequest.init(url: url!, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 10)
        let domainRequest = HTTPDomainServer.shared()?.getDomainPackingRequest(with: request)
        let realRequest = URLRequest.init(url: (domainRequest?.url)!, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 10)
        self.webHolder?.load(realRequest)
    }
}

//MARK: QQJSExternalDelegate
extension QQCourselistWebVC {
    
    func qqJSCallBack(withContent content: String!, withMethodName methodName: String!) {
        if methodName == kEasyJSCourseList_EnterHistoryRoom {
            //回放
            do {
                let content =  try JSONSerialization.jsonObject(with:content.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.allowFragments)
                if let contentDic = content as? Dictionary<String, Any> {
                    if let url = contentDic["url"] {
                        AppDelegate.loadVideoReplayWindowVC(url: url as? String ?? "")
                    }
                }
            } catch{}
        } else if methodName == kEasyJSCourseList_DownloadPPT {
            //课件下载
            do {
                let content =  try JSONSerialization.jsonObject(with:content.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.allowFragments)
                if let contentDic = content as? Dictionary<String, Any> {
                    if let urlStr = contentDic["url"] as? String{
                        if let url = URL.init(string: urlStr) {
                            NSWorkspace.shared.open(url)
                        }
                    }
                }
            } catch{}
        } else if methodName == kEasyJSCourseList_EnterRoom {
            //进入房间
            do {
                let content =  try JSONSerialization.jsonObject(with:content.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.allowFragments)
                if let contentDic = content as? Dictionary<String, Any> {
                    if let liveOrderCourseID = contentDic["qingqing_live_order_course_id"] as? String{
                        ClassroomVM.enterClassroom(liveOrderCourseID: liveOrderCourseID)
                    }
                }
            } catch{}

        }
    }
}

//MARK:IMYWebViewDelegate
extension QQCourselistWebVC {
    
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
