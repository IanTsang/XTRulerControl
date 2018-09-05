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
//        _rulerControl = [[XTArcRulerControl alloc] initWithRuler:[[XTRuler alloc] init]];

        
        XTRuler *ruler1 = [[XTRuler alloc] init];
        XTRuler *ruler2 = [[XTRuler alloc] init];
//        ruler2.scaleAngle = 2.5;
        ruler2.scaleValue = 300;
        
        XTRuler *ruler3 = [[XTRuler alloc] init];
//        ruler3.scaleAngle = 2.5 * 3;
        ruler3.scaleValue = 1200;
        
        _rulerControl = [[XTArcRulerControl alloc] initWithMultipleRulers:@{@(1):ruler1, @(3):ruler2, @(0.33):ruler3}];
        _rulerControl.radius = 800;
        _rulerControl.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.8];
        _rulerControl.selectedValue = -200;
        
    
    }
    return _rulerControl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.rulerControl];
        
    [self.angleSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self incrementValue];
//    });
}

- (void)incrementValue {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.rulerControl.selectedValue += 1;
        [self incrementValue];
    });
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _rulerControl.frame = CGRectMake(0, 200, self.view.frame.size.width , 160);
    
}

- (void)sliderValueChanged:(UISlider *)slider {
    if (slider == self.angleSlider) {
        self.rulerControl.directionAngle = slider.value * M_PI * 2;
    }
    
}



@end
