//
//  ViewController.m
//  OnlineCrashAnalyse
//
//  Created by gaojun on 2019/3/21.
//  Copyright © 2019年 gaojun. All rights reserved.
//

#import "ViewController.h"

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
    [self testException];
}

- (void)testException {
    [self.mutableStr appendString:self.serverJson[@"str"]];
}

- (void)testSignal {
    
}

@end
