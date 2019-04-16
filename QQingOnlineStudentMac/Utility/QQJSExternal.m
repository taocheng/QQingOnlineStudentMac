//
//  TeacherWebViewJSInterface.m
//  QQing
//
//  Created by 陶澄 on 15/6/29.
//
//

#import "QQJSExternal.h"
#import <AdSupport/AdSupport.h>
#import "EasyJSDataFunction.h"
#import "CommonHeader.h"
#import "QQingOnlineStudentMac-Swift.h"

@implementation QQJSExternal

- (void)qqJSCallBackWithContent:(NSString *)content withMethodName:(NSString *)methodName {
    TestDebugLog2(@"H5模块", @"H5调用qqJSCallBackWithContent: %@ withMethodName: %@", content, methodName);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(qqJSCallBackWithContent:withMethodName:)]) {
        [self.delegate qqJSCallBackWithContent:content withMethodName:methodName];
    }
}

- (void)qqJSAsyncGetContent:(NSString *)methodName callBack:(NSString *)funcID {
    TestDebugLog2(@"H5模块", @"H5调用qqJSAsyncGetContent: %@ callBack: %@", methodName, funcID);

    NSString *stringToReturn;
    if ([methodName isEqualToString:@"tk"]) {
        TestDebugLog2(@"H5模块", @"H5调用返回:%@", [[Cache sharedCache] token]);
        stringToReturn = [[Cache sharedCache] token];
    } else if ([methodName isEqualToString:@"si"]) {
        TestDebugLog2(@"H5模块", @"H5调用返回:%@", [[Cache sharedCache] sessionId]);
        stringToReturn = [[Cache sharedCache] sessionId];
    } else if ([methodName isEqualToString:@"ver"]) {
        TestDebugLog2(@"H5模块", @"H5调用返回:%@", [AppSystem appVersion]);
        stringToReturn = [AppSystem appVersion];
    } else if ([methodName isEqualToString:@"deviceinfo"]) {
        // 4.7.0版本中开始加入
        
        NSMutableDictionary* dictToReturn = [NSMutableDictionary dictionary];
        [dictToReturn setObject:[FCUUID uuidForDevice] forKey:@"deviceid"];
        [dictToReturn setObject:@"ios" forKey:@"devicetype"];
//        [dictToReturn setObject:[[UIDevice currentDevice] model] forKey:@"devicemodel"];
        [dictToReturn setObject:@"pad"  forKey:@"platform"];
        [dictToReturn setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey] forKey:@"appid"];
        [dictToReturn setObject:[AppSystem appVersion] forKey:@"appversion"];
        [dictToReturn setObject:[DeviceUtil systemVersion] forKey:@"osversion"];
        [dictToReturn setObject:@"AppStore" forKey:@"tunnel"];
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:dictToReturn options:0 error:nil];
        stringToReturn = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] URLEncodedString];
        TestDebugLog2(@"H5模块", @"H5调用返回:%@", stringToReturn);
    } else if ([methodName isEqualToString:@"userinfo"]) {
        // 4.7.0版本中开始加入
        NSMutableDictionary* dictToReturn = [NSMutableDictionary dictionary];
        [dictToReturn setObject:[NSString stringWithFormat:@"%d", [StudentInfoModel sharedInstance].isLoggedin] forKey:@"islogin"];
        [dictToReturn setObject:([StudentInfoModel sharedInstance].qqUserID ? [StudentInfoModel sharedInstance].qqUserID : @"") forKey:@"userid"];
        [dictToReturn setObject:([[Cache sharedCache] token] ? [[Cache sharedCache] token] : @"") forKey:@"token"];
        [dictToReturn setObject:([[Cache sharedCache] sessionId] ? [[Cache sharedCache] sessionId] : @"") forKey:@"sessionid"];
        [dictToReturn setObject:[NSString stringWithFormat:@"%ld", (long)[StudentInfoModel sharedInstance].cityID] forKey:@"cityid"];
        [dictToReturn setObject:[[[CityCache sharedCityCache] nameForId:@([StudentInfoModel sharedInstance].cityID) default:@"上海"] URLEncodedString] forKey:@"cityname"];
//        [dictToReturn setObject:@"pad"  forKey:@"platform"];
        [dictToReturn setObject:@"web"  forKey:@"platform"];

        [dictToReturn setObject:[NSString stringWithFormat:@"%ld", (long)[StudentInfoModel sharedInstance].sex] forKey:@"sex"];          // 4.8.0中加入
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:dictToReturn options:0 error:nil];
        stringToReturn = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] URLEncodedString];
        TestDebugLog2(@"H5模块", @"H5调用返回:%@", stringToReturn);
    } else if ([methodName isEqualToString:@"locationinfo"]) {
        // 4.7.0版本中开始加入
//        [QQProgressUtils showLoadingView];
//
//        __block NSMutableDictionary* dictToReturn = [NSMutableDictionary dictionary];
//        __block BOOL done = NO;
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//            [[LocationService sharedInstance] currentLocationWithBlock:^(LocationModel *location) {
//                [dictToReturn setObject:[NSString stringWithFormat:@"%d", location.cityID] forKey:@"cityid"];
//                [dictToReturn setObject:[(location.cityNameString ? location.cityNameString : @"") URLEncodedString] forKey:@"cityname"];
//                [dictToReturn setObject:[(location.district ? location.district : @"") URLEncodedString] forKey:@"district"];
//                [dictToReturn setObject:[NSString stringWithFormat:@"%f", location.longitude] forKey:@"longitude"];
//                [dictToReturn setObject:[NSString stringWithFormat:@"%f", location.latitude] forKey:@"latitude"];
//
//                done = YES;
//            }];
//        });
//        while (!done) {
//            RUNLOOP_RUN_FOR_A_WHILE;   // 或者使用 pthread_yield_np();
//        }
//        [QQProgressUtils hideLoadingView];
//
//        NSData *data = [NSJSONSerialization dataWithJSONObject:dictToReturn options:0 error:nil];
//        stringToReturn = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] URLEncodedString];
//        TestDebugLog2(@"H5模块", @"H5调用返回:%@", stringToReturn);
        stringToReturn = @"";
    }
    
    [[GCDQueue mainQueue] queueBlock:^{
        EasyJSDataFunction *ezJsDataFunc = [[EasyJSDataFunction alloc] initWithWebView:self.webView];
        ezJsDataFunc.funcID = funcID;
        ezJsDataFunc.removeAfterExecute = YES;
        [ezJsDataFunc executeNOEasyJSPrefixWithStringParam:stringToReturn completionHandler:^(NSString *result, NSError *error){
        }];
    }];
}

- (NSString *)qqJSCallBackGetContent:(NSString *)methodName {
    TestDebugLog2(@"H5模块", @"H5调用qqJSCallBackGetContent: %@", methodName);
    
    if ([methodName isEqualToString:@"tk"]) {
        TestDebugLog2(@"H5模块", @"H5调用返回:%@", [[Cache sharedCache] token]);
        return [[Cache sharedCache] token];
    } else if ([methodName isEqualToString:@"si"]) {
        TestDebugLog2(@"H5模块", @"H5调用返回:%@", [[Cache sharedCache] sessionId]);
        return [[Cache sharedCache] sessionId];
    } else if ([methodName isEqualToString:@"ver"]) {
        TestDebugLog2(@"H5模块", @"H5调用返回:%@", [AppSystem appVersion]);
        return [AppSystem appVersion];
    } else if ([methodName isEqualToString:@"deviceinfo"]) {
        // 4.7.0版本中开始加入
        
        NSMutableDictionary* dictToReturn = [NSMutableDictionary dictionary];
        [dictToReturn setObject:[FCUUID uuidForDevice] forKey:@"deviceid"];
        [dictToReturn setObject:@"ios" forKey:@"devicetype"];
//        [dictToReturn setObject:[[UIDevice currentDevice] model] forKey:@"devicemodel"];
        [dictToReturn setObject:@"mac" forKey:@"devicemodel"];
        [dictToReturn setObject:@"pad"  forKey:@"platform"];
        [dictToReturn setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey] forKey:@"appid"];
        [dictToReturn setObject:[AppSystem appVersion] forKey:@"appversion"];
        [dictToReturn setObject:[DeviceUtil systemVersion] forKey:@"osversion"];
        [dictToReturn setObject:@"AppStore" forKey:@"tunnel"];
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:dictToReturn options:0 error:nil];
        NSString *stringToReturn = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] URLEncodedString];
        TestDebugLog2(@"H5模块", @"H5调用返回:%@", stringToReturn);
        return stringToReturn;
    } else if ([methodName isEqualToString:@"userinfo"]) {
        // 4.7.0版本中开始加入
        NSMutableDictionary* dictToReturn = [NSMutableDictionary dictionary];
        [dictToReturn setObject:[NSString stringWithFormat:@"%d", [StudentInfoModel sharedInstance].isLoggedin] forKey:@"islogin"];
        [dictToReturn setObject:([StudentInfoModel sharedInstance].qqUserID ? [StudentInfoModel sharedInstance].qqUserID : @"") forKey:@"userid"];
        [dictToReturn setObject:([[Cache sharedCache] token] ? [[Cache sharedCache] token] : @"") forKey:@"token"];
        [dictToReturn setObject:([[Cache sharedCache] sessionId] ? [[Cache sharedCache] sessionId] : @"") forKey:@"sessionid"];
        [dictToReturn setObject:[NSString stringWithFormat:@"%ld", (long)[StudentInfoModel sharedInstance].cityID] forKey:@"cityid"];
//        [dictToReturn setObject:[[[CityCache sharedCityCache] nameForId:@([StudentInfoModel sharedInstance].cityID) default:@"上海"] URLEncodedString] forKey:@"cityname"];
//        [dictToReturn setObject:@"pad"  forKey:@"platform"];
        [dictToReturn setObject:@"web"  forKey:@"platform"];

        [dictToReturn setObject:[NSString stringWithFormat:@"%ld", (long)[StudentInfoModel sharedInstance].sex] forKey:@"sex"];          // 4.8.0中加入
        
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:dictToReturn options:0 error:nil];
        NSString *stringToReturn = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] URLEncodedString];
        TestDebugLog2(@"H5模块", @"H5调用返回:%@", stringToReturn);
        return stringToReturn;
    } else if ([methodName isEqualToString:@"locationinfo"]) {
        // 4.7.0版本中开始加入
//        [Utils showLoadingView];
//
//        __block NSMutableDictionary* dictToReturn = [NSMutableDictionary dictionary];
//        __block BOOL done = NO;
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//            [[LocationService sharedInstance] currentLocationWithBlock:^(LocationModel *location) {
//                [dictToReturn setObject:[NSString stringWithFormat:@"%d", location.cityID] forKey:@"cityid"];
//                [dictToReturn setObject:[(location.cityNameString ? location.cityNameString : @"") URLEncodedString] forKey:@"cityname"];
//                [dictToReturn setObject:[(location.district ? location.district : @"") URLEncodedString] forKey:@"district"];
//                [dictToReturn setObject:[NSString stringWithFormat:@"%f", location.longitude] forKey:@"longitude"];
//                [dictToReturn setObject:[NSString stringWithFormat:@"%f", location.latitude] forKey:@"latitude"];
//
//                done = YES;
//            }];
//        });
//        while (!done) {
//            RUNLOOP_RUN_FOR_A_WHILE;   // 或者使用 pthread_yield_np();
//        }
//        [Utils hideLoadingView];
//
//        NSData *data = [NSJSONSerialization dataWithJSONObject:dictToReturn options:0 error:nil];
//        NSString *stringToReturn = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] URLEncodedString];
//        TestDebugLog2(@"H5模块", @"H5调用返回:%@", stringToReturn);
//        return stringToReturn;
        return @"";
    }
    
    return nil;
}

@end


