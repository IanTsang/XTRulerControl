//
//  NSString+XTRuler.h
//  XTRulerControl
//
//  Created by ZengYuYing on 2018/9/5.
//  Copyright © 2018 ZengYuYing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (XTRuler)
- (void)drawWithBasePoint:(CGPoint)basePoint angle:(CGFloat)angle font:(UIFont *)font color:(UIColor *)color;
@end
