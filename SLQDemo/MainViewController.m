//
//  ViewController
//
//
//  Created by song on 2021/5/13.
//  Copyright © 2021 song. All rights reserved.

#import "MainViewController.h"
#import "SLQPrecompile.h"

#import "Test1ViewController.h"
#import "Test2ViewController.h"
#import "Test3ViewController.h"
@interface MainViewController ()
@end

@implementation MainViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = ThemeColor;
    self.title= @"Demo1";
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
     self.navigationController.navigationBar.barTintColor = ThemeColor;
     self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:25]}];
    
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc ] initWithTitle:@"111" style:UIBarButtonItemStylePlain target:self action:@selector(videoPush)];
    UIBarButtonItem *playBtn = [[UIBarButtonItem alloc] initWithTitle:@"222" style:UIBarButtonItemStylePlain target:self action:@selector(watchVideo)];
    
    self.navigationItem.rightBarButtonItem = playBtn;

    self.navigationItem.leftBarButtonItem = leftBar;
}
- (void)videoPush{
    Test1ViewController *vc = [[Test1ViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)watchVideo{
    Test2ViewController *vc = [[Test2ViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
