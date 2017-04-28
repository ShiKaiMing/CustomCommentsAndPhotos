//
//  photoViewController.m
//  paiPhtoto
//
//  Created by fangd@silviscene.com on 2016/10/16.
//  Copyright © 2016年 fangd@silviscene.com. All rights reserved.
//

#import "photoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "AJPhotoBrowserViewController.h"
#import "AJPhotoPickerViewController.h"
#import "PhotoCollectionViewCell.h"

#import "AFNetworkReachabilityManager.h"
#import "AFHTTPSessionManager.h"
#import "SVProgressHUD.h"

//网址拼接
#define DespritionUrl @"http://xsg.fafu.edu.cn/"
//防止循环引用
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
//默认最大输入字数为  kMaxTextCount  300
#define kMaxTextCount 300
#define HJWIDTH [UIScreen mainScreen].bounds.size.width
#define HJHEIGHT [UIScreen mainScreen].bounds.size.height
@interface photoViewController ()<UITextViewDelegate, AJPhotoPickerProtocol,AJPhotoBrowserDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
{
    
    //备注文本View高度
    float noteTextHeight;
    float pickerViewHeight;
    float allViewHeight;
}
@property (nonatomic,assign)NSInteger itemsCount;
@property (nonatomic,strong)NSMutableArray *imageEntry;
@property (nonatomic,strong)NSMutableArray *imageData;
@property (nonatomic, strong) UILabel *textViewPlaceholderLabel;
@end

@implementation photoViewController
-(NSMutableArray *)imageEntry
{
    if (_imageEntry == nil) {
        _imageEntry = [[NSMutableArray alloc]init];
    }
    return _imageEntry;
}
-(NSMutableArray *)imageData
{
    if (_imageData == nil) {
        _imageData = [[NSMutableArray alloc]init];
    }
    return _imageData;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    [self creatSendPhoto];



}
#pragma mark---页面布局
- (void)creatSendPhoto
{
    _titleLB = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, HJWIDTH, 64)];
    _titleLB.text = @"分享新鲜事";
    _titleLB.font = [UIFont systemFontOfSize:16];
    _titleLB.textColor = [UIColor blackColor];
    _titleLB.textAlignment = NSTextAlignmentCenter;
    _titleLB.userInteractionEnabled = YES;
//    _titleLB.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_titleLB];
    
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    _cancelBtn.frame = CGRectMake(10, 20, 88, 44);
    [_cancelBtn addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
    [_titleLB addSubview:_cancelBtn];
    
    _textView=[[UITextView alloc]initWithFrame:CGRectMake(0, 64, CGRectGetWidth([[UIScreen mainScreen] bounds]), HJHEIGHT/4)];
    _textView.keyboardType = UIKeyboardTypeDefault;
    [_textView setTextColor:[UIColor blackColor]];
    [_textView.layer setBorderColor:[[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0] CGColor]];
    [_textView setFont:[UIFont systemFontOfSize:15.5]];
    [_textView.layer setBorderWidth:0.8f];
    _textView.delegate = self;
    [self.view addSubview:_textView];
    
    _textViewPlaceholderLabel = [[UILabel alloc]init];
    _textViewPlaceholderLabel.frame =CGRectMake(10, 8, 100, 20);
    _textViewPlaceholderLabel.font = [UIFont boldSystemFontOfSize:15.5];
    _textViewPlaceholderLabel.text = @"请输入文字...";
    _textViewPlaceholderLabel.enabled = NO;//lable必须设置为不可用
    _textViewPlaceholderLabel.backgroundColor = [UIColor clearColor];
    [self.textView addSubview:_textViewPlaceholderLabel];
    
    _textNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 64+HJHEIGHT/4, HJWIDTH, 30)];
    _textNumberLabel.textAlignment = NSTextAlignmentRight;
    _textNumberLabel.font = [UIFont boldSystemFontOfSize:12];
    _textNumberLabel.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
    _textNumberLabel.backgroundColor = [UIColor whiteColor];
    _textNumberLabel.text = [NSString stringWithFormat:@"0/%d",kMaxTextCount];
    [self.view addSubview:_textNumberLabel];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.pickerCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64+HJHEIGHT/4+30, HJWIDTH, 0*HJWIDTH/4) collectionViewLayout:layout];
    self.pickerCollectionView.delegate=self;
    self.pickerCollectionView.dataSource=self;
    self.pickerCollectionView.backgroundColor = [UIColor whiteColor];
    self.pickerCollectionView.scrollEnabled = NO;
    [self.pickerCollectionView registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:@"collectionViewCell"];
    [self.view addSubview:_pickerCollectionView];
    
    _sendBackgroudView = [[UIView alloc]initWithFrame:CGRectMake(0, 64+HJHEIGHT/4+30+0*HJWIDTH/4+8, HJWIDTH, 44+40+5)];
    [self.view addSubview:_sendBackgroudView];
    
    _cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _cameraBtn.frame = CGRectMake(10, 2, 40, 40);
    [_cameraBtn setImage:[UIImage imageNamed:@"plus@2x.png"] forState:UIControlStateNormal];
    [_cameraBtn setBackgroundColor:[UIColor grayColor]];
    [_cameraBtn addTarget:self action:@selector(cameraBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendBackgroudView addSubview:_cameraBtn];
    
    _explainLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 7, HJWIDTH, 30)];
    //    _explainLabel.text = @"添加图片不超过9张，文字备注不超过300字";
    _explainLabel.text = [NSString stringWithFormat:@"添加图片不超过9张，文字备注不超过%d字",kMaxTextCount];
    //发布按钮颜色
    _explainLabel.textColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:199.0/255.0 alpha:1.0];
    _explainLabel.textAlignment = NSTextAlignmentCenter;
    _explainLabel.font = [UIFont boldSystemFontOfSize:12];
    [self.sendBackgroudView addSubview:_explainLabel];
    
    _submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _submitBtn.frame = CGRectMake(0,44+5, HJWIDTH, 40);
    [_submitBtn setTitle:@"发布" forState:UIControlStateNormal];
    [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_submitBtn setBackgroundColor:[UIColor colorWithRed:243.0/255.0 green:60.0/255.0 blue:62.0/255.0 alpha:1.0]];
    //圆角
    //设置圆角
    [_submitBtn.layer setCornerRadius:4.0f];
    [_submitBtn.layer setMasksToBounds:YES];
    [_submitBtn.layer setShouldRasterize:YES];
    [_submitBtn.layer setRasterizationScale:[UIScreen mainScreen].scale];
    
    [_submitBtn addTarget:self action:@selector(submitBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendBackgroudView addSubview:_submitBtn];
   
}
//取消按钮方法
- (void)cancelClick:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
//发布按钮方法
- (void)submitBtnClicked:(UIButton *)sender
{
    //检查输入
    sender.enabled = NO;
    if (![self checkInput]) {
        return;
    }
    //输入正确将数据上传服务器->
    [self submitToServer];
//    [self dismissViewControllerAnimated:YES completion:nil];
}
//相机按钮方法
- (void)cameraBtnClicked:(UIButton *)sender
{
     _itemsCount = self.imageEntry.count;
    [self aJPhotoPicker];
}
//重新计算高度
- (void)reloadPickerCollectionViewHieght
{
    if (_imageEntry.count >0 && _imageEntry.count <= 4) {
        
        _sendBackgroudView.frame = CGRectMake(0, 64+HJHEIGHT/4+30+HJWIDTH/4+8, HJWIDTH, 44+40+5);
        
        self.pickerCollectionView.frame = CGRectMake(0, 64+HJHEIGHT/4+30, HJWIDTH, HJWIDTH/4);
    }else if (_imageEntry.count >4 && _imageEntry.count <= 8){
        _sendBackgroudView.frame = CGRectMake(0, 64+HJHEIGHT/4+30+2*HJWIDTH/4+8, HJWIDTH, 44+40+5);
        
        self.pickerCollectionView.frame = CGRectMake(0, 64+HJHEIGHT/4+30, HJWIDTH, 2*HJWIDTH/4);
    }else if (_imageEntry.count>8 &&_imageEntry.count<=9){
        _sendBackgroudView.frame = CGRectMake(0, 64+HJHEIGHT/4+30+3*HJWIDTH/4+8, HJWIDTH, 44+40+5);
       
        self.pickerCollectionView.frame = CGRectMake(0, 64+HJHEIGHT/4+30, HJWIDTH, 3*HJWIDTH/4);
    }else{
        _sendBackgroudView.frame = CGRectMake(0, 64+HJHEIGHT/4+30+0*HJWIDTH/4+8, HJWIDTH, 44+40+5);
        
        self.pickerCollectionView.frame = CGRectMake(0, 64+HJHEIGHT/4+30, HJWIDTH, 0*HJWIDTH/4);
    }
}
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.imageEntry.count==0) {
        return 0;
    }
    return self.imageEntry.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Register nib file for the cell
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionViewCell" forIndexPath:indexPath];
    // Set up the reuse identifier
    if (_imageEntry.count != 0) {
        cell.profilePhoto.image = _imageEntry[indexPath.row];
    }

    return cell;
}
#pragma mark <UICollectionViewDelegate>
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(([UIScreen mainScreen].bounds.size.width-64) /4 ,([UIScreen mainScreen].bounds.size.width-64) /4);
}

//定义每个UICollectionView 的 margin
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 8, 20, 8);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self showBigAtIndex:indexPath.row];
}
#pragma mark--textView
#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    _textNumberLabel.text = [NSString stringWithFormat:@"%lu/%d    ",(unsigned long)_textView.text.length,kMaxTextCount];
    if (_textView.text.length > kMaxTextCount) {
        _textNumberLabel.textColor = [UIColor redColor];
    }else{
        _textNumberLabel.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
    }
    if ([text isEqualToString:@"\n"]) {
        NSLog(@"回车");
        return NO;
    }
//    [self textChanged];
    return YES;
}

//文本框每次输入文字都会调用  -> 更改文字个数提示框
- (void)textViewDidChangeSelection:(UITextView *)textView{
    
    NSLog(@"当前输入框文字个数:%ld",_textView.text.length);
    //
    _textNumberLabel.text = [NSString stringWithFormat:@"%lu/%d    ",(unsigned long)_textView.text.length,kMaxTextCount];
    if (_textView.text.length > kMaxTextCount) {
        _textNumberLabel.textColor = [UIColor redColor];
    }
    else{
        _textNumberLabel.textColor = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
    }
        self.textViewPlaceholderLabel.hidden = textView.text.length > 0;
//    [self textChanged];
}

/**
 *  文本高度自适应
 */
//-(void)textChanged{
//    
//    CGRect orgRect = self.textView.frame;//获取原始UITextView的frame
//    
//    //获取尺寸
//    CGSize size = [self.textView sizeThatFits:CGSizeMake(self.textView.frame.size.width, MAXFLOAT)];
//    
//    orgRect.size.height=size.height+10;//获取自适应文本内容高度
//    
//    //如果文本框没字了恢复初始尺寸
//    if (orgRect.size.height > 100) {
//        noteTextHeight = orgRect.size.height;
//    }else{
//        noteTextHeight = 100;
//    }
//}

/**
 *  取消输入
 */
- (void)viewTapped{
    [self.view endEditing:YES];
}
- (void)aJPhotoPicker
{
    AJPhotoPickerViewController *picker = [[AJPhotoPickerViewController alloc] init];
    picker.maximumNumberOfSelection = 9-_itemsCount;
    picker.multipleSelection = YES;
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.showEmptyGroups = YES;
    picker.delegate=self;
    picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return YES;
    }];
    [self presentViewController:picker animated:YES completion:nil];
}
#pragma mark - AJPhotoPickerProtocol

- (void)photoPickerDidCancel:(AJPhotoPickerViewController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoPicker:(AJPhotoPickerViewController *)picker didSelectAssets:(NSArray *)assets {
    NSArray *photos = [NSArray arrayWithArray:assets];
    for (ALAsset *asset in photos) {
        UIImage *tempImg = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
                [self.imageEntry addObject:tempImg];
    }
    [self.pickerCollectionView reloadData];
    [self reloadPickerCollectionViewHieght];
    [picker dismissViewControllerAnimated:NO completion:nil];
}

- (void)photoPicker:(AJPhotoPickerViewController *)picker didSelectAsset:(ALAsset *)asset {
    NSLog(@"%s",__func__);
}

- (void)photoPicker:(AJPhotoPickerViewController *)picker didDeselectAsset:(ALAsset *)asset {
    NSLog(@"%s",__func__);
}

//超过最大选择项时
- (void)photoPickerDidMaximum:(AJPhotoPickerViewController *)picker {
    NSLog(@"%s",__func__);
    [[[UIAlertView alloc] initWithTitle:@"最多只能添加9张图片" message:nil delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
}

//低于最低选择项时
- (void)photoPickerDidMinimum:(AJPhotoPickerViewController *)picker {
    NSLog(@"%s",__func__);
}

- (void)photoPickerTapCameraAction:(AJPhotoPickerViewController *)picker {
    [self checkCameraAvailability:^(BOOL auth) {
        if (!auth) {
            NSLog(@"没有访问相机权限");
            return;
        }
        
        [picker dismissViewControllerAnimated:NO completion:nil];
        UIImagePickerController *cameraUI = [UIImagePickerController new];
        cameraUI.allowsEditing = NO;
        cameraUI.delegate = self;
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        cameraUI.cameraFlashMode=UIImagePickerControllerCameraFlashModeAuto;
        
        [self presentViewController: cameraUI animated: YES completion:nil];
    }];
}
#pragma mark - AJPhotoBrowserDelegate

- (void)photoBrowser:(AJPhotoBrowserViewController *)vc deleteWithIndex:(NSInteger)index {
    NSLog(@"%s",__func__);
    [self.imageEntry removeObjectAtIndex:index];
    [self.pickerCollectionView reloadData];
    [self reloadPickerCollectionViewHieght];
}

- (void)photoBrowser:(AJPhotoBrowserViewController *)vc didDonePhotos:(NSArray *)photos {
    NSLog(@"%s",__func__);
    [vc dismissViewControllerAnimated:YES completion:nil];
}

- (void)showBigAtIndex:(NSInteger)index {
        AJPhotoBrowserViewController *photoBrowserViewController = [[AJPhotoBrowserViewController alloc] initWithPhotos:self.imageEntry index:index];
        photoBrowserViewController.delegate = self;
        [self presentViewController:photoBrowserViewController animated:YES completion:nil];
}

#pragma mark - UIImagePickerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *) picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    if (!error) {
        NSLog(@"保存到相册成功");
    }else{
        NSLog(@"保存到相册出错%@", error);
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage;
    if (CFStringCompare((CFStringRef) mediaType,kUTTypeImage, 0)== kCFCompareEqualTo) {
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
    }
        [self.imageEntry addObject:originalImage];
    [self.pickerCollectionView reloadData];
    [self reloadPickerCollectionViewHieght];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)checkCameraAvailability:(void (^)(BOOL auth))block {
    BOOL status = NO;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        status = YES;
    } else if (authStatus == AVAuthorizationStatusDenied) {
        status = NO;
    } else if (authStatus == AVAuthorizationStatusRestricted) {
        status = NO;
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                if (block) {
                    block(granted);
                }
            } else {
                if (block) {
                    block(granted);
                }
            }
        }];
        return;
    }
    if (block) {
        block(status);
    }
}
#pragma mark -- 发布动态
#pragma maek - 检查输入
- (BOOL)checkInput{
    //文本框没字
    if (_textView.text.length == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"请输入文字" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionCacel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:actionCacel];
        [self presentViewController:alertController animated:YES completion:nil];
        
        return NO;
    }
    
    //文本框字数超过300
    if (_textView.text.length > kMaxTextCount) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"超出文字限制" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionCacel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:actionCacel];
        [self presentViewController:alertController animated:YES completion:nil];
        return NO;
    }
    return YES;
}

- (void)submitToServer
{
//    for (NSInteger i = 0; i < _imageEntry.count; i++) {
//        UIImage *dataImg = _imageEntry[i];
//        NSData *imgData = UIImagePNGRepresentation(dataImg);
//        [_imageData addObject:imgData];
//    }
    [SVProgressHUD show];
   NSString  *userID = @"bc61a517-945c-47d0-ab0f-1d327cb888cc";
    WS(weakSelf);
    
    NSString *url = [NSString stringWithFormat:@"%@ajax/PoiHandler.ashx",DespritionUrl];
    
    NSDictionary * parameters= @{@"action":@"addCom",@"memberid":userID,@"pid":@"",@"content":_textView.text};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //以下三项manager的属性根据需要进行配置
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/json",@"text/plain",@"text/JavaScript", nil];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //根据当前系统时间生成图片名称
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyyMMddHHMMSS"];
        
        NSString *dateString = [formatter stringFromDate:date];
        
        for (NSInteger i = 0; i < weakSelf.imageEntry.count; i++) {
                NSString *fileName = [NSString stringWithFormat:@"%@%ld.png",dateString,i];
            UIImage *image1 = _imageEntry[i];
             NSData *imageData = UIImageJPEGRepresentation(image1, 0.3);
            if (imageData.length/1024 > 128) {
                
                image1 = [weakSelf compressImageWith:image1];
                imageData = UIImageJPEGRepresentation(image1, 0.3);
            }
                [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"%ld",i] fileName:fileName  mimeType:@"image/jpg/png/jpeg"];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismiss];
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"恭喜" message:@"发表动态成功！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertVC addAction:action];
        [weakSelf presentViewController:alertVC animated:YES completion:nil];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            NSLog(@"%@",error);
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"发表动态失败" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertVC addAction:action];
            [weakSelf presentViewController:alertVC animated:YES completion:nil];
        }
         [SVProgressHUD dismiss];
    }];

    
}
-(UIImage *)compressImageWith:(UIImage *)image

{
    
    float imageWidth = image.size.width;
    
    float imageHeight = image.size.height;
    
    float width = 640;
    
    float height = image.size.height/(image.size.width/width);
    
    float widthScale = imageWidth /width;
    
    float heightScale = imageHeight /height;
    
    // 创建一个bitmap的context
    
    // 并把它设置成为当前正在使用的context
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    if (widthScale > heightScale) {
        
        [image drawInRect:CGRectMake(0, 0, imageWidth /heightScale , height)];
        
    }
    
    else {
        
        [image drawInRect:CGRectMake(0, 0, width , imageHeight /widthScale)];
        
    }
    
    // 从当前context中创建一个改变大小后的图片
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    NSLog(@"%s",__func__);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
