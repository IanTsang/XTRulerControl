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
        self.markScale.height = 16;
        self.unmarkScale = [[XTRulerScale alloc] init];
        self.unmarkScale.height = 12;
        self.markFontSize = 14;
        self.markFontColor = [UIColor colorWithWhite:1 alpha:0.5];
        self.markTopSpacing = 40;
        self.markDirection = XTRulerMarkDirectionVertical;
        self.minorScaleCount = 6;
        self.markMajorScaleCount = 1;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"hh:mm";
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
//@property (nonatomic, copy) NSArray<XTRuler *> *rulers;
//@property (nonatomic, copy) NSArray<NSNumber *> *zoomScales;
@property (nonatomic, copy) NSDictionary<NSNumber*, XTRuler*> *mulRulers; /**< 不同缩放倍率对应的刻度尺 */
@property (nonatomic, strong) XTRuler *currentRuler;    /**< 当前刻度尺 */
@property (nonatomic, assign) CGFloat currentZoomScale; /**< 当前缩放倍率 */
@end

@implementation XTArcRulerControl

@synthesize directionAngle = _directionAngle;

- (instancetype)initWithRuler:(XTRuler *)ruler {
    if (!ruler) {
        ruler = [[XTRuler alloc] init];
    }
    return [self initWithMultipleRulers:@{@(1):ruler}];
}
//- (instancetype)initWithRulers:(NSArray<XTRuler *> *)rulers zoomScales:(NSArray<NSNumber *> *)zoomScales {
//    if (self = [super init]) {
//        self.backgroundColor = [UIColor clearColor];
//        self.currentRuler = rulers.firstObject;
//        self.currentZoomScale = 1;
//        self.enableZoom = YES;
//        [self addGestures];
//    }
//    return self;
//}

- (instancetype)initWithMultipleRulers:(NSDictionary<NSNumber*, XTRuler*> *)mulRulers {
    NSAssert([mulRulers.allKeys containsObject:@(1)], @"MultipleRulers必须包含key为@(1)的项");
    NSAssert([mulRulers[@(1)] isKindOfClass:[XTRuler class]], @"MultipleRulers的key=@(1)的值必须为XTRuler对象");
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.mulRulers = mulRulers;
        self.currentRuler = mulRulers[@(1)];
        self.currentZoomScale = 1;
        self.enableZoom = YES;
        [self addGestures];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    
    //画圆
    UIBezierPath *arcPath = [UIBezierPath bezierPathWithArcCenter:self.arcCenter radius:self.radius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    arcPath.lineWidth = self.arcLineWidth;
    [[UIColor clearColor] set];
    [arcPath stroke];
    
    [self.currentRuler.backgroundColor set];
    [arcPath fill];
    
    //画刻度
    [self drawRuler:self.currentRuler];
    
    //画指针
    [self drawIndicator];
}

- (void)drawRuler:(XTRuler *)ruler {
    
    /**
     从当前值分别向左右两边180°的范围进行画图
     */
    
    // 1.根据当前值计算开始角度
    
    // >每个刻度的角度
//    CGFloat zoomScaleAngle = ruler.scaleAngle * self.currentZoomScale; //缩放后的每个刻度角度
    CGFloat zoomScaleAngle = [self zoomScaleAngle]; //缩放后的每个刻度角度

    // >计算当前值距离左右刻度间的值差
    CGFloat leftSpacingValue = fabs(self.selectedValue);
    while (leftSpacingValue >= ruler.scaleValue) {
        leftSpacingValue -= ruler.scaleValue;
    }
    if (self.selectedValue < 0) {
        leftSpacingValue = ruler.scaleValue - leftSpacingValue;
    }
    CGFloat rightSpacingValue = ruler.scaleValue - leftSpacingValue;

    // >算出左右开始画的角度
    CGFloat rightStartAngle = zoomScaleAngle * (rightSpacingValue / ruler.scaleValue);
    CGFloat leftStartAngle = -(zoomScaleAngle * (leftSpacingValue/ ruler.scaleValue));

    // 2.画刻度
    // >画右边180°范围的刻度
    CGFloat drawAngle = rightStartAngle;
    CGFloat drawValue = ceil((self.selectedValue-ruler.minValue)/ruler.scaleValue) * ruler.scaleValue + ruler.minValue;
    UIBezierPath *path = [UIBezierPath bezierPath];
    while (drawAngle < M_PI) {
        XTRulerScale *scale = [self scaleWithRuler:ruler Value:drawValue];
        CGPoint startPoint = [self arcPointWithCenter:self.arcCenter raidus:self.radius - scale.topSpacing angle:[self correctAngle:drawAngle]];
        CGPoint endPoint = [self arcPointWithCenter:self.arcCenter raidus:self.radius - scale.topSpacing - scale.height angle:[self correctAngle:drawAngle]];

        path.lineWidth = scale.width;
        path.lineCapStyle = scale.lineCap;
        [path moveToPoint:startPoint];
        [path addLineToPoint:endPoint];
        [scale.color setStroke];
        
        if (scale == ruler.markScale) {
            [self drawMarkWithRuler:ruler angle:drawAngle value:drawValue];
        }
        
        drawAngle += zoomScaleAngle;
        drawValue += ruler.scaleValue;
    }
    
    // >画左边180°范围的刻度
    drawAngle = leftStartAngle;
    drawValue = floor((self.selectedValue-ruler.minValue)/ruler.scaleValue) * ruler.scaleValue + ruler.minValue;
    while (drawAngle > -M_PI) {
        XTRulerScale *scale = [self scaleWithRuler:ruler Value:drawValue];
        CGPoint startPoint = [self arcPointWithCenter:self.arcCenter raidus:self.radius - scale.topSpacing angle:[self correctAngle:drawAngle]];
        CGPoint endPoint = [self arcPointWithCenter:self.arcCenter raidus:self.radius - scale.topSpacing - scale.height angle:[self correctAngle:drawAngle]];
        
        [path moveToPoint:startPoint];
        [path addLineToPoint:endPoint];
        [path moveToPoint:startPoint];
        [path addLineToPoint:endPoint];
        [scale.color setStroke];
        
        if (scale == ruler.markScale) {
            [self drawMarkWithRuler:ruler angle:drawAngle value:drawValue];
        }
        
        drawAngle -= zoomScaleAngle;
        drawValue -= ruler.scaleValue;
    }
    
    [path stroke];

}

- (void)drawMarkWithRuler:(XTRuler *)ruler angle:(CGFloat)angle value:(CGFloat)value {
    NSString *markStr = @"00:00";
    if (ruler.markRule) {
        markStr = ruler.markRule(value);
    }
    UIFont *markFont = [UIFont systemFontOfSize:ruler.markFontSize];
    CGSize textSize = [markStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:markFont} context:nil].size;
    
    CGFloat markRotateAngle = angle + self.directionAngle; //文字本身旋转角度
    CGPoint markCenterPoint = [self arcPointWithCenter:self.arcCenter raidus:self.radius - ruler.markTopSpacing - textSize.height/2  angle:[self correctAngle:angle]];
    if (ruler.markDirection == XTRulerMarkDirectionHorizontal) {
        markRotateAngle = markRotateAngle + M_PI_2;
        markCenterPoint = [self arcPointWithCenter:self.arcCenter raidus:self.radius - ruler.markTopSpacing - textSize.width/2  angle:[self correctAngle:angle]];

    }
    [markStr drawWithBasePoint:markCenterPoint angle:markRotateAngle font:markFont color:ruler.markFontColor];
}

- (void)drawIndicator {
    [self.indicatorColor set];
    //上三角
    CGFloat angle = 7.5/800;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.arcCenter radius:self.radius startAngle:[self correctAngle:-angle] endAngle:[self correctAngle:angle] clockwise:YES];
    [path addLineToPoint:[self arcPointWithCenter:self.arcCenter raidus:self.radius-12 angle:[self correctAngle:0]]];
    
    //下三角
    [path moveToPoint:[self arcPointWithCenter:self.arcCenter raidus:self.radius-65 angle:[self correctAngle:0]]];
    CGFloat pointToCenter = (7.5/96)*(self.radius-65);
    [path addLineToPoint:[self arcPointWithCenter:self.arcCenter raidus:pointToCenter angle:[self correctAngle:-M_PI_2]]];
    [path addLineToPoint:[self arcPointWithCenter:self.arcCenter raidus:pointToCenter angle:[self correctAngle:M_PI_2]]];
    [path fill];
}


/**
 根据尺子对象和值返回对应的刻度属性对象

 @param ruler 尺子
 @param value 值
 @return 刻度
 */
- (XTRulerScale *)scaleWithRuler:(XTRuler *)ruler Value:(CGFloat)value {
    CGFloat increValue = value - ruler.minValue; //值和最小值（原点）的值差
    CGFloat increRatio = increValue/ruler.scaleValue; //和刻度间值的倍数
    if (increRatio - (NSInteger)(increRatio) != 0) { //没有整除说明这个值不需要画刻度
        return nil;
    }
    
    NSInteger iRatio = (NSInteger)increRatio;
    if (iRatio % (ruler.minorScaleCount * ruler.markMajorScaleCount) == 0) {
//        NSLog(@"大刻度M selectedValue:%@ value:%@ increValue:%@ increRatio:%@",@(_selectedValue), @(value), @(increValue), @(increRatio));

        return ruler.markScale;
    }
    
    if (iRatio % ruler.minorScaleCount == 0) {
//        NSLog(@"大刻度U selectedValue:%@ value:%@ increValue:%@ increRatio:%@",@(_selectedValue), @(value), @(increValue), @(increRatio));

        return ruler.unmarkScale;
    }
    
//    NSLog(@"小刻度 selectedValue:%@ value:%@ increValue:%@ increRatio:%@",@(_selectedValue), @(value), @(increValue), @(increRatio));
    return ruler.minorScale;
}


#pragma mark - 手势
- (void)addGestures {
    if (self.enableZoom) {
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinch:)];
        [self addGestureRecognizer:pinch];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    [self addGestureRecognizer:pan];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
    [self addGestureRecognizer:swipe];
}

- (void)onPinch:(UIPinchGestureRecognizer *)gesture {
    static CGFloat zoomScale;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            zoomScale = 1;
            break;
        case UIGestureRecognizerStateEnded: {
            
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGFloat increScale = (gesture.scale - zoomScale)/zoomScale;
            zoomScale = gesture.scale;
            
            self.currentZoomScale *= (1 + increScale);
            
            NSLog(@"pinch scale: %@, currentZoomScale: %@", @(gesture.scale), @(self.currentZoomScale));
        }
            
            break;
        default:
            break;
    }
}

- (void)onTap:(UITapGestureRecognizer *)gesture {
    NSLog(@"%s",__func__);
}

- (void)onPan:(UIPanGestureRecognizer *)gesture {
    static CGPoint previousTrans;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            previousTrans = CGPointZero;
            break;
        case UIGestureRecognizerStateEnded: {
            CGPoint speed = [gesture velocityInView:self];
            NSLog(@"velocityInView %@ currentValue:%@", @(speed), @(self.selectedValue));
        }
            break;
        case UIGestureRecognizerStateChanged: {

            CGPoint translation = [gesture translationInView:self];
            if (floor(previousTrans.x) == floor(translation.x) &&
                floor(previousTrans.y) == floor(translation.y)) { //限制处理频率，不到1单位的坐标改变不处理
                return;
            }
            
            CGFloat moveX = translation.x - previousTrans.x;
            CGFloat moveY = translation.y - previousTrans.y;
            previousTrans = translation;
            
            CGFloat realMoveX = moveX * cos(self.directionAngle);
            CGFloat realMoveY = moveY * sin(self.directionAngle);
            CGFloat move = sqrt(realMoveX * realMoveX + realMoveY * realMoveY);

            //计算偏转角度
            CGFloat moveAngle = asin(move/self.radius);
            //TODO: 偏转方向，正还是负，这只是粗略判断，尚未完全弄明白公式，待优化
            if (realMoveX < 0 ||
                realMoveY < 0) {
                moveAngle = -moveAngle;
            }
            
            //根据偏转角度计算当前值
//            self.selectedValue -= moveAngle * self.currentRuler.scaleValue/(self.currentRuler.scaleAngle * self.currentZoomScale);
            self.selectedValue -= moveAngle * self.currentRuler.scaleValue/[self zoomScaleAngle];

            
        }
            break;
        default:
            break;
    }
}

- (void)onSwipe:(UISwipeGestureRecognizer *)gesture {
    NSLog(@"%s",__func__);
}

#pragma mark -

/**
 根据当前缩放倍数切换刻度尺属性
 */
- (void)updateCurrentRulerWitOldZoomScale:(CGFloat)oldZoomScale newZoomScale:(CGFloat)newZoomScale {
    NSArray<NSNumber *> *zoomScales = self.mulRulers.allKeys;
    if (!(zoomScales.count > 1)) {
        return;
    }
    
    CGFloat largeScale = oldZoomScale > newZoomScale ? oldZoomScale : newZoomScale;
    CGFloat smallScale = oldZoomScale > newZoomScale ? newZoomScale : oldZoomScale;
    NSLog(@"largeScale:%@ smallScale:%@",@(largeScale), @(smallScale));
    __weak typeof(self) weakSelf = self;
    [self.mulRulers.allKeys enumerateObjectsUsingBlock:^(NSNumber * _Nonnull scale, NSUInteger idx, BOOL * _Nonnull stop) {
        if (([scale doubleValue] >= smallScale) && ([scale doubleValue] <= largeScale)) {
            if (weakSelf.currentRuler != weakSelf.mulRulers[scale]) {
                weakSelf.currentRuler = weakSelf.mulRulers[scale];
                NSLog(@"currentRuler changed");
                *stop = YES;
            }
        }
    }];
    
}


/**
 根据当前刻度尺和当前总的缩放倍率计算每个刻度间的角度
 */
- (CGFloat)zoomScaleAngle {
    
    CGFloat currentRulerScale = 1; //计算当前刻度尺的切换倍率
    for (NSNumber *scale in self.mulRulers.allKeys) {
        if (self.mulRulers[scale] == self.currentRuler) {
            currentRulerScale = [scale doubleValue];
            break;
        }
    }
    CGFloat angleScale = self.currentZoomScale - currentRulerScale + 1;
    return self.currentRuler.scaleAngle * angleScale;
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

- (CGPoint)arcCenter {
    //TODO: arcCenter需要频繁使用，在getter实时计算可能比较耗性能，待优化
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

- (void)setSelectedValue:(CGFloat)selectedValue {
    _selectedValue = selectedValue;
    [self setNeedsDisplay];
}

- (void)setCurrentZoomScale:(CGFloat)currentZoomScale {
    [self updateCurrentRulerWitOldZoomScale:_currentZoomScale newZoomScale:currentZoomScale];
    _currentZoomScale = currentZoomScale;
    [self setNeedsDisplay];
}


@end
