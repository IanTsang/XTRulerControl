//
//  XTRulerControl.h
//  XTRulerControl
//
//  Created by ZengYuYing on 2018/8/27.
//  Copyright © 2018 ZengYuYing. All rights reserved.
//

#import <UIKit/UIKit.h>


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
@interface XTRulerScale
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGFloat width;        /**< 宽度 */
@property (nonatomic, assign) CGFloat height;       /**< 高度 */
@property (nonatomic, assign) CGLineCap lineCap;    /**< 刻度首尾样式 */
@end


/**
 刻度尺
 */
@interface XTRulerControl : UIControl

@property (nonatomic, strong) UIColor *rulerBackgroundColor;        /**< 刻度尺背景颜色 */

@property (nonatomic, assign) CGFloat selectedValue;                /**< 选中的值 */
@property (nonatomic, assign) CGFloat minValue;                     /**< 最小值 */
@property (nonatomic, assign) CGFloat maxValue;                     /**< 最大值 */
@property (nonatomic, assign) CGFloat scaleValue;                   /**< 每个刻度间的值差 */

@property (nonatomic, assign) CGFloat scaleSpacing;                 /**< 刻度间距（刻度中心直线距离） */
@property (nonatomic, strong) XTRulerScale *minorScale;             /**< 小刻度 */
@property (nonatomic, strong) XTRulerScale *markScale;              /**< 有值标记的大刻度 */
@property (nonatomic, strong) XTRulerScale *unmarkScale;            /**< 没有值标记的大刻度 */

@property (nonatomic, assign) CGSize  indicatorSize;                /**< 指示条大小 */
@property (nonatomic, strong) UIColor *indicatorColor;              /**< 指示条颜色 */

@property (nonatomic, assign) CGFloat markFontSize;                 /**< 标记字体大小 */
@property (nonatomic, strong) UIColor *markFontColor;               /**< 标记字体颜色 */
@property (nonatomic, assign) NSInteger minorScaleCount;            /**< 一个大刻度间的小刻度数量 */
@property (nonatomic, assign) NSInteger markMajorScaleCount;        /**< 几个大刻度做一个数值标记 */
@property (nonatomic, copy) NSString *(^markRule)(CGFloat value);   /**< 指定value的刻度应该怎么显示 */

@property (nonatomic, copy) NSArray<XTRulerFillArea *> *fillAreas;  /**< 填充区域 */

@end
