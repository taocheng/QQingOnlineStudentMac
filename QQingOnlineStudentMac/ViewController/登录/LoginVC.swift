//
//  LoginVC.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/1/2.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Cocoa
import ReactiveCocoa
import ReactiveSwift

//MARK: - Life Cycle

class LoginVC: QQBaseVC {
    
    /***************左半部分视图****************/
    @IBOutlet weak var leftView: NSView!
    
    /***************登录头部-分割线以上部分视图****************/
    @IBOutlet weak var switchSignGreenView: NSView!                                       //绿色线条
    @IBOutlet weak var switchSignGreenViewLeadingConstrainst: NSLayoutConstraint!         //绿色线条的leadingconstrainst
    @IBOutlet weak var switchCutoffGrayLineView: NSView!                                  //灰色线条
    
    /*************登录底部-登录框以及登录按钮等视图**************/
    @IBOutlet weak var switchScrollContentView: NSView!                                   //用户名密码，验证码所在的contentview
    @IBOutlet weak var switchScrollContentViewLeadingConstrainst: NSLayoutConstraint!     //用户名密码，验证码所在的contentview的leadingconstrainst
    
    @IBOutlet weak var imageVerificationContentView: NSView!                              //验证码所在输入框的contentview
    @IBOutlet weak var imageVerificationContentViewHeightConstrainst: NSLayoutConstraint! //验证码所在输入框的contentview高度的constrainst
    
    @IBOutlet weak var bottomContentView: NSView!                                         //验证码下面视图
    @IBOutlet weak var bottomContentViewTopConstrainst: NSLayoutConstraint!               //验证码下面视图与验证码所在输入框的contentview的距离
    
    @IBOutlet weak var usernameForPasswordTextfield: NSTextField!                         //密码登录：用户名输入框
    @IBOutlet weak var passwordTextfield: NSSecureTextField!                              //密码登录：密码输入框
    @IBOutlet weak var usernameForCaptchaTextField: NSTextField!                          //验证码登录：用户名输入框
    @IBOutlet weak var captchaTextfield: NSTextField!                                     //验证码登录：验证码输入框
    
    /*************属性**************/
    var loginVM: LoginVM?
    var webview:WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.initData()
        self.bindViewModel()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        //自动登录
        if let userName = self.keychainRead(KWStorageUsername),let password = self.keychainRead(KWStoragePassword) {
            self.loginVM?.usernameForPassword = userName
            self.loginVM?.password = password
            self.usernameForPasswordTextfield.stringValue = userName
            self.passwordTextfield.stringValue = password
            self.didClickOnLoginWithPasswordButton((Any).self)
        }
    }
}

//MARK: - View Init

extension LoginVC {
    
    func initUI() {
        //左边视图颜色
        self.leftView.wantsLayer = true
        self.leftView.layer?.backgroundColor = NSColorFromRGB(color_vaule: 0x0AC373).cgColor
        
        //标记线颜色
        self.switchSignGreenView.wantsLayer = true
        self.switchSignGreenView.layer?.backgroundColor = NSColor.green.cgColor
        
        //分割线颜色
        self.switchCutoffGrayLineView.wantsLayer = true
        self.switchCutoffGrayLineView.layer?.backgroundColor = NSColor.gray.cgColor

        //去掉焦点蓝色框
        self.usernameForPasswordTextfield.focusRingType = NSFocusRingType.none
        self.passwordTextfield.focusRingType = NSFocusRingType.none

    }
    
}

//MARK: - Data Init

extension LoginVC:NSAnimationDelegate {
    
    func initData () {
        self.loginVM = LoginVM()
    }

    func startAnimation(target:NSView,endpoint:NSPoint) {
        let startFrame = target.frame
        let endFrame = NSRect(x: endpoint.x, y: endpoint.y, width: startFrame.size.width, height: startFrame.size.height)
        let dictionary:[NSViewAnimation.Key : Any] = [NSViewAnimation.Key.target:target,
                                                      NSViewAnimation.Key.effect:NSViewAnimation.EffectName.fadeOut,
                                                      NSViewAnimation.Key.startFrame:NSValue.init(rect: startFrame),
                                                      NSViewAnimation.Key.endFrame:NSValue.init(rect: endFrame)]
        let animation = NSViewAnimation.init(viewAnimations: [dictionary])
        animation.duration = 2
        animation.delegate = self
        animation.animationBlockingMode = NSAnimation.BlockingMode.nonblocking

        animation.start()
    }
    
}

//MARK: - Binding View Model

extension LoginVC {
    
    func bindViewModel() {
        
        //绑定：密码登录-》用户名
        self.usernameForPasswordTextfield.reactive.continuousStringValues.observeValues { (text) in
            self.loginVM?.usernameForPassword = (text.count > 11) ? text.substring(toIndex: 11).getNumberFromString():text.getNumberFromString()
            self.usernameForPasswordTextfield.stringValue = self.loginVM?.usernameForPassword ?? ""
        }
        //绑定：密码登录-》密码
        self.passwordTextfield.reactive.continuousStringValues.observeValues { (text) in
            self.loginVM?.password = text
        }
        
        //绑定：验证码登录-》用户名
        self.usernameForCaptchaTextField.reactive.continuousStringValues.observeValues { (text) in
            self.loginVM?.usernameForVerification = (text.count > 11) ? text.substring(toIndex: 11).getNumberFromString():text.getNumberFromString()
            self.usernameForCaptchaTextField.stringValue = self.loginVM?.usernameForVerification ?? ""
        }
        //绑定：验证码登录-》验证码
        self.captchaTextfield.reactive.continuousStringValues.observeValues { (text) in
            self.loginVM?.captchaCode = text
        }
        
    }
}

//MARK: - IBAction

extension LoginVC {
    
    //关闭按钮
    @IBAction func didClickOnCloseButton(_ sender: Any) {
        view.window?.close()
        self.imageVerificationContentViewHeightConstrainst.constant = 40
        self.bottomContentViewTopConstrainst.constant = 15
    }

    //登录按钮
    @IBAction func didClickedOnLoginButton(_ sender: Any) {
        
        //关闭登录窗口
        self.didClickOnCloseButton((Any).self)
        
        //切换到主窗口
        AppDelegate.loadHomeWindowVC()
    }
    
    //登录按钮
    @IBAction func didClickOnLoginWithPasswordButton(_ sender: Any) {        
        QQProgressUtils.showLoadingView(withText: "登录中...", withXoffset: 115)
        self.loginVM?.sig_loginWithPassword(userName: self.loginVM?.usernameForPassword, password:
            self.loginVM?.password).onMainThread().subscribeNext({ (obj) in
                
                AppInitializer.sharedInstance.initiateAppAfterLaunching(block: { (success) in
                    QQProgressUtils.hideLoadingView()
                    if success {
                        //关闭登录窗口
                        self.didClickOnCloseButton((Any).self)
                        //切换到主窗口
                        AppDelegate.loadHomeWindowVC()
                    }
                })
                
        }, error: { (error) in
            QQProgressUtils.hideLoadingView()
            BasicErrorHandler.showToast(withAllError: error, withXoffset: 115)
        })
    }
    
    //验证码登录
    @IBAction func didClickOnCaptchaButton(_ sender: Any) {
        QQProgressUtils.showLoadingView(withText: "登录中...", withXoffset: 115)
        self.loginVM?.sig_signupForCaptcha().onMainThread()?.subscribeNext({ (obj) in
            QQProgressUtils.hideLoadingView()
            //关闭登录窗口
            self.didClickOnCloseButton((Any).self)
            
            //切换到主窗口
            AppDelegate.loadHomeWindowVC()
        }, error: { (error) in
            QQProgressUtils.hideLoadingView()
            BasicErrorHandler.showToast(withAllError: error, withXoffset: 115)
        })
    }

    //切换到账号密码登录
    @IBAction func didClickOnSwitchPasswordButton(_ sender: Any) {
        self.switchSignGreenViewLeadingConstrainst.constant = 20
        self.switchSignGreenView.animator().frame = CGRect(x: 20,
                                                           y: self.switchSignGreenView.frame.origin.y,
                                                           width: self.switchSignGreenView.frame.size.width,
                                                           height: self.switchSignGreenView.frame.size.height)
        
        self.switchScrollContentViewLeadingConstrainst.constant = 0
        self.switchScrollContentView.animator().frame = CGRect(x: 0,
                                                               y: self.switchScrollContentView.frame.origin.y,
                                                               width: self.switchScrollContentView.frame.size.width,
                                                               height: self.switchScrollContentView.frame.size.height)
    }

    //切换到验证码登录
    @IBAction func didClickOnVerificationButton(_ sender: Any) {
        self.switchSignGreenViewLeadingConstrainst.constant = 160
        self.switchSignGreenView.animator().frame = CGRect(x: 160,
                                                           y: self.switchSignGreenView.frame.origin.y,
                                                           width: self.switchSignGreenView.frame.size.width,
                                                           height: self.switchSignGreenView.frame.size.height)
        
        self.switchScrollContentViewLeadingConstrainst.constant = -280
        self.switchScrollContentView.animator().frame = CGRect(x: -280,
                                                               y: self.switchScrollContentView.frame.origin.y,
                                                               width: self.switchScrollContentView.frame.size.width,
                                                               height: self.switchScrollContentView.frame.size.height)

    }

}


