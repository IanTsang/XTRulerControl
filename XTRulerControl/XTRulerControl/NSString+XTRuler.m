//
//  NSString+XTRuler.m
//  XTRulerControl
//
//  Created by ZengYuYing on 2018/9/5.
//  Copyright © 2018 ZengYuYing. All rights reserved.
//

#import "NSString+XTRuler.h"

@implementation NSString (XTRuler)

- (void)xt_drawWithCenterPoint:(CGPoint)centerPoint angle:(CGFloat)angle font:(UIFont *)font color:(UIColor *)color {
    CGSize textSize = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform t = CGAffineTransformMakeTranslation(centerPoint.x, centerPoint.y);
    CGAffineTransform r = CGAffineTransformMakeRotation(angle);
    
    CGContextConcatCTM(context, t);
    CGContextConcatCTM(context, r);
    
    [self drawAtPoint:CGPointMake(-1 * textSize.width / 2, -1 * textSize.height / 2) withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:color}];
    
    CGContextConcatCTM(context, CGAffineTransformInvert(r));
    CGContextConcatCTM(context, CGAffineTransformInvert(t));
}

@end
