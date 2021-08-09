//
//  ShareViewController.m
//  share
//
//  Created by song on 2021/7/8.
//  Copyright © 2021 难说再见了. All rights reserved.
//

#import "ShareViewController.h"
#import "AFNetworking.h"

@interface ShareViewController ()
@property (nonatomic,copy) NSMutableArray *images; // 图片数组
@property (nonatomic,strong) AFHTTPSessionManager *httpManager;
@end

@implementation ShareViewController

// 内容验证，输入过程中会不断调用此方法
- (BOOL)isContentValid {
    NSLog(@"%s",__FUNCTION__);
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}
// 发送分享内容
- (void)didSelectPost {
    
    NSLog(@"%s",__FUNCTION__);
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    NSLog(@"输入框：%@",self.textView.text);
    NSLog(@"图片：%zd",self.images.count);
    [self uploadData];
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:^(BOOL expired) {
        NSLog(@"expired:%d",expired);
    }];
}
// 点击取消按钮
- (void)didSelectCancel{

    NSLog(@"%s",__FUNCTION__);
    [super didSelectCancel];
}
// 自定义分享编辑界面sheet
- (NSArray *)configurationItems {
    NSLog(@"%s",__FUNCTION__);
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    SLComposeSheetConfigurationItem *item = [[SLComposeSheetConfigurationItem alloc] init];
    item.title = @"测试1";
    item.value = @"1";
    item.valuePending = YES;
    SLComposeSheetConfigurationItem *item2 = [[SLComposeSheetConfigurationItem alloc] init];
    item2.title = @"测试2";
    item2.value = @"2";
//    item2.valuePending = NO;
    
    return @[item,item2];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    NSLog(@"%s",__FUNCTION__);
    // 逻辑处理，是否登陆，是否允许发布图片等
    self.placeholder = @"来吧，输入你要说的话";
    
    NSUserDefaults *user = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.ask.answer.live"];
    BOOL isLogin = [user boolForKey:@"isLogin"];
    NSString *token = [user valueForKey:@"token"];
    NSLog(@"是否登陆：%d",isLogin);
    NSLog(@"登陆token：%@",token);
    [self setupManager];
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
                    [weakSelf.images addObject:url];
                }];
            }else if ([provider hasItemConformingToTypeIdentifier:@"public.movie"]){
                // 如果是视频
            }
        }
    }
    
}

#pragma mark - 上传数据
- (void)uploadData{
    NSLog(@"文字：%@",self.textView.text);
    NSLog(@"图片：%@",self.images);
    NSString *url = @"http://192.168.111.176:8888/imgs/";
    NSDictionary *param = @{
        @"text":self.textView.text
    };
    [self.httpManager POST:url parameters:param headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        // 上传附件
        NSLog(@"上传附件");
        for (NSURL *fileUrl in self.images) {
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

- (NSMutableArray *)images{
    if (!_images) {
        _images = [NSMutableArray array];
    }
    return _images;
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
