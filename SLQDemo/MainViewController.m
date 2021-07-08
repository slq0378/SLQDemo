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
//#import "NFCTools.h"
#import "NFCTagTools.h"
#import "NFCTableViewCell.h"

@interface MainViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,copy) NSMutableArray *datas;
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
    
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc ] initWithTitle:@"读取NFC" style:UIBarButtonItemStylePlain target:self action:@selector(read)];
    UIBarButtonItem *playBtn = [[UIBarButtonItem alloc] initWithTitle:@"写入NFC" style:UIBarButtonItemStylePlain target:self action:@selector(write)];
    
    self.navigationItem.rightBarButtonItem = playBtn;
    
    self.navigationItem.leftBarButtonItem = leftBar;

    [self.view addSubview:self.tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"NFCTableViewCell" bundle:nil] forCellReuseIdentifier:@"NFCTableViewCell"];
    
}
- (void)read{
    [[NFCTagTools shareInstance] scanWithSuccessBlock:^(NFCNDEFMessage * _Nullable message) {
        NSLog(@"读取成功----------%@",message);
        for (NFCNDEFPayload *pay in message.records) {
            NSLog(@"typeNameFormat:%d",pay.typeNameFormat);
            NSLog(@"type:%@",[[NSString alloc] initWithData:pay.type encoding:NSUTF8StringEncoding]);
            NSLog(@"identifier:%@",[[NSString alloc] initWithData:pay.identifier encoding:NSUTF8StringEncoding]);
            NSLog(@"payload:%@",[[NSString alloc] initWithData:pay.payload encoding:NSUTF8StringEncoding]);
        }
        if (message) {
            [self.datas addObject:message];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        }
        
    } failedBlock:^(NSError * _Nullable error) {
   
        if (error.code == 200) {
            NSLog(@"取消扫描----------");
        }else{
            NSLog(@"读取失败----------%@",error);
        }
    }];
    
}
- (void)write{
    
    [[NFCTagTools shareInstance] writeWithMessage:[self setupMessage] witeSuccessBlock:^{
        NSLog(@"写入成功----------");
    } witeFailedBlock:^(NSError * _Nullable error) {
        if (error.code == 200) {
            NSLog(@"取消写入----------");
        }else{
            NSLog(@"写入失败----------%@",error);
        }
    }];
}

- (NFCNDEFMessage *)setupMessage{
    NSString *type = @"U";
    NSData *typeData = [type dataUsingEncoding:NSUTF8StringEncoding];
    NSString *identifier = @"test1111";
    NSData *idenData = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    NSString *payloadStr = @"https://www.qq.com";
    NSData *payloadData = [payloadStr dataUsingEncoding:NSUTF8StringEncoding];
    if (@available(iOS 13.0, *)) {
        NFCNDEFPayload *payload = [[NFCNDEFPayload alloc] initWithFormat:NFCTypeNameFormatNFCWellKnown type:typeData identifier:idenData payload:payloadData];
        NFCNDEFMessage *message = [[NFCNDEFMessage alloc] initWithNDEFRecords:@[payload]];
        return message;
    } else {
        return nil;
    }
}

- (UITableView *)tableView {
    
    if(!_tableView) {
        
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kNavBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT-kNavBarHeight) style:UITableViewStylePlain];
        
        _tableView.delegate =self;
        
        _tableView.dataSource =self;
        
    }
    return _tableView;
}

#pragma mark - tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.datas.count;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 160;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identify =@"NFCTableViewCell";
    
    NFCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    NFCNDEFMessage *  message = self.datas[indexPath.row];
    for (NFCNDEFPayload *pay in message.records) {
        NSLog(@"typeNameFormat:%d",pay.typeNameFormat);
        NSLog(@"type:%@",[[NSString alloc] initWithData:pay.type encoding:NSUTF8StringEncoding]);
        NSLog(@"identifier:%@",[[NSString alloc] initWithData:pay.identifier encoding:NSUTF8StringEncoding]);
        NSLog(@"payload:%@",[[NSString alloc] initWithData:pay.payload encoding:NSUTF8StringEncoding]);
        
        cell.formatLabel.text  = [NSString stringWithFormat:@"%d",pay.typeNameFormat];
        cell.typeLabel.text  = [[NSString alloc] initWithData:pay.type encoding:NSUTF8StringEncoding];
        cell.identifierLabel.text  = [[NSString alloc] initWithData:pay.identifier encoding:NSUTF8StringEncoding];
        cell.payloadLabel.text  = [[NSString alloc] initWithData:pay.payload encoding:NSUTF8StringEncoding];
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
- (NSMutableArray *)datas{
    if (!_datas) {
        _datas = [NSMutableArray array];
    }
    return _datas;
}
@end
