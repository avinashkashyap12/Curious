//
//  ViewController.m
//  ScannerProject
//
//  Created by Avinash kashyap on 09/01/15.
//  Copyright (c) 2015 Avinash kashyap. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.statusLabel.hidden = YES;
    //Setting background color
    self.view.backgroundColor = [UIColor whiteColor];
    
    //setting scan button border and cormer radius
    self.scanButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.scanButton.layer.borderWidth = 0.7;
    self.scanButton.layer.cornerRadius = 3;
    self.scanButton.clipsToBounds = YES;
    
    //setting status label border and corner radius
    self.statusLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.statusLabel.layer.borderWidth = 0.7;
    self.statusLabel.layer.cornerRadius = 2;
    self.statusLabel.clipsToBounds = YES;
    //setting preview view border and corner radius
    self.previewView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.previewView.layer.borderWidth = 0.5;
    self.previewView.layer.cornerRadius = 5;
    self.previewView.clipsToBounds = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
-(BOOL) startReading{
    
    NSError *error;
    
    //For Front Camera
//    AVCaptureDevice *captureDevice = [AVCaptureDevice deviceWithUniqueID:@"com.apple.avfoundation.avcapturedevice.built-in_video:1"];
    
    //For Default Camera
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"Error = %@", error.localizedDescription);
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
        [[[UIAlertView alloc] initWithTitle:@"Camera Unavailable" message:[NSString stringWithFormat:@"The %@ has not been given a permission to your camera. Please check the Privacy Settings: Settings -> %@ -> Privacy -> Camera", appName, appName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return NO;
    }
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.captureSession addOutput:captureMetadataOutput];
    
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
//    [captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeQRCode,AVMetadataObjectTypeAztecCode,AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeCode128Code]];//[NSArray arrayWithObject:AVMetadataObjectTypeCode39Code]];
    captureMetadataOutput.metadataObjectTypes = [captureMetadataOutput availableMetadataObjectTypes];
    
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    self.videoPreviewLayer.frame = self.previewView.bounds;
    [self.previewView.layer addSublayer:self.videoPreviewLayer];
    
    [self.captureSession startRunning];
    return YES;
}
//Stop Reading Code
-(void) stopReading{
    
    [self.captureSession stopRunning];
    self.captureSession = nil;
    
    [self.videoPreviewLayer removeFromSuperlayer];
    self.videoPreviewLayer = nil;
    
}

#pragma mark -
//AVCaptureMetadataOutputObjectsDelegate Delegate method
-(void) captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    if (metadataObjects != nil && [metadataObjects count]>0) {
        id metadataObj= [metadataObjects objectAtIndex:0];
        if ([metadataObj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"metadata readable object count = %d   \n Meta Data = %@",(int)metadataObjects.count,metadataObjects);
                self.statusLabel.hidden = NO;
                [self.statusLabel performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];
                [self stopReading];
                [self.scanButton setTitle:@"Scan" forState:UIControlStateNormal];
                self.scanButton.enabled = YES;
            });
        }
        else if([metadataObjects isKindOfClass:[AVMetadataFaceObject class]]){
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"metadata FaceObject object count = %d   \n Meta Data = %@",(int)metadataObjects.count,metadataObjects);
            });
            
        }
        else{
            NSLog(@"Type = not found");
        }
        
    }
}
#pragma mark -
//Start and Stop button Action
-(IBAction)clickButtonAction:(id)sender{
    
    if ([self.captureSession isRunning] == YES) {
        self.statusLabel.hidden = YES;
        self.statusLabel.text = @"";
        [self stopReading];
        [self.scanButton setTitle:@"Scan" forState:UIControlStateNormal];
    }
    else{
        if ([self startReading]) {
            self.statusLabel.hidden = NO;
            self.statusLabel.text = @"Scanning...";
            [self startReading];
            [self.scanButton setTitle:@"Stop" forState:UIControlStateNormal];
        }
        
    }
}

// Set Preview View frame during  Orientation
-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    self.videoPreviewLayer.frame = self.previewView.bounds;
}
@end
