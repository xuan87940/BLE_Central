//
//  ViewController.h
//  BLE_Central
//
//  Created by YaSheng on 2015/10/2.
//  Copyright (c) 2015年 YaSheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBCMCtrl.h"
#import "CBCPCtrl.h"
@interface ViewController : UIViewController<CBCMCtrlDelegate,CBCPCtrlDelegate>

@property (strong,nonatomic) UIWindow *window;
@property (strong,nonatomic) CBCMCtrl *CBC;
@property (strong,nonatomic) CBCPCtrl *CBP;
@property (nonatomic) boolean_t wasConnectedBeforBackground;


- (IBAction)scanButtonPress:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *scanButton;

- (IBAction)connectButtonPress:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *scanServicesButton;
- (IBAction)scanServicesButtonPress:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *readCharacteristicButton;
- (IBAction)readCharacteristicButtonClick:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *writeCharacteristicButton;
- (IBAction)writeCharacteristicClick:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *notifyCharacteristicButton;
- (IBAction)notifyCharacteristicButtonClick:(id)sender;



- (void) applicationDidEnterBackground:(UIApplication *)application;
- (void) applicationDidBecomeActive:(UIApplication *)application;


- (void) updateRSSITimer:(NSTimer *)timer;

@end

