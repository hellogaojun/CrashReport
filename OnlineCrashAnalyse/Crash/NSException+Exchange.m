//
//  NSException+Exchange.m
//  OnlineCrashAnalyse
//
//  Created by gaojun on 2019/3/21.
//  Copyright © 2019年 gaojun. All rights reserved.
//

#import "NSException+Exchange.h"
#import <objc/runtime.h>

@implementation NSException (Exchange)
//+ (void)load {
//    Method originMethod = class_getInstanceMethod(self, @selector(raise));
//    Method swizzMethod = class_getInstanceMethod(self, @selector(gj_raise));
//    method_exchangeImplementations(originMethod, swizzMethod);
//}
//
//- (void)gj_raise {
//    NSLog(@"上传crash");
//    //TODO:上传成功后或者超时后进行崩溃操作
//
//    NSInteger timeout = 5;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self gj_raise];
//    });
//}

@end
