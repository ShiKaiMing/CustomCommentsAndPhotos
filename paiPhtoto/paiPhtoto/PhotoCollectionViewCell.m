//
//  PhotoCollectionViewCell.m
//  paiPhtoto
//
//  Created by fangd@silviscene.com on 2016/10/17.
//  Copyright © 2016年 fangd@silviscene.com. All rights reserved.
//

#import "PhotoCollectionViewCell.h"
@implementation PhotoCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.profilePhoto = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,([UIScreen mainScreen].bounds.size.width-64)/4 ,([UIScreen mainScreen].bounds.size.width-64) /4)];
        [self.contentView addSubview:self.profilePhoto];
        
    }
    return self;
}
@end
