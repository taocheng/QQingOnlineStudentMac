//
//  TeacherWebViewJSInterface.h
//  QQing
//
//  Created by 陶澄 on 15/6/29.
//
//

#import <Foundation/Foundation.h>

@class EasyJSWebView;

@protocol QQJSExternalDelegate <NSObject>

- (void)qqJSCallBackWithContent:(NSString *)content withMethodName:(NSString *)methodName;

@end

@interface QQJSExternal : NSObject

@property (nonatomic, weak) id<QQJSExternalDelegate> delegate;
@property (nonatomic, weak) EasyJSWebView *webView;

/*
 * 通过EasyJS与h5页面交互
 *
 * @return param    content     返回的参数
 * @return param    methodName  返回的方法名，通过这个可以区分是什么回调
 *
 */
- (void)qqJSCallBackWithContent:(NSString *)content withMethodName:(NSString *)methodName;

- (void)qqJSAsyncGetContent:(NSString *)methodName callBack:(NSString *)funcID;

- (NSString *)qqJSCallBackGetContent:(NSString *)methodName;  // 5.3.5版本开始弃用同步接口，之前的全换成qqJSAsyncGetContent:callBack:异步接口

@end
