//
//  ViewController.h
//  ScannerProject
//
//  Created by Avinash kashyap on 09/01/15.
//  Copyright (c) 2015 Avinash kashyap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface ViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, weak) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *scanButton;
-(IBAction)clickButtonAction:(id)sender;
@end

