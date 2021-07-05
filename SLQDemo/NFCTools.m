//
//  NFCTools.m
//  SLQDemo
//
//  Created by song on 2021/7/5.
//  Copyright © 2021 难说再见了. All rights reserved.
//

#import "NFCTools.h"

@interface NFCTools()<NFCNDEFReaderSessionDelegate>
@property (nonatomic,strong) NSString *alertMessage;
@property (nonatomic,strong) NFCNDEFReaderSession *session;
@property (nonatomic,strong) NFCNDEFMessage *message;
@property (nonatomic, copy) NFCFailedBlock failedBlock;
@property (nonatomic, copy) NFCSuccessBlock successBlock;
@property (nonatomic, copy) NFCWriteFailedBlock writeFailedBlock;
@property (nonatomic, copy) NFCWriteSuccessBlock writeSuccessBlock;
@property (nonatomic,assign) BOOL isWriting;

@end
@implementation NFCTools
static NFCTools *_NFCTools;
+(instancetype)shareInstance{
    if (!_NFCTools) {
        _NFCTools = [[NFCTools alloc] init];
        _NFCTools.alertMessage = @"把卡放到手机背面，开启读取NFC";
    }
    return _NFCTools;
}

- (NFCToolsUseType)available{
    
    if(@available(iOS 11.0,*)){
        if (NFCReaderSession.readingAvailable) {
            NSLog(@"支持NFC");
            return NFCToolsUseTypeCanRead;
        }else{
            NSLog(@"设备不支持NFC");
            return NFCToolsUseTypeDeviceNotSupport;
        }
    }else{
        NSLog(@"系统不支持NFC");
        return NFCToolsUseTypeDeviceNotSupport;
    }
    
}
- (void)beginScan{
    if (NFCToolsUseTypeCanRead == [self available]) {
        NFCNDEFReaderSession *session = [[NFCNDEFReaderSession alloc] initWithDelegate:self queue:nil invalidateAfterFirstRead:NO];
        session.alertMessage = self.alertMessage;
        [session beginSession];
        self.session = session;
    }else{
        NSLog(@"不支持读取NFC");
    }
}
- (void)stopScan{
    if (self.session) {
        [self.session invalidateSession];
    }
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

- (void)scanWithSuccessBlock:(NFCSuccessBlock)successBlock failedBlock:(NFCFailedBlock)failedBlock{
    self.successBlock = successBlock;
    self.failedBlock = failedBlock;
    self.isWriting = NO;
    [self beginScan];
}
- (void)writeWithMessage:(NFCNDEFMessage *)message witeSuccessBlock:(NFCWriteSuccessBlock)writeSuccessBlock  witeFailedBlock:(NFCWriteFailedBlock)writeFailedBlock{
    self.writeSuccessBlock = writeSuccessBlock;
    self.writeFailedBlock  = writeFailedBlock;
    self.isWriting = YES;
    [self beginScan];
}
#pragma mark - NFCNDEFReaderSessionDelegate
// 覆盖didDetectNDEFs，如果实现这个，didDetectNDEFs就不会调用
- (void)readerSession:(NFCNDEFReaderSession *)session didDetectTags:(NSArray<__kindof id<NFCNDEFTag>> *)tags API_AVAILABLE(ios(13.0)){
    NSLog(@"didDetectTags:%@",tags);
    
    if (@available(iOS 13.0, *)) {
        if(tags.count>1){
            session.alertMessage = @"存在多个标签，继续扫描";
            [session restartPolling];
            return;
        }
    
        id tag = tags.firstObject;
        [session connectToTag:tag completionHandler:^(NSError * _Nullable error) {
            if (error) {
                session.alertMessage = @"连接NFC标签失败";
                [self stopScan];
                if (self.failedBlock) {
                    self.failedBlock(error);
                }
                return;
            }
            [tag queryNDEFStatusWithCompletionHandler:^(NFCNDEFStatus status, NSUInteger capacity, NSError * _Nullable error) {
                if(error){
                    session.alertMessage = @"读取NFC标签失败";
                    [self stopScan];
                    if (self.failedBlock) {
                        self.failedBlock(error);
                    }
                    return;
                }
                else if (status == NFCNDEFStatusNotSupported ){
                    session.alertMessage = @"标签不是NDEF格式";
                    [self stopScan];
                    return;
                }
                if (!self.isWriting) {
                    [tag readNDEFWithCompletionHandler:^(NFCNDEFMessage * _Nullable message, NSError * _Nullable error) {
                        if (error) {
                            session.alertMessage = @"读取NFC标签失败";
                            [self stopScan];
                            if (self.failedBlock) {
                                self.failedBlock(error);
                            }
                            return;
                        }
                        else if(message == nil){
                            session.alertMessage = @"NFC标签为空";
                            [self stopScan];
                            return;
                        }else{
                            session.alertMessage = @"读取NFC标签成功";
                            [self stopScan];
                            NSLog(@"NFC内容：%@",message);
                
                            if (self.successBlock) {
                                self.successBlock(message);
                            }
                        }
                    }];
                    
                    [tag writeNDEF:self.message completionHandler:^(NSError * _Nullable error) {
                        if (error) {
                            session.alertMessage = @"NFC标签写入失败";
                            [self stopScan];
                            
                            if (self.writeFailedBlock) {
                                self.writeFailedBlock(error);
                            }
                        }else {
                            session.alertMessage = @"NFC标签写入成功";
                            [self stopScan];
                            if (self.writeSuccessBlock) {
                                self.writeSuccessBlock();
                            }
                        }
                    }];
                }
                
            }];
        }];
    } else {
        NSLog(@"系统版本不支持");
    }
   
}
- (void)readerSession:(NFCNDEFReaderSession *)session didDetectNDEFs:(NSArray<NFCNDEFMessage *> *)messages{
    NSLog(@"didDetectNDEFs:%@",messages);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.isWriting) {
            if (@available(iOS 11.0, *)) {
                for (NFCNDEFMessage *msg in messages) {
                    session.alertMessage = @"读取成功";
                    [self stopScan];
                    if (self.successBlock) {
                        self.successBlock(msg);
                    }
                }
            }
        } else {
            session.alertMessage = @"写入失败";
            [self stopScan];
        }
    });

}
- (void)readerSessionDidBecomeActive:(NFCNDEFReaderSession *)session{
    NSLog(@"readerSessionDidBecomeActive:%@",session);
}

- (void)readerSession:(NFCNDEFReaderSession *)session didInvalidateWithError:(NSError *)error{
    NSLog(@"didInvalidateWithError:%@",error);
    if(error.code == 201){
        session.alertMessage = @"扫描超时";
        NSLog(@"扫描超时");
    }else if(error.code == 200){
        NSLog(@"取消扫描");
        session.alertMessage = @"取消扫描";
    }
    if (self.failedBlock) {
        self.failedBlock(error);
    }
    [self stopScan];
}
@end
