//
//  ViewController.m
//  OnlineCrashAnalyse
//
//  Created by gaojun on 2019/3/21.
//  Copyright © 2019年 gaojun. All rights reserved.
//

#import "ViewController.h"
#import "GJPerson.h"
#import <objc/runtime.h>

@interface ViewController ()
@property (nonatomic, strong) NSMutableString *mutableStr;

@property (nonatomic, copy) NSDictionary *serverJson;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.mutableStr = [NSMutableString string];
    self.serverJson = @{@"str":[NSNull null]};
  
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self testMemoryBoom];
}

- (IBAction)exceptionCrashAction:(UIButton *)sender {
    [self testException];
}


- (IBAction)signalCrashAction:(UIButton *)sender {
    [self testSignal];
}

//普通异常
- (void)testException {
    [self.mutableStr appendString:self.serverJson[@"str"]];
 
}

//signal错误
- (void)testSignal {
    GJPerson *person = [GJPerson new];
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([person class], &count);
    for (NSUInteger i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        NSLog(@"propertyName: %@",[[NSString alloc]initWithCString:propertyName encoding:(NSASCIIStringEncoding)]);
    }
    free(properties);
    //为了让Signal错误继续回到用户层面,Debug时输入这句LLDB调试命令:pro hand -p true -s false SIGABRT
    //pro(process) hand -p(pass) true -s(stop) false SIGABRT(signal名字)
    free(properties);
    
}

//爆内存
- (void)testMemoryBoom {
    while (1) {
        UIImage *tempImage = [UIImage imageNamed:@"temp"];
        UIImageView *imView = [[UIImageView alloc]initWithImage:tempImage];
        [self.view addSubview:imView];
    }
}

//主线程卡死
- (void)testMainThreadDead {
    while (1) {
        
    }
}

//应用退到后台后,在background task模式下执行某些任务时由于超过后台保活阈值crash

@end
