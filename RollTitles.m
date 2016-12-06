//
//  RollTitles.m
//  p
//
//  Created by wyzc03 on 16/11/10.
//  Copyright © 2016年 wyzc03. All rights reserved.
//

#import "RollTitles.h"

@interface RollTitles ()
//主label
@property (nonatomic,strong) UILabel * label;
//辅助标签 为了使动画连贯
@property (nonatomic,strong) UILabel * supportLabel;
@property (nonatomic,copy) NSString * text;
@property (nonatomic,strong) NSTimer * timer;
@property (nonatomic,assign) CGFloat tempWidth;

@end

@implementation RollTitles
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.tempWidth = 0;
        self.timeInterval = 3;
        //只显示自身视图大小的文字数量
        self.clipsToBounds = YES;
        self.startOrStop = YES;
        [self addTimer];
        [self addObserver];
    }
    return self;
}
#pragma mark 重写setter方法
- (void)setTimeInterval:(NSTimeInterval)timeInterval{
    if (_timeInterval != timeInterval) {
        if (timeInterval <= 1) {
            _timeInterval = 1;
        }else{
            _timeInterval = timeInterval;
        }
    }
}
- (void)setShowWords:(NSString *)showWords{
    if (_showWords != showWords) {
        _showWords = showWords;
        self.label.text = showWords;
    }
}
- (void)setStartOrStop:(BOOL)startOrStop{
    if (_startOrStop != startOrStop) {
        _startOrStop = startOrStop;
        if (startOrStop == YES) {
            [self demosAnimationContinue:_supportLabel];
            [self demosAnimationContinue:_label];
        }else{
            [self demosAnimationPause:_supportLabel];
            [self demosAnimationPause:_label];
        }
    }
}
#pragma mark 暂停 开启动画方法
//暂停动画
- (void)demosAnimationPause:(UILabel *)alable {
    // 将当前时间CACurrentMediaTime转换为layer上的时间, 即将parent time转换为local time
    CFTimeInterval pauseTime = [alable.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    
    // 设置layer的timeOffset, 在继续操作也会使用到
    alable.layer.timeOffset = pauseTime;
    
    // local time与parent time的比例(speed)为0, 意味着local time暂停了
    alable.layer.speed = 0;
}
//继续动画
- (void)demosAnimationContinue:(UILabel *)alabel {
    // 时间转换
    CFTimeInterval pauseTime = alabel.layer.timeOffset;
    // 计算暂停时间
    CFTimeInterval timeSincePause = CACurrentMediaTime() - pauseTime;
    // 取消
    alabel.layer.timeOffset = 0;
    // local time相对于parent time世界的beginTime
    alabel.layer.beginTime = timeSincePause;
    // 继续
    alabel.layer.speed = 1;
}

#pragma mark 重写getter方法
- (UILabel *)label{
    
    if (_label == nil) {
        _label = [[UILabel alloc]init];
        [self addSubview:_label];
        [self makeConstrains];

    }
    return _label;
}
- (UILabel *)supportLabel{
    if (_supportLabel == nil) {
        _supportLabel = [[UILabel alloc]init];
        [self addSubview:_supportLabel];
    }
    return _supportLabel;
}
#pragma mark 设置约束
- (void)makeConstrains{
    weakTypeof(self);
    //将自适应的宽度传给中介(暂时存储)宽度
    self.tempWidth = [tempself autoLayoutWidth:_label];
    //label
    [_label mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.equalTo(tempself);
        make.width.mas_equalTo(tempself.tempWidth);
    }];
    //supportLabel
    [self.supportLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(tempself);
        make.left.equalTo(_label.mas_right);
        make.width.equalTo(_label);
    }];
}
//自适应宽度
- (CGFloat)autoLayoutWidth:(UILabel *)aLabel{
    CGSize size = [aLabel.text sizeWithAttributes:@{NSFontAttributeName:aLabel.font}];
    return  ceil(size.width);
}
#pragma mark 解决supportLabel 的文本不能赋值的问题
- (void)addTimer{
    weakTypeof(self);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 repeats:YES block:^(NSTimer * _Nonnull timer) {
        tempself.text = _label.text;
    }];
}
- (void)addObserver{
    [self addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
}
//当这个方法被调用时,说明自身视图已经有了具体的frame,这时的frame就可以用了
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    weakTypeof(self);
    self.supportLabel.text = _text;
    [self.timer invalidate];
    self.timer = nil;
    [self makeConstrains];
    [self setNeedsUpdateConstraints];
    [UIView animateWithDuration:0 animations:^{
        [tempself layoutIfNeeded];
    }];
    [self start];
    //移除观察者
    [self removeObserver:self forKeyPath:@"text"];
}
#pragma mark 动画实现部分
//开启动画
- (void)start{
    //判断是否需要开启动画
    if (self.frame.size.width >= self.tempWidth) {
        //移除辅助标签
        [_supportLabel removeFromSuperview];
    }else{
        [self startAnimationWith:_label];
        [self startAnimationWith:_supportLabel];
    }
}

//滚动字幕
-(void)startAnimationWith:(UILabel *)alabel{
    //取消、停止所有的动画
    [alabel.layer removeAllAnimations];
    [UIView animateWithDuration:_timeInterval
     
                          delay:0
     
                        options:UIViewAnimationOptionRepeat //动画重复的主开关
     |UIViewAnimationOptionCurveLinear //动画的时间曲线，滚动字幕线性比较合理
     
                     animations:^{
                         alabel.transform = CGAffineTransformMakeTranslation(-self.tempWidth, 0);
                     }
                     completion:^(BOOL finished) {
                     }
     ];
}
@end

