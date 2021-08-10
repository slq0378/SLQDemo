//
//  ShareViewController.m
//  share
//
//  Created by song on 2021/7/8.
//  Copyright © 2021 难说再见了. All rights reserved.
//

#import "ShareViewController.h"
#import "AFNetworking.h"

@interface ShareViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,copy) NSMutableArray *datas; // 图片数组
@property (nonatomic,strong) AFHTTPSessionManager *httpManager;
@end

@implementation ShareViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    NSLog(@"%s",__FUNCTION__);
    // 逻辑处理，是否登陆，是否允许发布图片等
    self.navigationController.title = @"分享APP";
    NSUserDefaults *user = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.ask.answer.live"];
    BOOL isLogin = [user boolForKey:@"isLogin"];
    NSString *token = [user valueForKey:@"token"];
    NSLog(@"是否登陆：%d",isLogin);
    NSLog(@"登陆token：%@",token);
    self.view.backgroundColor = [UIColor whiteColor];
//    [self setupManager];
    self.datas = [NSMutableArray arrayWithArray:@[@{@"title":@"分享到微信",@"image":@"yesButton"},@{@"title":@"分享到收藏",@"image":@"noButton"}]];
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    self.navigationItem.leftBarButtonItem = left;
}
- (void)close {
    [self.extensionContext cancelRequestWithError:nil];
}
- (void)save {
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

#pragma mark - 界面显示完毕就异步加载数据到缓存
- (void)presentationAnimationDidFinish{
    NSLog(@"%s",__FUNCTION__);
    
    // 异步加载资源
    __weak typeof(self) weakSelf = self;
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *provider in item.attachments) {
            if ([provider hasItemConformingToTypeIdentifier:@"public.image"]) {
                 // 如果是图片
                [provider loadItemForTypeIdentifier:@"public.image" options:nil completionHandler:^(__kindof id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
//                    NSLog(@"读取图片%@",item);
//                    NSData *data = [NSData dataWithContentsOfURL:url];
//                    UIImage *image = [UIImage imageWithData:data];
                    NSURL *url = (NSURL *)item;
                    [weakSelf.datas addObject:url];
                }];
            }else if ([provider hasItemConformingToTypeIdentifier:@"public.movie"]){
                // 如果是视频
            }
        }
    }
    
}

#pragma mark - 上传数据
- (void)uploadData{

    NSString *url = @"http://192.168.111.176:8888/imgs/";
    NSDictionary *param = @{
       
    };
    [self.httpManager POST:url parameters:param headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        // 上传附件
        NSLog(@"上传附件");
        for (NSURL *fileUrl in self.datas) {
            NSData *data = [NSData dataWithContentsOfURL:fileUrl];
            [formData appendPartWithFileData:data name:@"images" fileName:[self uuid] mimeType:@"image/jpg"];
        }
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            NSLog(@"uploadProgress:%@",uploadProgress);
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"upload success");
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"upload failed");
        }];
}
- (void)setupManager{
    // 配置后台上传文件
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.share.upload.backgoundsession"];
    config.sharedContainerIdentifier = @"group.com.ask.answer.live";
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    AFHTTPResponseSerializer *serializer=[AFHTTPResponseSerializer serializer];
    serializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/x-msdownload",@"application/json",@"text/json", @"text/javascript",@"text/plain", nil];
    manager.responseSerializer=serializer;
    
    NSUserDefaults *user = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.ask.answer.live"];
    NSString *token = [user valueForKey:@"token"];
    // 设置token
    NSLog(@"token:%@",token);
    
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    
    self.httpManager = manager;
    
}

#pragma mark - tableView delegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identify =@"cellIdentify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    NSDictionary *info = self.datas[indexPath.row];
    cell.textLabel.text = info[@"title"];
    cell.imageView.image = [UIImage imageNamed:info[@"image"]];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSMutableArray *)datas{
    if (!_datas) {
        _datas = [NSMutableArray array];
    }
    return _datas;
}

- (NSString*)uuid
{
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    
    return [result stringByReplacingOccurrencesOfString:@"-" withString:@""];
}
@end
