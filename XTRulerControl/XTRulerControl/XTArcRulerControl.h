//
//  XTArcRulerControl.h
//  XTRulerControl
//
//  Created by ZengYuYing on 2018/8/31.
//  Copyright © 2018 ZengYuYing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewExt.h"

/**
 刻度尺填充区域类
 */
@interface XTRulerFillArea : NSObject
@property (nonatomic, assign) CGFloat beginValue; /**< 填充开始值 */
@property (nonatomic, assign) CGFloat endValue;   /**< 填充结束值 */
@property (nonatomic, strong) UIColor *fillColor; /**< 填充颜色 */
@end

/**
 刻度属性
 */
@interface XTRulerScale : NSObject
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGFloat width;        /**< 宽度 */
@property (nonatomic, assign) CGFloat height;       /**< 高度 */
@property (nonatomic, assign) CGLineCap lineCap;    /**< 刻度首尾样式 */
@property (nonatomic, assign) CGFloat topSpacing;   /**< 顶部间距，即距离圆弧距离 */
@end

/**
 刻度尺属性
 */
@interface XTRuler : NSObject

@property (nonatomic, strong) UIColor *backgroundColor;             /**< 刻度尺背景颜色 */
@property (nonatomic, assign) CGFloat minValue;                     /**< 最小值 */
@property (nonatomic, assign) CGFloat maxValue;                     /**< 最大值 */
@property (nonatomic, assign) CGFloat scaleValue;                   /**< 每个刻度间的值差 */
@property (nonatomic, assign) CGFloat scaleAngle;                   /**< 刻度间角度，需转换为π单位，360°=2π */

//@property (nonatomic, assign) CGFloat scaleSpacing;                 /**< 刻度间距（刻度中心直线距离） */
@property (nonatomic, strong) XTRulerScale *minorScale;             /**< 小刻度 */
@property (nonatomic, strong) XTRulerScale *markScale;              /**< 有值标记的大刻度 */
@property (nonatomic, strong) XTRulerScale *unmarkScale;            /**< 没有值标记的大刻度 */

@property (nonatomic, assign) CGFloat markFontSize;                 /**< 标记字体大小 */
@property (nonatomic, strong) UIColor *markFontColor;               /**< 标记字体颜色 */
@property (nonatomic, assign) CGFloat markTopSpacing;               /**< 标记顶部间距（距离圆弧距离） */
@property (nonatomic, assign) NSInteger minorScaleCount;            /**< 一个大刻度间的小刻度数量 */
@property (nonatomic, assign) NSInteger markMajorScaleCount;        /**< 几个大刻度做一个数值标记 */
@property (nonatomic, copy) NSString *(^markRule)(CGFloat value);   /**< 指定value的刻度应该怎么显示 */
@property (nonatomic, copy) NSArray<XTRulerFillArea *> *fillAreas;  /**< 填充区域 */

@end


/**
 标记方向类型

 - XTRulerMarkDirectionUp: 默认向上
 - XTRulerMarkDirectionFollowScale: 跟随刻度方向
 */
typedef NS_ENUM(NSUInteger, XTRulerMarkDirection) {
    XTRulerMarkDirectionUp,
    XTRulerMarkDirectionFollowScale,
};

//typedef NS_ENUM(NSUInteger, XTRulerIndicatorDirection) {
//    XTRulerIndicatorDirectionUp,
//    XTRulerIndicatorDirectionDown,
//    XTRulerIndicatorDirectionLeft,
//    XTRulerIndicatorDirectionRight,
//
//};

/**
 刻度尺
 */
@interface XTArcRulerControl : UIControl

@property (nonatomic, assign) CGFloat selectedValue;                /**< 选中的值 */
@property (nonatomic, assign) CGFloat directionAngle;               /**< 刻度尺总体方向, range is [0, PI*2], default is PI*1.5 */
@property (nonatomic, assign) CGFloat radius;                       /**< 圆弧半径，默认等于刻度尺宽度（self.frame.size.width） */
@property (nonatomic, assign) XTRulerMarkDirection markDirection;   /**< 标记方向 default = XTRulerMarkDirectionUp */

@property (nonatomic, strong) UIColor *indicatorColor;              /**< 指示条颜色 */

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithRuler:(XTRuler *)ruler;
- (instancetype)initWithRulers:(NSArray<XTRuler *> *)rulers zoomScales:(NSArray<NSNumber *> *)zoomScales;


@end

