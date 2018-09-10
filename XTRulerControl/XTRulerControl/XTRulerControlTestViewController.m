//
//  XTRulerControlTestViewController.m
//  XTRulerControl
//
//  Created by ZengYuYing on 2018/8/30.
//  Copyright © 2018 ZengYuYing. All rights reserved.
//

#import "XTRulerControlTestViewController.h"
#import "XTArcRulerControl.h"
@interface XTRulerControlTestViewController ()
@property (strong, nonatomic) XTArcRulerControl *rulerControl;
@property (weak, nonatomic) IBOutlet UISlider *angleSlider;

@end

@implementation XTRulerControlTestViewController

- (XTArcRulerControl *)rulerControl {
    if (!_rulerControl) {
        
        XTRuler *ruler1 = [[XTRuler alloc] init];
        XTRuler *ruler2 = [[XTRuler alloc] init];
        ruler2.scaleValue = 300;
        ruler2.scaleAngle = ruler1.scaleAngle * (ruler1.scaleValue/ruler2.scaleValue)/4;

        
        XTRuler *ruler3 = [[XTRuler alloc] init];
        ruler3.scaleValue = 1200;
        ruler3.scaleAngle = ruler1.scaleAngle * (ruler1.scaleValue/ruler3.scaleValue);
        
        XTRuler *ruler4 = [[XTRuler alloc] init];
        ruler4.scaleValue = 60;
        ruler4.minorScaleCount = 5;
        
        XTRuler *ruler5 = [[XTRuler alloc] init];
        ruler5.scaleValue = 1;
        ruler5.minorScaleCount = 5;
        ruler5.markMajorScaleCount = 2;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"hh:mm:ss";
        ruler5.markRule = ^NSString *(CGFloat value) {
            return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:value]];
        };

        
        XTRulerFillArea *fillArea1 = [[XTRulerFillArea alloc] init];
        fillArea1.beginValue = 120;
        fillArea1.endValue = 3600;
        fillArea1.fillColor = [UIColor colorWithRed:95/255.0 green:58/255.0 blue:28/255.0 alpha:0.5];
        
        XTRulerFillArea *fillArea2 = [[XTRulerFillArea alloc] init];
        fillArea2.beginValue = 4000;
        fillArea2.endValue = 8000;
        fillArea2.fillColor = [UIColor colorWithRed:48/255.0 green:58/255.0 blue:88/255.0 alpha:0.5];
        
        
        _rulerControl = [[XTArcRulerControl alloc] initWithMultipleRulers:@{@(1):ruler1, @(2.5):ruler2, @(0.4):ruler3, @(6):ruler4, @(9):ruler5}];
        _rulerControl.radius = 400;
//        _rulerControl.radius = [UIScreen mainScreen].bounds.size.width/2;
        _rulerControl.backgroundColor = [UIColor whiteColor];
        _rulerControl.selectedValue = -200;
        _rulerControl.fillAreas = @[fillArea1, fillArea2];
        
    
    }
    return _rulerControl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.rulerControl];
        
    [self.angleSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self incrementValue];
    });
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 500, 97, 70)];
//    button.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
    button.layer.shadowRadius = 4;
    button.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
    button.layer.shadowOffset = CGSizeMake(0, 0);
    button.layer.shadowOpacity = 1;

    [button setImage:[UIImage imageNamed:@"未按"] forState:UIControlStateNormal];
    [self.view addSubview:button];
}

- (void)incrementValue {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.rulerControl.selectedValue += 0.1;
        [self incrementValue];
    });
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _rulerControl.frame = CGRectMake(0, 200, self.view.frame.size.width , 160);
//    _rulerControl.frame = CGRectMake(0, 200, self.view.frame.size.width , self.view.frame.size.width);

    
}

- (void)sliderValueChanged:(UISlider *)slider {
    if (slider == self.angleSlider) {
        self.rulerControl.directionAngle = slider.value * M_PI * 2;
    }
    
}



@end
