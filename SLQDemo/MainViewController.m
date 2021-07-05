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
#import "NFCTools.h"
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
    
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc ] initWithTitle:@"读取NFC" style:UIBarButtonItemStylePlain target:self action:@selector(videoPush)];
    UIBarButtonItem *playBtn = [[UIBarButtonItem alloc] initWithTitle:@"写入NFC" style:UIBarButtonItemStylePlain target:self action:@selector(watchVideo)];
    
    self.navigationItem.rightBarButtonItem = playBtn;
    
    self.navigationItem.leftBarButtonItem = leftBar;
    
}
- (void)videoPush{
    [[NFCTools shareInstance] scanWithSuccessBlock:^(NFCNDEFMessage * _Nullable message) {
        NSLog(@"读取成功----------%@",message);
    } failedBlock:^(NSError * _Nullable error) {
        NSLog(@"读取失败----------%@",error);
    }];
    
}
- (void)watchVideo{
    
    [[NFCTools shareInstance] writeWithMessage:[self setupMessage] witeSuccessBlock:^{
        NSLog(@"写入成功----------");
    } witeFailedBlock:^(NSError * _Nullable error) {
        NSLog(@"写入失败----------%@",error);
    }];
}

- (NFCNDEFMessage *)setupMessage{
    NSString *type = @"U";
    NSData *typeData = [type dataUsingEncoding:NSUTF8StringEncoding];
    NSString *identifier = @"test1111";
    NSData *idenData = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    NSString *payloadStr = @"http://1.2.3.3:80";
    NSData *payloadData = [payloadStr dataUsingEncoding:NSUTF8StringEncoding];
    if (@available(iOS 13.0, *)) {
        NFCNDEFPayload *payload = [[NFCNDEFPayload alloc] initWithFormat:NFCTypeNameFormatNFCWellKnown type:typeData identifier:idenData payload:payloadData];
        NFCNDEFMessage *message = [[NFCNDEFMessage alloc] initWithNDEFRecords:@[payload]];
        return message;
    } else {
        return nil;
    }
}

@end
