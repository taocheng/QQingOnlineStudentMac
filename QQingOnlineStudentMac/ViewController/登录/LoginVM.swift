//
//  LoginVM.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/1/4.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Cocoa

let kAppRegisterSource: String = "1002376"

class LoginVM: NSObject {
    
    //密码登录用户名
    var usernameForPassword: String?
    //密码
    var password: String?
    //验证码登录用户名
    var usernameForVerification: String?
    //验证码
    var captchaCode: String?

    //密码登录-cmd
    var cmd_loginForPassword: RACCommand<AnyObject, AnyObject>?
    //验证码登录-cmd
    var cmd_loginForVerification: RACCommand<AnyObject, AnyObject>?
    
}

//MARK: - Request

extension LoginVM {
    
    //密码登录
    func sig_loginWithPassword(userName: String? = nil, password: String? = nil) -> RACSignal<AnyObject> {
        return RACSignal.createSignal({ [weak self] (subscriber) -> RACDisposable? in
            
            guard let `self` = self else { return nil }

            if var usernameForPassword = self.usernameForPassword,var password = self.password {
                //过滤特殊字符
                usernameForPassword = usernameForPassword.trimmingCharacters(in: .whitespacesAndNewlines)
                password = password.trimmingCharacters(in: .whitespacesAndNewlines)
                
                //检测号码有效性
                if !usernameForPassword.validMobileNumber() {
                    subscriber.sendError(NSError.makeIncludeToast(withDomain: kErrorDomain_LoginVM,
                                                                  code:ErrorCodeTeacherLoginVM.loginVM_MobileInvalid.rawValue))
                }
                
                //构建request
                let request: GPBPassportPbPasswordLoginRequest = GPBPassportPbPasswordLoginRequest()
                request.name = usernameForPassword
                request.password = password
                request.userType = GPBUserType.student
                request.accountType = GPBPassportAccountType.phonePassportAccountType
                request.deviceId = FCUUID.uuidForDevice()
                
                SignalFromRequest.signalFromPBRequest(withApiPath: kClient_Signin_LoginURLString,
                                                      pbMessage: request,
                                                      responseClass: GPBPassportLoginResponse.self,
                                                      errorDomain: kErrorDomainPB_PasswordLoginRequest)?.subscribeNext({ [weak self] (response) in
                                                        guard let `self` = self else { return }
                                                        
                                                        if let res = response as?GPBPassportLoginResponse {
                                                            //保存用户名密码
                                                            self.keychainWrite(usernameForPassword, forKey: KWStorageUsername)
                                                            self.keychainWrite(password, forKey: KWStoragePassword)
                                                            
                                                            //保存session，token等信息
                                                            LoginVM.saveLoginSuccessResponse(response: res)
                                                            
                                                            //保存用户名
                                                            Cache.shared()?.setUsername(request.name)
                                                        }
                                                        
                                                        subscriber.sendNext(NSNumber.init(value: true))
                                                        subscriber.sendCompleted()
                                                        }, error: { (error) in
                                                            subscriber.sendError(error)
                                                      });
            } else {
                subscriber.sendError(NSError.makeIncludeToast(withDomain: kErrorDomain_LoginVM,
                                                              code:ErrorCodeTeacherLoginVM.loginVM_MobileInvalid.rawValue))
            }
            return nil;
        })
    }
    
    //验证码登录
    func sig_signupForCaptcha() ->RACSignal<AnyObject> {
        return RACSignal.createSignal({ [weak self] (subscriber) -> RACDisposable? in
            guard let `self` = self else { return nil }
            
            //过滤特殊字符
            self.usernameForVerification = self.usernameForVerification?.trimmingCharacters(in: .whitespacesAndNewlines)
            self.captchaCode = self.captchaCode?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            //检测号码有效性
            if ( !(self.usernameForVerification?.isValidMobileNumber())! ) {
                    subscriber.sendError(NSError.makeIncludeToast(withDomain: kErrorDomain_LoginVM,
                                                                  code:ErrorCodeTeacherLoginVM.loginVM_MobileInvalid.rawValue))
            }
            
            //构建request
            let request: GPBPassportPbCaptchaLoginRequest = GPBPassportPbCaptchaLoginRequest()
            request.name = self.usernameForVerification
            request.captchaCode = self.captchaCode
            request.userType = GPBUserType.student
            request.deviceId = FCUUID.uuidForDevice()
            
            SignalFromRequest.signalFromPBRequest(withApiPath: kClient_Signin_LoginByCaptchaURLString,
                                                  pbMessage: request,
                                                  responseClass: GPBPassportLoginResponse.self,
                                                  errorDomain: kErrorDomain_LoginByCaptcha)?.subscribeNext({ [weak self] (response) in
                                                        guard let `self` = self else { return }

                                                        if let res = response as?GPBPassportLoginResponse {
                                                            //用户名存入钥匙串
                                                            self.keychainWrite(self.usernameForVerification, forKey: KWStorageUsername)
                                                        
                                                            //保存session，token等信息
                                                            LoginVM.saveLoginSuccessResponse(response: res)
                                                        }
                                                    
                                                        subscriber.sendNext(NSNumber.init(value: true))
                                                        subscriber.sendCompleted()
                                                  }, error: { [weak self] (error) in
                                                    
                                                        guard let `self` = self else { return }

                                                    
                                                    
                                                    
                                                        let response: GPBPassportLoginResponse = (error! as NSError).responseInfo() as! GPBPassportLoginResponse
                                                        if (response.response.errorCode == ErrorCodeTeacherLoginByCaptcha.userNotExistOrPasswordError.rawValue ||
                                                            response.response.errorCode == ErrorCodeTeacherLoginByCaptcha.registerUnCompleteError.rawValue) {
                                                            
                                                            //用户名存入钥匙串
                                                            self.keychainWrite(self.usernameForVerification, forKey: KWStorageUsername)
                                                            
                                                            //保存session，token信息
                                                            LoginVM.saveLoginSuccessResponse(response: response)
                                                            
                                                            subscriber.sendNext(NSNumber.init(value: true))
                                                            subscriber.sendCompleted()
                                                        } else {
                                                            subscriber.sendError(error)
                                                        }
                                                  })
            return nil
        }).doCompleted {
            
        }.doError({ (error) in
            
        })
    }
    
    //注册登录
    func sig_signupForVertification(type: GPBEnterType) -> RACSignal<AnyObject> {
        
        return RACSignal.createSignal({ (subscriber) -> RACDisposable? in
            
            //过滤特殊字符
            self.usernameForVerification = self.usernameForVerification?.trimmingCharacters(in: .whitespacesAndNewlines)
            self.captchaCode = self.captchaCode?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            //检测号码有效性
            if ( !(self.usernameForVerification?.isValidMobileNumber())! ) {
                subscriber.sendError(NSError.makeIncludeToast(withDomain: kErrorDomain_LoginVM,
                                                              code:ErrorCodeTeacherLoginVM.loginVM_MobileInvalid.rawValue))
            }

            //构建request
            let request: GPBRegisterRequestV2 = GPBRegisterRequestV2()
            request.username = self.usernameForVerification
            request.userType = GPBUserType.student
            request.enterType = type
            request.captchaCode = self.captchaCode
            request.deviceId = FCUUID.uuidForDevice()
            request.channelNo = "AppStore"
            request.hasGeoPoint = false
            request.spreadSource = kAppRegisterSource
            request.cityId = Int32(StudentInfoModel.sharedInstance().cityID)
            
            SignalFromRequest.signalFromPBRequest(withApiPath: kClient_LoginOrRegisterV2URLString,
                                                  pbMessage: request,
                                                  responseClass: GPBRegisterResponseV2.self,
                                                  errorDomain: kErrorDomainPB_RegisterRequest)?.subscribeNext({ [weak self] (response) in
                                                        guard let `self` = self else { return }
                                                    
                                                        if let res = response as?GPBRegisterResponseV2 {
                                                        
                                                            //用户名存入钥匙串
                                                            self.keychainWrite(self.usernameForVerification, forKey: KWStorageUsername)
                                                        
                                                            //保存session，token等信息
                                                            LoginVM.saveLoginSuccessResponse2(response: res)
                                                        }
                                                    
                                                        subscriber.sendNext(NSNumber.init(value: true))
                                                        subscriber.sendCompleted()
                                                  }, error: { [weak self] (error) in
                                                    
                                                        guard let `self` = self else { return }
                                                    
                                                        let response: GPBRegisterResponseV2 = (error! as NSError).responseInfo() as! GPBRegisterResponseV2
                                                        if (response.response.errorCode == ErrorCodePBRegisterRequest.register_AlreadyDone.rawValue) {
                                                            
                                                            //用户名存入钥匙串
                                                            self.keychainWrite(self.usernameForVerification, forKey: KWStorageUsername)
                                                            
                                                            //保存session，token信息
                                                            LoginVM.saveLoginSuccessResponse2(response: response)
                                                            
                                                            subscriber.sendNext(NSNumber.init(value: true))
                                                            subscriber.sendCompleted()
                                                        } else {
                                                            subscriber.sendError(error)
                                                        }
                                                  })
            return nil
        })
    }
    
    //自动登录
    func sig_autoLogin() -> RACSignal<AnyObject> {
        
        return RACSignal.createSignal({ (subscriber) -> RACDisposable? in
            
            //构建request
            let request: GPBPassportPtTokenSessionLoginRequest = GPBPassportPtTokenSessionLoginRequest()
            request.hasGeoPoint = false
            request.deviceId = FCUUID.uuidForDevice()
            
            SignalFromRequest.signalFromPBRequest(withApiPath: kClient_Auto_LoginURLString,
                                                  pbMessage: request,
                                                  responseClass: GPBPassportLoginResponse.self,
                                                  errorDomain: kErrorDomainPB_TkLoginRequest)?.subscribeNext({ (response) in
                                                    
                                                        if let res = response as? GPBPassportLoginResponse {
                                                            
                                                            //保存登录信息
                                                            LoginVM.saveLoginSuccessResponse(response: res)
                                                        }
                                                    
                                                        subscriber.sendNext(NSNumber.init(value: true))
                                                        subscriber.sendCompleted()
                                                  }, error: { (error) in
                                                        subscriber.sendError(error)
                                                  })
            return nil
        })
    }
}

//MARK: - Private Method

extension LoginVM {
    
    //根据GPBPassportLoginResponse保存登录信息
    static func saveLoginSuccessResponse(response:GPBPassportLoginResponse) {
        //保存token
        Cache.shared()?.setToken(response.token)
        FARequestSerialization.sharedInstance()?.setToken(response.token)
        
        //保存session
        Cache.shared()?.setSecondId(response.sessionId)
        FARequestSerialization.sharedInstance()?.setSessionId(response.sessionId)
        
        //保存userID
        Cache.shared()?.setUserID(response.userId)
        StudentInfoModel.sharedInstance().qqUserID = response.qingqingUserId
        Cache.shared()?.setUserIDString(response.qingqingUserId)
        
        //保存usersecondID
        Cache.shared()?.setSecondId(response.userSecondId)
        
        //保存登录状态
        StudentInfoModel.sharedInstance().isLoggedin = true
    }
    
    //根据GPBRegisterResponseV2保存登录信息
    static func saveLoginSuccessResponse2(response:GPBRegisterResponseV2) {
        //保存token
        Cache.shared()?.setToken(response.token)
        FARequestSerialization.sharedInstance()?.setToken(response.token)
        
        //保存session
        Cache.shared()?.setSecondId(response.sessionId)
        FARequestSerialization.sharedInstance()?.setSessionId(response.sessionId)
        
        //保存userID
        Cache.shared()?.setUserID(response.userId)
        StudentInfoModel.sharedInstance().qqUserID = response.qingqingUserId
        Cache.shared()?.setUserIDString(response.qingqingUserId)
        
        //保存usersecondID
        Cache.shared()?.setSecondId(response.userSecondId)
        
        //保存登录状态
        StudentInfoModel.sharedInstance().isLoggedin = true
    }
}
