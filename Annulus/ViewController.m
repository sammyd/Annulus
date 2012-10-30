//
//  ViewController.m
//  Annulus
//
//  Created by Sam Davies on 26/10/2012.
//  Copyright (c) 2012 VisualPutty. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface ViewController () {
    CGFloat currentValue;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    ring = [[Ring alloc] init];
    ringHolder = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    ring.backgroundLayer.frame = ringHolder.bounds;
    [ring.backgroundLayer setNeedsDisplay];
    ring.foregroundLayer.frame = ringHolder.bounds;
    [ring.foregroundLayer setNeedsDisplay];
    [ringHolder.layer addSublayer:ring.backgroundLayer];
    [ringHolder.layer addSublayer:ring.foregroundLayer];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(progressTimer) userInfo:nil repeats:YES];
    currentValue = 0;
    [self.view addSubview:ringHolder];
}

- (void)progressTimer
{
    if(currentValue >= 1) {
        currentValue = 0.02;
    } else {
        currentValue += 0.02;
    }
    
    ring.startAngle = (currentValue - 0.3) * M_PI * 2;
    ring.endAngle = (currentValue + 0.3) * M_PI * 2;
    [ring updateSegment];
}

- (void)dealloc
{
    [ring release];
    [ringHolder release];
    [timer invalidate];
    timer = nil;
    [super dealloc];
}

@end
