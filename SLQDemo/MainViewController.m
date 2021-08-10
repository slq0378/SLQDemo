//
//  ViewController
//
//
//  Created by song on 2021/5/13.
//  Copyright © 2021 song. All rights reserved.

#import "MainViewController.h"


@interface MainViewController ()
@end

@implementation MainViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"我的小窗口";

    NSUserDefaults *user = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.ask.answer.live"];
    [user setBool:YES forKey:@"isLogin"];
    [user setValue:@"xjsjsjjs-1h3j23hsdf0sd--sdfssdf" forKey:@"token"];
}


@end
