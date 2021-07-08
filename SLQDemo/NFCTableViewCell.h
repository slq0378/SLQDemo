//
//  NFCTableViewCell.h
//  SLQDemo
//
//  Created by song on 2021/7/8.
//  Copyright © 2021 难说再见了. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NFCTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *formatLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *payloadLabel;
@property (weak, nonatomic) IBOutlet UILabel *identifierLabel;

@end

NS_ASSUME_NONNULL_END
