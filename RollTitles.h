//
//  RollTitles.h
//  p
//
//  Created by wyzc03 on 16/11/10.
//  Copyright © 2016年 wyzc03. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
#define weakTypeof(obj)  __weak typeof(obj) temp##obj = obj
@interface RollTitles : UIView
//展示文字文字
@property (nonatomic,copy) NSString * showWords;
//动画滚动的周期 默认3秒 最小周期为1秒
@property (nonatomic,assign) NSTimeInterval timeInterval;
//控制动画是否开启默认是YES
@property (nonatomic,assign) BOOL startOrStop;
@end
