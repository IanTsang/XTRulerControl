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
        _rulerControl = [[XTArcRulerControl alloc] initWithRuler:[[XTRuler alloc] init]];
        _rulerControl.radius = 800;
        _rulerControl.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.8];

    }
    return _rulerControl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.rulerControl];
        
    [self.angleSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
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
