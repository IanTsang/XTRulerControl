//
//  XTRulerControl.m
//  XTRulerControl
//
//  Created by ZengYuYing on 2018/8/27.
//  Copyright © 2018 ZengYuYing. All rights reserved.
//

#import "XTRulerControl.h"

@interface XTRulerControl () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;     /**< 滚动容器 */
@property (nonatomic, strong) UIImageView *rulerImageView;  /**< 显示刻度尺的ImageView */
@property (nonatomic, strong) UIView *indicatorView;        /**< 中间的指示条 */

@property (nonatomic, assign) BOOL reloadRuler;             /**< 重绘刻度尺 */
@end


@implementation XTRulerControl

- (instancetype)initWithFrame:(CGRect)frame
{
    NSLog(@"%s", __func__);
    self = [super initWithFrame:frame];
    if (self) {
        self.reloadRuler = NO;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    NSLog(@"%s", __func__);

    [self addSubview:self.scrollView];
    [self addSubview:self.indicatorView];
    
    [self.scrollView addSubview:self.rulerImageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"%s", __func__);

    // 刻度尺图片为空或者需要重新加载时，创建刻度尺图片
    if (!self.rulerImageView.image || self.reloadRuler) {
        [self loadRuler];
    }
    
    self.backgroundColor = self.rulerBackgroundColor;

    
    CGFloat tempW = 1;
    CGFloat tempH = self.frame.size.height;
    CGFloat tempX = (self.frame.size.width - tempW)/2;
    CGFloat tempY = 0;
    self.indicatorView.frame = CGRectMake(tempX, tempY, tempW, tempH);
    
    self.scrollView.contentSize = self.rulerImageView.image.size;
    
}

- (void)loadRuler {
    UIImage *rulerImage = [self createRulerImage];
    if (!rulerImage) {
        return;
    }
    self.rulerImageView.image = [self createRulerImage];
    [self.rulerImageView sizeToFit];
    
}

- (UIImage *)createRulerImage {
    NSInteger scaleCount = self.maxValue / self.scaleValue + 1; //总刻度数量
    
    NSInteger majorScaleCount = self.maxValue / (self.scaleValue * self.minorScaleCount) + 1; //大刻度总数量
    NSInteger markScaleCount = self.maxValue / (self.scaleValue * self.markMajorScaleCount * self.minorScaleCount) + 1; //标记数值的大刻度数量
    NSInteger unmarkScaleCount = majorScaleCount - markScaleCount;
    
//    UIGraphicsBeginImageContext(<#CGSize size#>);
    return nil;
}

#pragma mark - private
- (CGSize)maxValueMarkStringSize {
    NSString *maxMarkString = [self markStringForValue:self.maxValue];
    CGSize size = [maxMarkString boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[self markStringAttributes] context:nil].size;
    return size;
}

- (NSDictionary *)markStringAttributes {
    CGFloat fontSize = self.markFontSize * [UIScreen mainScreen].scale * 0.6;
    return @{NSForegroundColorAttributeName: self.markFontColor,
             NSFontAttributeName: [UIFont boldSystemFontOfSize:fontSize]};
}

- (NSString *)markStringForValue:(CGFloat)value {
    if (self.markRule) {
        return self.markRule(value);
    }
    return @(value).description;
}

#pragma mark - UIScrollViewDelegate
#pragma mark - getter
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.scrollEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIImageView *)rulerImageView {
    if (!_rulerImageView) {
        _rulerImageView = [[UIImageView alloc] init];
    }
    return _rulerImageView;
}
- (UIView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIView alloc] init];
        _indicatorView.backgroundColor = self.indicatorColor;
    }
    return _indicatorView;
}

- (UIColor *)indicatorColor {
    if (!_indicatorColor) {
        _indicatorColor = [UIColor redColor];
    }
    return _indicatorColor;
}

- (UIColor *)rulerBackgroundColor {
    if (!_rulerBackgroundColor) {
        _rulerBackgroundColor = [UIColor clearColor];
    }
    return _rulerBackgroundColor;
}

@end
