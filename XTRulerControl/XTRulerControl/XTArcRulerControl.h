//
//  XTArcRulerControl.h
//  XTRulerControl
//
//  Created by ZengYuYing on 2018/8/31.
//  Copyright © 2018 ZengYuYing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewExt.h"
#import "NSString+XTRuler.h"
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
 标记方向类型
 
 - XTRulerMarkDirectionVertical: 默认垂直于刻度
 - XTRulerMarkDirectionHorizontal: 跟刻度平行
 */
typedef NS_ENUM(NSUInteger, XTRulerMarkDirection) {
    XTRulerMarkDirectionDefault,
    XTRulerMarkDirectionVertical,
    XTRulerMarkDirectionHorizontal,
};

/**
 刻度尺属性
 */
@interface XTRuler : NSObject

@property (nonatomic, strong) UIColor *backgroundColor;             /**< 刻度尺背景颜色 */
@property (nonatomic, assign) CGFloat minValue;                     /**< 最小值，默认0 */
@property (nonatomic, assign) CGFloat maxValue;                     /**< 最大值，默认CGFLOAT_MAX */
@property (nonatomic, assign) CGFloat scaleValue;                   /**< 每个刻度间的值差，默认600 */
@property (nonatomic, assign) CGFloat scaleAngle;                   /**< 刻度间角度，需转换为弧度rad，360°=2π，默认2.5 * (M_PI/180) */
//@property (nonatomic, assign) CGFloat scaleSpacing;                 /**< 刻度间距（刻度中心直线距离） */
@property (nonatomic, strong) XTRulerScale *minorScale;             /**< 小刻度 */
@property (nonatomic, strong) XTRulerScale *markScale;              /**< 有值标记的大刻度 */
@property (nonatomic, strong) XTRulerScale *unmarkScale;            /**< 没有值标记的大刻度 */

@property (nonatomic, assign) CGFloat markFontSize;                 /**< 标记字体大小，默认14 */
@property (nonatomic, strong) UIColor *markFontColor;               /**< 标记字体颜色，默认半透明黑 */
@property (nonatomic, assign) CGFloat markTopSpacing;               /**< 标记顶部间距（距离圆弧距离），默认40 */
@property (nonatomic, assign) XTRulerMarkDirection markDirection;   /**< 标记方向 default = XTRulerMarkDirectionVertical */
@property (nonatomic, assign) NSInteger minorScaleCount;            /**< 一个大刻度间的小刻度数量，默认6 */
@property (nonatomic, assign) NSInteger markMajorScaleCount;        /**< 几个大刻度做一个数值标记，默认1 */
@property (nonatomic, copy) NSString *(^markRule)(CGFloat value);   /**< 指定value的刻度应该怎么显示，默认是时间格式"HH:mm" */


@end

/**
 刻度尺
 */
@interface XTArcRulerControl : UIControl

@property (nonatomic, assign) CGFloat selectedValue;                /**< 选中的值 */
@property (nonatomic, assign) CGFloat directionAngle;               /**< 刻度尺总体方向, 范围[0, PI*2], 默认是0，方向正上 */
@property (nonatomic, assign) CGFloat radius;                       /**< 圆弧半径，默认等于刻度尺宽度（self.frame.size.width） */
@property (nonatomic, copy)   NSArray<XTRulerFillArea *> *fillAreas;/**< 填充区域 */
@property (nonatomic, strong) UIColor *indicatorColor;              /**< 指示条颜色 */
@property (nonatomic, assign) BOOL enableZoom;                      /**< 缩放开关，默认开 */
@property (nonatomic, assign) CGFloat minZoomScale;                 /**< 最小缩放倍率，默认0.1 */
@property (nonatomic, assign) CGFloat maxZoomScale;                 /**< 最大缩放倍率，默认10 */
@property (nonatomic, assign) XTRulerMarkDirection markDirection;   /**< 设置标记方向 default = XTRulerMarkDirectionDefault，设置后会覆盖单个XTRuler对象的方向 */
@property (nonatomic, copy)   NSDictionary<NSNumber*, XTRuler*> *mulRulers; /**< 不同缩放倍率对应的刻度尺 */

@property (nonatomic, copy) void(^valueChangeBegin)(CGFloat currentValue);
@property (nonatomic, copy) BOOL(^valueShouldChange)(CGFloat currentValue, CGFloat newValue);
@property (nonatomic, copy) void(^valueChangeEnd)(CGFloat currentValue);

- (instancetype)init NS_UNAVAILABLE;


/**
 单精度构造方法
 */
- (instancetype)initWithRuler:(XTRuler *)ruler;

/**
 多精度构造方法。使用此构造方法进行创建，支持通过缩放手势在多个刻度尺精度间进行切换

 @param mulRulers 刻度尺信息，key为缩放倍数，value为对应的刻度尺属性，必须至少包含一个key=@(1)的项作为默认刻度尺
 @return 对象
 */
- (instancetype)initWithMultipleRulers:(NSDictionary<NSNumber*, XTRuler*> *)mulRulers;

@end

