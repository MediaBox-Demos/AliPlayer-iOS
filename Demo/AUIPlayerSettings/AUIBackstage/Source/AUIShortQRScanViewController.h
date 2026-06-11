//
//  AUIShortQRScanViewController.h
//  AUIPlayer
//
//  Created by aqi on 2025/4/18.
//

#import <UIKit/UIKit.h>

typedef void(^scanTextCallBack)(NSString *text);


@interface AUIShortQRScanViewController : UIViewController

@property (nonatomic,strong)scanTextCallBack scannedTextCallBack;
@property (nonatomic,copy)void(^scanPageBack)(void);

@end
