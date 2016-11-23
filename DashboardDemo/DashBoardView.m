//
//  DashBoardView.m
//  AliPayCredit
//
//  Created by 施澍 on 16/10/21.
//  Copyright © 2016年 EJU. All rights reserved.
//

#import "DashBoardView.h"
#import "UIView+Frame.h"
#import <POP.h>

#define kAngle M_PI*7/6
#define kMarginToScreen 70
#define kMarginBetweenCurves 25
#define kPerAnimationDuration 1.0

@implementation DashBoardView
{
    CGFloat _startAngle;
    CGFloat _endAngle;
    CGPoint _curveCenter;
    CGFloat _curveradius;
    
    CGFloat _duration;
    NSArray *_expArray;
    NSArray *_colorsArray;
    
    CGFloat _strokeEndAnimateTo;
    
    CAShapeLayer *_progressLayer;
    CAShapeLayer *_indicatorLayer;
    
    UILabel *_pointLabel;
    UILabel *_levelLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupMemberVariables];
        [self configProgressLayer];
        [self configExpLabel];
        [self configPointLabel];
        [self configLevelLabel];
        [self configIndicatorLayer];
    }
    return self;
}

- (void)setCurrentExp:(NSInteger)currentExp {
    _currentExp = currentExp;
    
    for (NSInteger i = 1; i<_expArray.count; i++) {
        NSInteger perExp = [_expArray[i] integerValue];
        NSInteger lastPerExp = [_expArray[i-1] integerValue];
        
        if (_currentExp < perExp) {
            _duration += 1.0*(_currentExp-lastPerExp)/(perExp-lastPerExp)*kPerAnimationDuration;
            break;
        } else {
            _duration += kPerAnimationDuration;
        }
    }
    _strokeEndAnimateTo = _duration/(kPerAnimationDuration*(_expArray.count-1));
}

- (void)setupMemberVariables {
    _curveradius = (self.width - 2*kMarginToScreen)/2;
    _curveCenter = CGPointMake(self.centerX, self.centerY-_curveradius/2);
    _startAngle = M_PI + M_PI_2 - kAngle/2;
    _endAngle = _startAngle + kAngle;
    _expArray = @[@"0", @"1000", @"3000", @"10000", @"50000"];
    _colorsArray = @[];
}

- (void)configIndicatorLayer {
    
    CGFloat x = kMarginToScreen + kMarginBetweenCurves + 25;
    CGFloat y = _curveCenter.y - _curveradius;
    CGFloat width = (_curveradius - 25 - kMarginBetweenCurves)*2;
    CGFloat height = (_curveradius - 25 - kMarginBetweenCurves)*2;
    
    UIBezierPath *pivotPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2, height) radius:10.0 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    CAShapeLayer *pivotLayer = [CAShapeLayer layer];
    pivotLayer.path = pivotPath.CGPath;
    pivotLayer.fillColor = [UIColor blackColor].CGColor;
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, NULL, 0, height);
    CGPathAddLineToPoint(pathRef, NULL, width/2, height);
    _indicatorLayer = [CAShapeLayer layer];
    _indicatorLayer.path = pathRef;
    _indicatorLayer.anchorPoint = CGPointMake(0.5, 1.0);
    _indicatorLayer.frame = CGRectMake(x, y, width, height);
    _indicatorLayer.lineWidth = 3.0f;
    _indicatorLayer.strokeColor = [UIColor redColor].CGColor;
//    _indicatorLayer.borderWidth = 1;
    [_indicatorLayer addSublayer:pivotLayer];
    [self.layer addSublayer:_indicatorLayer];
    CGPathRelease(pathRef);
}

- (void)configProgressLayer {
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:_curveCenter radius:_curveradius-kMarginBetweenCurves startAngle:_startAngle endAngle:_endAngle clockwise:YES];
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.path = path.CGPath;
    _progressLayer.lineCap = kCALineCapRound;
    _progressLayer.lineWidth = 10.f;
    _progressLayer.fillColor = [UIColor clearColor].CGColor;
    _progressLayer.strokeColor = [UIColor redColor].CGColor;
    _progressLayer.strokeEnd = 0;
    [self.layer addSublayer:_progressLayer];
}

- (void)configExpLabel {
    UILabel *expLabel = [[UILabel alloc]initWithFrame:CGRectMake(_curveCenter.x-50, _curveCenter.y-70, 100, 15)];
    expLabel.textColor = [UIColor redColor];
    expLabel.font = [UIFont systemFontOfSize:13];
    expLabel.textAlignment = 1;
    expLabel.text = @"我的经验值";
    [self addSubview:expLabel];
}

- (void)configPointLabel {
    _pointLabel = [[UILabel alloc]initWithFrame:CGRectMake(_curveCenter.x-_curveradius, _curveCenter.y-45, _curveradius*2, 50)];
    _pointLabel.textColor = [UIColor redColor];
    _pointLabel.font = [UIFont boldSystemFontOfSize:50];
    _pointLabel.textAlignment = 1;
    _pointLabel.text = @"0";
    [self addSubview:_pointLabel];
}

- (void)configLevelLabel {
    _levelLabel = [[UILabel alloc]initWithFrame:CGRectMake(_curveCenter.x-75, _curveCenter.y, 150, 50)];
    _levelLabel.textColor = [UIColor redColor];
    _levelLabel.font = [UIFont boldSystemFontOfSize:20];
    _levelLabel.textAlignment = 1;
    _levelLabel.text = @"普通顾问";
    [self addSubview:_levelLabel];
}

- (void)drawRect:(CGRect)rect {
    [self drawOutCurvePath];
    [self drawDial];
    [self beginIndicatorAnimation];
    [self beginProgressLayerAnimation];
    [self beginWordsAnimation];
}

// 绘制外部轮廓线
- (void)drawOutCurvePath {
    
    //刻度盘
    UIBezierPath *curvePath = [UIBezierPath bezierPathWithArcCenter:_curveCenter radius:_curveradius startAngle:_startAngle endAngle:_endAngle clockwise:YES];
    curvePath.lineWidth = 3.0;
    [[UIColor colorWithWhite:0.93 alpha:1.0] setStroke];
    [curvePath stroke];
    
    CGFloat perAngle = kAngle/4;

    for (NSInteger i = -1; i<4; i++) {
        CGFloat startAngle = _startAngle+i*perAngle;
        CGFloat endAngle = startAngle + perAngle;
        
        UIBezierPath *curvePath = [UIBezierPath bezierPathWithArcCenter:_curveCenter radius:_curveradius startAngle:startAngle endAngle:endAngle clockwise:YES];
        
        //刻度
        CGPoint startPoint = CGPointMake(curvePath.currentPoint.x+10*cos(endAngle), curvePath.currentPoint.y+10*sin(endAngle));
        [[UIColor colorWithWhite:0.8 alpha:1.0]setStroke];
        CGPoint toPoint = CGPointMake(curvePath.currentPoint.x-10*cos(endAngle), curvePath.currentPoint.y-10*sin(endAngle));
        UIBezierPath *path = [UIBezierPath bezierPath];
        path.lineWidth = 3.0;
        [path moveToPoint:startPoint];
        [path addLineToPoint:toPoint];
        [path stroke];
        
        //数字
        CATextLayer *txtLayer = [CATextLayer layer];
        //解决文字不清晰
        txtLayer.contentsScale = [UIScreen mainScreen].scale;
        
//        txtLayer.shouldRasterize = YES;
//        txtLayer.allowsEdgeAntialiasing = YES;
        CGFloat width = [_expArray[i+1] boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 13) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil].size.width;
        txtLayer.frame = CGRectMake(0, 0, width, 13);
        CGPoint position = CGPointMake(curvePath.currentPoint.x+20*cos(endAngle), curvePath.currentPoint.y+20*sin(endAngle));
        txtLayer.position = position;
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:_expArray[i+1]];
        [attStr addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} range:NSMakeRange(0, [_expArray[i+1] length])];
        txtLayer.string = attStr;
        txtLayer.transform = CATransform3DMakeRotation(endAngle-M_PI*3/2, 0, 0, 1);
        [self.layer addSublayer:txtLayer];
    }
}

//内圈圆
- (void)drawDial {
    CGFloat radius = _curveradius-kMarginBetweenCurves;
    
    UIBezierPath *curvePath = [UIBezierPath bezierPathWithArcCenter:_curveCenter radius:radius startAngle:_startAngle endAngle:_endAngle clockwise:YES];
    curvePath.lineWidth = 10.f;
    [[UIColor colorWithWhite:0.9 alpha:1.0]setStroke];
    [curvePath stroke];
}

//开始动画
- (void)beginIndicatorAnimation {
    POPBasicAnimation *rotateAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
    rotateAnim.toValue = @M_PI;
    rotateAnim.duration = _duration;
    rotateAnim.beginTime = CACurrentMediaTime()+1.0;
    rotateAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [_indicatorLayer pop_addAnimation:rotateAnim forKey:@"rotation"];
    
    [self addColorAnimationTo:_indicatorLayer propertyName:kPOPShapeLayerStrokeColor];
}

- (void)beginProgressLayerAnimation {
    
    POPBasicAnimation *strokeAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPShapeLayerStrokeEnd];
    strokeAnim.fromValue = @0;
    strokeAnim.toValue = @(_strokeEndAnimateTo);
    strokeAnim.duration = _duration;
    strokeAnim.beginTime = CACurrentMediaTime() + 1.0;
    strokeAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [_progressLayer pop_addAnimation:strokeAnim forKey:@"strokeAnim"];
    
    [self addColorAnimationTo:_progressLayer propertyName:kPOPShapeLayerStrokeColor];
}

- (void)beginWordsAnimation {
//    POPBasicAnimation *anim = [POPBasicAnimation easeInEaseOutAnimation];
    POPBasicAnimation *anim = [POPBasicAnimation linearAnimation];
    anim.property = [POPAnimatableProperty propertyWithName:@"wordsAnimation" initializer:^(POPMutableAnimatableProperty *prop) {
        [prop setReadBlock:^(UILabel *label, CGFloat *values) {
            values[0] = label.text.floatValue;
        }];
        [prop setWriteBlock:^(UILabel *label, const CGFloat *values) {
            label.text = [NSString stringWithFormat:@"%.0f", values[0]];
            if (values[0] <= [_expArray[0]integerValue]) {
                _levelLabel.text = @"普通顾问";
            } else if(values[0] <= [_expArray[1]integerValue]) {
                _levelLabel.text = @"中级顾问";
            } else if(values[0] <= [_expArray[2]integerValue]){
                _levelLabel.text = @"高级顾问";
            } else {
                _levelLabel.text = @"专家";
            }
        }];
    }];
    anim.fromValue = @0;
    anim.toValue = @(_currentExp);
    anim.duration = _duration;
    anim.beginTime = CACurrentMediaTime() + 1.0;
    [_pointLabel pop_addAnimation:anim forKey:@"anim"];
    
    [self addColorAnimationTo:_pointLabel propertyName:kPOPLabelTextColor];
    [self addColorAnimationTo:_levelLabel propertyName:kPOPLabelTextColor];
    
    
    //test
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(100, 400, 100, 30);
//    btn.layer.borderWidth = 3;
//    btn.layer.borderColor = [UIColor redColor].CGColor;
//    [btn setTitle:@"呵呵" forState:UIControlStateNormal];
//    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//    [self addSubview:btn];
//    
//    [self addColorAnimationTo:btn.layer propertyName:kPOPLayerBorderColor];
//    [self addColorAnimationTo:btn.titleLabel propertyName:kPOPLabelTextColor];
}

- (void)addColorAnimationTo:(id)obj propertyName:(NSString *)name{
    
//    CGFloat perDuration = _duration/_expArray.count;
    
    if(_currentExp > [_expArray[1] integerValue]) {
        POPBasicAnimation *colorAnim1 = [POPBasicAnimation animationWithPropertyNamed:name];
        colorAnim1.toValue = [NSValue valueWithCGRect:CGRectMake(0, 1, 0, 1.0)];
        colorAnim1.duration = kPerAnimationDuration;
        colorAnim1.beginTime = CACurrentMediaTime() + 1.0 + kPerAnimationDuration;
        colorAnim1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [obj pop_addAnimation:colorAnim1 forKey:@"ColorAnim1"];
    }
    if(_currentExp > [_expArray[2] integerValue]){
        POPBasicAnimation *colorAnim2 = [POPBasicAnimation animationWithPropertyNamed:name];
        colorAnim2.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 1, 1.0)];
        colorAnim2.duration = kPerAnimationDuration;
        colorAnim2.beginTime = CACurrentMediaTime() + 1.0 + 2*kPerAnimationDuration;
        colorAnim2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [obj pop_addAnimation:colorAnim2 forKey:@"ColorAnim2"];
    }
    if(_currentExp>[_expArray[3] integerValue]) {
        POPBasicAnimation *colorAnim3 = [POPBasicAnimation animationWithPropertyNamed:name];
        colorAnim3.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0.5, 0.5, 1.0)];
        colorAnim3.duration = kPerAnimationDuration;
        colorAnim3.beginTime = CACurrentMediaTime() + 1.0 + 3*kPerAnimationDuration;
        colorAnim3.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [obj pop_addAnimation:colorAnim3 forKey:@"ColorAnim3"];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self beginProgressLayerAnimation];
    [self beginWordsAnimation];
}


@end
