//
//  NFCTools.h
//  SLQDemo
//
//  Created by song on 2021/7/5.
//  Copyright © 2021 难说再见了. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreNFC/CoreNFC.h>
typedef NS_ENUM(NSUInteger,NFCToolsUseType) {
    NFCToolsUseTypeCanRead,
    NFCToolsUseTypeDeviceNotSupport,
    NFCToolsUseTypeSystemNotSUpport,
};

typedef void(^NFCFailedBlock)(NSError * _Nullable error);
typedef void(^NFCSuccessBlock)(NFCNDEFMessage * _Nullable message);

typedef void(^NFCWriteSuccessBlock)(void);
typedef void(^NFCWriteFailedBlock)(NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface NFCTagTools : NSObject

+ (instancetype)shareInstance;
- (NFCToolsUseType)available;
- (void)beginScan;
- (void)stopScan;
- (void)setAlertMessage:(NSString *)alertMessage;
- (void)scanWithSuccessBlock:(NFCSuccessBlock)successBlock failedBlock:(NFCFailedBlock)failedBlock;
- (void)writeWithMessage:(NFCNDEFMessage *)message witeSuccessBlock:(NFCWriteSuccessBlock)writeSuccessBlock witeFailedBlock:(NFCWriteFailedBlock)writeFailedBlock;
- (NFCNDEFMessage *)setupMessage;
@end

NS_ASSUME_NONNULL_END
