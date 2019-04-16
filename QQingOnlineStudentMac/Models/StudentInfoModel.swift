//
//  StudentInfoModel.swift
//  QQingOnlineStudentMac
//
//  Created by 陶澄 on 2019/1/10.
//  Copyright © 2019年 陶澄. All rights reserved.
//

import Foundation

class StudentInfoModel: NSObject {
    
    //用户id
    @objc var qqUserID: String?
    //用户头像url
    @objc var headImageUrl: String?
    //登录状态
    @objc var isLoggedin: Bool
    //城市id
    @objc var cityID: Int
    //用户性别
    @objc var sex: Int
    //年级id
    var gradeID: Int?
    //用户昵称
    var nickName: String?

    //单利初始化
    @objc static let sharedInstance = StudentInfoModel()
    private override init() {
        self.isLoggedin = false
        self.cityID = 0
        self.sex = 10
    }
}

//MARK: - Request

extension StudentInfoModel {
    
    //请求 - 获取学生基本信息接口
    func sig_studentBaseInfo() ->RACSignal<AnyObject> {
        return RACSignal.createSignal({ (subscriber) -> RACDisposable? in
            
            SignalFromRequest.signalFromPBRequest(withApiPath: kStudent_Profile_GetBaseInfoURLString,
                                                  pbMessage: nil,
                                                  responseClass: GPBStudentBaseInfoForStudentResponse.self,
                                                  errorDomain: kErrorDomain_FetchStudentBaseInfo)?.subscribeNext({ [weak self] (response) in
                                                    
                                                        guard let `self` = self else { return }
                                                    
                                                        //更新基本信息
                                                        if let res = response as? GPBStudentBaseInfoForStudentResponse {
                                                            self.updateStudentBaseInfo(baseInfo: res)
                                                        }
                                                    
                                                        subscriber.sendNext(nil)
                                                        subscriber.sendCompleted()
                                                  }, error: { (error) in
                                                        subscriber.sendError(error)
                                                  })
            return nil
        })
    }
    
    //请求 - 获取年级科目信息
    func sig_courseGradeListInfo() -> RACSignal<AnyObject> {
        return RACSignal.createSignal({ (subscriber) -> RACDisposable? in

            let requestUrl = kClient_CourseAndGradeInfoURLString + "?city_id=\(StudentInfoModel.sharedInstance.cityID)"
            SignalFromRequest.signalFromPBRequest(withApiPath: requestUrl,
                                                  httpMethod: HTTP_GET,
                                                  supportHttpCache:true,
                                                  pbMessage: nil,
                                                  responseClass: GPBGradeCourseListResponse.self,
                                                  errorDomain: kErrorDomainPB_GradeCourseListRequest)?.subscribeNext({ (response) in
                                                    
                                                        if let res = response as? GPBGradeCourseListResponse {
                                                            let courseListArray = NSMutableArray()
                                                            let validCourseListArray = NSMutableArray()
                                                            let gradeCourseArray: [GPBGradeCourse] = res.gradeCourseList.gradeCoursesArray as? [GPBGradeCourse] ?? []
                                                            let courseArray: [GPBCourse] = res.gradeCourseList.coursesArray as? [GPBCourse] ?? []
                                                            
                                                            //查找开放的科目
                                                            for gradeCourse:GPBGradeCourse in gradeCourseArray {
                                                                let courseIDNumer = NSNumber.init(value: gradeCourse.courseId)
                                                                if !validCourseListArray.contains(courseIDNumer) {
                                                                    validCourseListArray.add(courseIDNumer)
                                                                }
                                                            }
                                                            
                                                            //查找已开通的科目
                                                            for courseItem:GPBCourse in courseArray {
                                                                let course = Course()
                                                                course.id = courseItem.courseId
                                                                course.name = courseItem.courseName
                                                                course.type = 1
                                                                course.isOpen = validCourseListArray.contains(NSNumber.init(value: courseItem.courseId)) ? 1:0
                                                                courseListArray.add(course)
                                                            }
                                                            
                                                            //保存开通的科目
                                                            CourseCache.shared()?.removeAllObject()
                                                            CourseCache.shared()?.add(courseListArray)
                                                        }
                                                    
                                                        subscriber.sendNext(response)
                                                        subscriber.sendCompleted()
                                                  }, error: { (error) in
                                                        subscriber.sendError(error)
                                                  })
                return nil
        })
    }
}

//MARK: - Private Method

extension StudentInfoModel {
    
    //存储学生基本信息
    func updateStudentBaseInfo(baseInfo: GPBStudentBaseInfoForStudentResponse) {
        StudentInfoModel.sharedInstance.cityID = Int( baseInfo.cityId )
        StudentInfoModel.sharedInstance.nickName = baseInfo.studentInfo.userInfo.nick
        StudentInfoModel.sharedInstance.headImageUrl = baseInfo.studentInfo.userInfo.newHeadImage
        
    }
}
