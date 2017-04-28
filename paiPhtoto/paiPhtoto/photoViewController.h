//
//  photoViewController.h
//  paiPhtoto
//
//  Created by fangd@silviscene.com on 2016/10/16.
//  Copyright © 2016年 fangd@silviscene.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface photoViewController : UIViewController
/**
 *  取消按钮+监听方法
 */
@property (nonatomic,strong)UIButton *cancelBtn;
- (void)cancelClick:(UIButton *)sender;
/**
 *  title文字  默认分享新鲜事
 */
@property (nonatomic,strong) UILabel *titleLB;


////背景
@property(nonatomic,strong) UIView *sendBackgroudView;

@property(nonatomic,strong)UIButton *cameraBtn;

//备注
@property(nonatomic,strong) UITextView *textView;

//文字个数提示label
@property(nonatomic,strong) UILabel *textNumberLabel;

//文字说明
@property(nonatomic,strong) UILabel *explainLabel;

//发布按钮
@property(nonatomic,strong) UIButton *submitBtn;

@property (nonatomic, strong) UICollectionView *pickerCollectionView;

@end
