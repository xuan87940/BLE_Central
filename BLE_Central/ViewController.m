//
//  ViewController.m
//  BLE_Central
//
//  Created by YaSheng on 2015/10/2.
//  Copyright (c) 2015年 YaSheng. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface ViewController ()

@end

@implementation ViewController
{
    CBPeripheral *device;
}

@synthesize scanServicesButton;
@synthesize connectButton;
@synthesize scanButton;
@synthesize CBC;
@synthesize CBP;
@synthesize wasConnectedBeforBackground;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(applicationDidEnterBackground:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(applicationDidBecomeActive:)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    
    
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"Initializing BLE");

    self.CBC = [CBCMCtrl alloc];
    self.CBP = [CBCPCtrl alloc];
    if (self.CBC) {
        self.CBC.cBCM = [[CBCentralManager alloc] initWithDelegate:self.CBC queue:nil];
        self.CBC.delegate = self;
    }
    if (self.CBP) {
        self.CBP.delegate = self;
    }

    
}

- (void)viewDidUnload
{
    NSLog(@"viewDidUnload");
    [self setScanButton:nil];
    [self setConnectButton:nil];
    [self setScanServicesButton:nil];
    [super viewDidUnload];

}


- (void) applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"applicationDidEnterBackground");
    if (self.CBP.cBCP.isConnected) {
        NSLog(@"Disconnecting from connected peripheral");
        self.wasConnectedBeforBackground = true;
        [self.CBC.cBCM cancelPeripheralConnection:self.CBP.cBCP];
    }
    else self.wasConnectedBeforBackground = false;
}

- (void) applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"applicationDidBecomeActive");
    if (self.wasConnectedBeforBackground) {
        NSLog(@"Was connected before, connecting again");
        [self.CBC.cBCM connectPeripheral:self.CBP.cBCP options:nil];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}
- (IBAction)scanButtonPress:(id)sender {
    if (self.CBC.cBReady) {
        // BLE HW is ready start scanning for peripherals now.
        NSLog(@"Button pressed, start scanning ...");
        [self.scanButton setTitle:@"Scanning ..." forState:UIControlStateNormal];
        [self.CBC.cBCM scanForPeripheralsWithServices:nil options:nil];
    }
}

- (IBAction)connectButtonPress:(id)sender {
    if(self.CBP.cBCP) {
        if(!self.CBP.cBCP.isConnected) {
            [self.CBC.cBCM connectPeripheral:self.CBP.cBCP options:nil];
            [self.connectButton setTitle:@"Disconnect ..." forState:UIControlStateNormal];
        }
        else {
            [self.CBC.cBCM cancelPeripheralConnection:self.CBP.cBCP];
            [self.connectButton setTitle:@"Connect ..." forState:UIControlStateNormal];
        }
    }
}

- (void) updateCMLog:(NSString *)text {
    NSLog(@"%@",text);
}

- (void) updateCPLog:(NSString *)text {
}


- (void) foundPeripheral:(CBPeripheral *)p {
    [connectButton setEnabled:true];
    self.CBP.cBCP = p;
}

-(void) connectedPeripheral:(CBPeripheral *)p {
    [scanServicesButton setEnabled:true];
    [NSTimer scheduledTimerWithTimeInterval:(float)5.0 target:self selector:@selector(updateRSSITimer:) userInfo:nil repeats:NO];
}

-(void) servicesRead {
    
}

- (IBAction)scanServicesButtonPress:(id)sender {
    NSLog(@"Starting Service Scan !");
    [self.CBP.cBCP setDelegate:self.CBP];
    [self.CBP.cBCP discoverServices:nil];
}

-(void) updatedRSSI:(CBPeripheral *)peripheral {
    NSLog(@"RSSI updated : %d",peripheral.RSSI.intValue);
    int barValue = peripheral.RSSI.intValue;
    barValue +=100;
    if (barValue > 100) barValue = 100;
    else if (barValue < 0) barValue = 0;

    
    //Trigger next round of measurements in 5 seconds :
    [NSTimer scheduledTimerWithTimeInterval:(float)5.0 target:self selector:@selector(updateRSSITimer:) userInfo:nil repeats:NO];
    
}

- (void) updateRSSITimer:(NSTimer *)timer {
    if (self.CBP.cBCP.isConnected) {
        [self.CBP.cBCP readRSSI];
    }
}

-(void) updatedCharacteristic:(CBPeripheral *)peripheral sUUID:(CBUUID *)sUUID cUUID:(CBUUID *)cUUID data:(NSData *)data {
    NSLog(@"updatedCharacteristic in viewController");
    [self updateCMLog:@"updatedCharacteristic in viewController"];
    [self updateCMLog:[NSString stringWithFormat:@"Updated characteristic %@ - %@ | %@",sUUID,cUUID,data]];
    NSLog(@"%@",data);
    
}

- (IBAction)readCharacteristicButtonClick:(id)sender {
    [self.CBP readCharacteristic:self.CBP.cBCP sUUID:@"180a" cUUID:@"2a26"];
    [self updateCMLog:@"Read value for FFA1 characteristic on FFA0 service"];
    
}
- (IBAction)writeCharacteristicClick:(id)sender {
    
    unsigned char data[7] = {0x00,0x80,0x80,0x80,0x80,0x10,0x84};
    int i;
    for (i=0; i<7; i++) {
        NSLog(@"%x",data[i]);
    }
    
    [self.CBP writeCharacteristic:self.CBP.cBCP sUUID:@"0001" cUUID:@"0002" data:[NSData dataWithBytes:&data length:7]];
    
    [self updateCMLog:@"Wrtie value for 0001 characteristic on 0002 service"];
}
- (IBAction)notifyCharacteristicButtonClick:(id)sender {
    [self.CBP setNotificationForCharacteristic:self.CBP.cBCP sUUID:@"0001" cUUID:@"0003" enable:TRUE];
    [self updateCMLog:@"Set notification state for 0001 characteristic on 0003 service"];
}
@end