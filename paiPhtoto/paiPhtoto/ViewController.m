//
//  ViewController.m
//  paiPhtoto
//
//  Created by fangd@silviscene.com on 2016/10/16.
//  Copyright © 2016年 fangd@silviscene.com. All rights reserved.
//

#import "ViewController.h"
#import "photoViewController.h"
#import "AJPhotoBrowserViewController.h"
#import "AJPhotoPickerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
@interface ViewController ()<UITextViewDelegate, AJPhotoPickerProtocol,AJPhotoBrowserDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)pai:(id)sender {
    photoViewController *aJPhotoPicker = [[photoViewController alloc]init];
    [self presentViewController:aJPhotoPicker animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
