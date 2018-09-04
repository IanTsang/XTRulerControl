//
//  XTArcRulerControl.m
//  XTRulerControl
//
//  Created by ZengYuYing on 2018/8/31.
//  Copyright © 2018 ZengYuYing. All rights reserved.
//

#import "XTArcRulerControl.h"

@implementation XTRulerScale

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.color = [UIColor colorWithWhite:1 alpha:0.5];
        self.width = 3;
        self.height = 8;
        self.lineCap = kCGLineCapRound;
        self.topSpacing = 16;
    }
    return self;
}

@end

@implementation XTRuler
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.minValue = 0;
        self.maxValue = [[NSDate date] timeIntervalSince1970];
        self.scaleValue = 600;
        self.scaleAngle = 2.5 * (M_PI/180);
        self.minorScale = [[XTRulerScale alloc] init];
        self.markScale = [[XTRulerScale alloc] init];
        self.unmarkScale = [[XTRulerScale alloc] init];
        self.markFontSize = 14;
        self.markFontColor = [UIColor colorWithWhite:1 alpha:0.5];
        self.markTopSpacing = 40;
        self.minorScaleCount = 6;
        self.markMajorScaleCount = 1;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"hh24:mm";
        self.markRule = ^NSString *(CGFloat value) {
            return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:value]];
        };
    }
    return self;
}

@end

@interface XTArcRulerControl ()
@property (nonatomic, assign) CGPoint arcCenter;        /**< 圆弧中心点 */
@property (nonatomic, assign) CGFloat arcLineWidth;     /**< 圆弧stroke时线的宽度 */
@property (nonatomic, copy) NSArray<XTRuler *> *rulers;
@property (nonatomic, copy) NSArray<NSNumber *> *zoomScales;
@property (nonatomic, strong) XTRuler *currentRuler;    /**< 当前刻度尺 */

@end

@implementation XTArcRulerControl

@synthesize directionAngle = _directionAngle;

- (instancetype)initWithRuler:(XTRuler *)ruler {
    if (!ruler) {
        ruler = [[XTRuler alloc] init];
    }
    return [self initWithRulers:@[ruler] zoomScales:@[@1]];
}
- (instancetype)initWithRulers:(NSArray<XTRuler *> *)rulers zoomScales:(NSArray<NSNumber *> *)zoomScales {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.currentRuler = rulers.firstObject;
        [self addGestures];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    
    /**
     画圆
     */
    UIBezierPath *arcPath = [UIBezierPath bezierPathWithArcCenter:self.arcCenter radius:self.radius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    arcPath.lineWidth = self.arcLineWidth;
    [[UIColor blackColor] set];
    [arcPath stroke];
    
    [self.currentRuler.backgroundColor set];
    [arcPath fill];
    
    
    [self drawIndicator];
    
}

- (void)drawIndicator {
    [self.indicatorColor set];
    //上三角
    CGFloat angle = 7.5/800;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.arcCenter radius:self.radius startAngle:[self correctAngle:-angle] endAngle:[self correctAngle:angle] clockwise:YES];
    [path addLineToPoint:[self arcPointWithCenter:self.arcCenter raidus:self.radius-12 angle:[self correctAngle:0]]];
    
    //下三角
    [path moveToPoint:[self arcPointWithCenter:self.arcCenter raidus:self.radius-54 angle:[self correctAngle:0]]];
    CGFloat pointToCenter = (7.5/96)*(self.radius-54);
    [path addLineToPoint:[self arcPointWithCenter:self.arcCenter raidus:pointToCenter angle:[self correctAngle:-M_PI_2]]];
    [path addLineToPoint:[self arcPointWithCenter:self.arcCenter raidus:pointToCenter angle:[self correctAngle:M_PI_2]]];
    [path fill];
}


#pragma mark - 手势
- (void)addGestures {
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinch:)];
    [self addGestureRecognizer:pinch];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    [self addGestureRecognizer:pan];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
    [self addGestureRecognizer:swipe];
}

- (void)onPinch:(UIPinchGestureRecognizer *)gesture {
    NSLog(@"%s",__func__);
}

- (void)onTap:(UITapGestureRecognizer *)gesture {
    NSLog(@"%s",__func__);
}

- (void)onPan:(UIPanGestureRecognizer *)gesture {
    NSLog(@"%s",__func__);
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint speed = [gesture velocityInView:self];
        NSLog(@"velocityInView %@", @(speed));

    }
}

- (void)onSwipe:(UISwipeGestureRecognizer *)gesture {
    NSLog(@"%s",__func__);
}


#pragma mark - 坐标转换

/**
 根据设计角度和方向偏移角度返回实际作图角度
 设计编码以竖直向上作为0度，而实际画图向右是0度
 @param angle 设计编码角度
 @return 实际画图角度
 */
- (CGFloat)correctAngle:(CGFloat)angle {
    return angle + self.directionAngle - M_PI_2;
}

- (CGPoint)convertArcPoint:(CGPoint)point byAngle:(CGFloat)angle {
    CGFloat x = self.arcCenter.x + self.radius * cos(angle);
    CGFloat y = self.arcCenter.y + self.radius * sin(angle);
    return CGPointMake(x, y);
}

/**
 根据圆的中心、半径、偏移角度计算圆弧上点的坐标

 @param center 中心坐标
 @param radius 半径
 @param angle 角度，水平右为0，顺时针增加，一圈=2π
 @return 圆弧上点的坐标
 */
- (CGPoint)arcPointWithCenter:(CGPoint)center raidus:(CGFloat)radius angle:(CGFloat)angle {
    CGFloat x = center.x + radius * cos(angle);
    CGFloat y = center.y + radius * sin(angle);
    return CGPointMake(x, y);
}

- (CGPoint)arcPointWithCenter:(CGPoint)center raidus:(CGFloat)radius angle:(CGFloat)angle size:(CGSize)size {
    CGFloat x = center.x + size.width/2 * cos(angle);
    CGFloat y = center.y + size.height/2 * sin(angle);
    return CGPointMake(x, y);
}


/**
 根据角度获取椭圆上一点的坐标

 @param center 椭圆中心点
 @param size 椭圆外矩形size，正方形则为圆形
 @param angle 角度
 @return 圆弧上坐标
 */
- (CGPoint)getArcPointWithCenter:(CGPoint)center Size:(CGSize)size angle:(CGFloat)angle {

    CGFloat origin_x = center.x;
    CGFloat origin_y = center.y;
    CGFloat radius, radiusScaleX = 1, radiusScaleY = 1;
    
    if (size.width > size.height) {
        radius = size.height/2;
        radiusScaleX = size.width/size.height;
    } else {
        radius = size.width/2;
        radiusScaleY = size.height/size.width;
    }
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGAffineTransform t2 = CGAffineTransformConcat(CGAffineTransformConcat(
                                                                           CGAffineTransformMakeTranslation(-origin_x, -origin_y),
                                                                           CGAffineTransformMakeScale(radiusScaleX, radiusScaleY)),
                                                   CGAffineTransformMakeTranslation(origin_x, origin_y));
    
    CGPathMoveToPoint(curvedPath, NULL, origin_x, origin_y);
    CGPathAddArc(curvedPath, &t2, origin_x, origin_y, radius, 0, angle, 1);
    CGPoint point = CGPathGetCurrentPoint(curvedPath);
    CGPathRelease(curvedPath);
    return point;
}

#pragma mark - getter
- (CGFloat)radius {
    if (_radius <= 0) {
        _radius = self.frame.size.width;
    }
    return _radius;
}

- (CGFloat)directionAngle {
    if (_directionAngle < 0 || _directionAngle > M_PI * 2) {
        return M_PI * 1.5;
    }
    return _directionAngle;
}

- (XTRulerMarkDirection)markDirection {
    if ((_markDirection != XTRulerMarkDirectionUp) && (_markDirection != XTRulerMarkDirectionFollowScale)) {
        _markDirection = XTRulerMarkDirectionUp;
    }
    return _markDirection;
}

- (CGPoint)arcCenter {
    CGFloat radius = self.radius + self.arcLineWidth/2;
    CGPoint rotateCenter = CGPointMake(self.width/2, self.height/2);
    //不同角度对应圆弧的中心点的轨迹是一个椭圆
    CGPoint center = [self getArcPointWithCenter:rotateCenter Size:CGSizeMake(radius*2 - self.width, radius*2 - self.height) angle:self.directionAngle + M_PI_2];
    return center;
}

- (CGFloat)arcLineWidth {
    if (_arcLineWidth <= 0) {
        _arcLineWidth = 1;
    }
    return _arcLineWidth;
}

- (UIColor *)indicatorColor {
    if (!_indicatorColor) {
        _indicatorColor = [UIColor colorWithRed:255/255.0 green:127/255.0 blue:0/255.0 alpha:1];
    }
    return _indicatorColor;
}

#pragma mark - setter

- (void)setDirectionAngle:(CGFloat)directionAngle {
    _directionAngle = directionAngle;
    [self setNeedsDisplay];
}


@end
