//
//  MLMCircleView.m
//  MLMProgressView
//
//  Created by my on 16/8/4.
//  Copyright © 2016年 MS. All rights reserved.
//

#import "MLMCircleView.h"

@interface MLMCircleView () {
    CGFloat circleRadius;//bottom半径
    CGFloat progressRadius;//进度半径
    
    CGFloat _progress;//进度
    
    ///起点
    CGFloat _startAngle;
    ///终点
    CGFloat _endAngle;
}

@property (nonatomic, strong) UIImageView *dotImageView;//光标
@property (nonatomic, strong) CAShapeLayer *bottomLayer;//弧度背景
@property (nonatomic, strong) CAShapeLayer *progressLayer;//进度

@end


@implementation MLMCircleView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame startAngle:150 endAngle:390];
}


- (instancetype)initWithFrame:(CGRect)frame
                   startAngle:(CGFloat)start
                     endAngle:(CGFloat)end {
    if (self = [super initWithFrame:frame]) {
        
        _startAngle = start;
        _endAngle = end;
        //默认数据
        [self initData];

    }
    return self;
}

#pragma mark - 默认数据
- (void)initData {
    _progressWidth = 6.f;
    _bottomWidth = 6.f;
    _bgColor = [UIColor blueColor];
    _fillColor = [UIColor redColor];
    _capRound = YES;
//    _dotImage = [UIImage imageNamed:@"redDot"];
    _dotDiameter = 20.f;
    
    _edgespace = 0;
    _progressSpace = 0;
}

- (void)setBgColor:(UIColor *)bgColor{
    _bgColor = bgColor;
}
- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
}
#pragma mark - 计算光标的起始center
- (void)dotCenter {

    if (_dotImageView) {
        [_dotImageView removeFromSuperview];
    } else {
        _dotImageView = [[UIImageView alloc] init];
    }
    _dotImageView.frame = CGRectMake(0, 0, self.dotDiameter, self.dotDiameter);
    CGFloat centerX = self.width_s/2 + progressRadius*cosf(DEGREES_TO_RADIANS(_startAngle));
    CGFloat centerY = self.width_s/2 + progressRadius*sinf(DEGREES_TO_RADIANS(_startAngle));
    _dotImageView.center = CGPointMake(centerX, centerY);
    _dotImageView.layer.cornerRadius = self.dotDiameter/2;
    [_dotImageView setImage:self.dotImage];
    [self addSubview:_dotImageView];
}


#pragma mark - draw
- (void)drawProgress {
    //
    CGFloat baseRadius = self.width_s/2 - _edgespace;
    
    //确保边缘距离设置正确
    if (_progressSpace == 0) {
        circleRadius = progressRadius = baseRadius - MAX(_progressWidth, _bottomWidth)/2;
    } else if (_progressSpace < 0) {
        circleRadius = baseRadius + _progressSpace - _progressWidth/2;
        progressRadius = baseRadius - _progressWidth/2;
    } else {
        circleRadius = baseRadius - _bottomWidth/2;
        progressRadius = baseRadius - _bottomWidth/2 - _progressSpace;
    }
    
    //光标位置
    [self drowLayer];
    [self dotCenter];
}

#pragma mark - layer
- (void)drowLayer {
    [self drowBottom];
    [self drowProgress];
}



- (void)drowBottom {
    if (self.bottomLayer) {
        [self.bottomLayer removeFromSuperlayer];
    }
    //背景
    UIBezierPath *bottomPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.width_s/2, self.height_s/2)
                                                                radius:circleRadius
                                                            startAngle:DEGREES_TO_RADIANS(_startAngle)
                                                              endAngle:DEGREES_TO_RADIANS(_endAngle)
                                                             clockwise:YES];
    self.bottomLayer = [CAShapeLayer layer];
    self.bottomLayer.frame = CGRectMake(0, 0, self.width_s, self.height_s);
    self.bottomLayer.fillColor = [UIColor clearColor].CGColor;
    self.bottomLayer.strokeColor = self.bgColor.CGColor;
    if (_capRound) {
        self.bottomLayer.lineCap = kCALineCapRound;
    }
    self.bottomLayer.lineWidth = self.bottomWidth;
    self.bottomLayer.path = [bottomPath CGPath];
    [self.layer addSublayer:self.bottomLayer];
}

- (void)drowProgress {
    if (self.progressLayer) {
        [self.progressLayer removeFromSuperlayer];
    }
    UIBezierPath *progressPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.width_s/2, self.height_s/2)
                                                              radius:progressRadius
                                                          startAngle:DEGREES_TO_RADIANS(_startAngle)
                                                            endAngle:DEGREES_TO_RADIANS(_endAngle)
                                                           clockwise:YES];
    self.progressLayer = [CAShapeLayer layer];
    self.progressLayer.frame = CGRectMake(0, 0, self.width_s, self.height_s);
    self.progressLayer.fillColor =  [UIColor clearColor].CGColor;
    self.progressLayer.strokeColor  = self.fillColor.CGColor;
    if (_capRound) {
        self.progressLayer.lineCap = kCALineCapRound;
    }
    self.progressLayer.lineWidth = self.progressWidth;
    self.progressLayer.path = [progressPath CGPath];
    self.progressLayer.strokeEnd = 0;
    [self.layer addSublayer:self.progressLayer];
}

#pragma mark - 动画
- (void)createAnimation {
    //设置动画
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;//使得动画均匀进行
    //动画结束不被移除
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    
    pathAnimation.duration = kAnimationTime;
    pathAnimation.repeatCount = 1;
    
    //设置动画路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, self.width_s/2, self.height_s/2, progressRadius, DEGREES_TO_RADIANS(_startAngle), (DEGREES_TO_RADIANS(_endAngle) - DEGREES_TO_RADIANS(_startAngle))*_progress + DEGREES_TO_RADIANS(_startAngle), 0);
    pathAnimation.path=path;
    CGPathRelease(path);
    [self.dotImageView.layer addAnimation:pathAnimation forKey:@"moveMarker"];
}

#pragma mark - 弧度
- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self setProgressAnimation:YES];
}

- (void)setProgressAnimation:(BOOL)animation {

    [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(circleAnimation) userInfo:nil repeats:NO];
    
    [self createAnimation];
}


- (void)circleAnimation {
    //开启事务
    [CATransaction begin];
    //禁用隐式动画
    [CATransaction setDisableActions:NO];
    //线性
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [CATransaction setAnimationDuration:0];
    self.progressLayer.strokeEnd = 0;
    [CATransaction commit];
    
    //开启事务
    [CATransaction begin];
    //禁用隐式动画
    [CATransaction setDisableActions:NO];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [CATransaction setAnimationDuration:kAnimationTime];
    self.progressLayer.strokeEnd = _progress;
    [CATransaction commit];
    
    self.progressLayer.strokeStart = 0;
}

- (void)dotHidden:(BOOL)hidden {
    _dotImageView.hidden = hidden;
}

- (CGFloat)freeWidth {
    //最小半径
    CGFloat cirle = circleRadius - _bottomWidth/2;
    CGFloat progress = progressRadius - _progressWidth/2;
    
    return MIN(cirle, progress)*2;

}

- (void)bottomNearProgress:(BOOL)outOrIn {
    CGFloat nearSpace = (self.bottomWidth+self.progressWidth)/2;
    if (outOrIn) {
        self.progressSpace = -nearSpace;
    } else {
        self.progressSpace = nearSpace;
    }
}

@end
