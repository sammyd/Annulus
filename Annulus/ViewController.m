//
//  ViewController.m
//  Annulus
//
//  Created by Sam Davies on 26/10/2012.
//  Copyright (c) 2012 VisualPutty. All rights reserved.
//

#import "ViewController.h"


@interface ViewController () {
    CGFloat currentValue;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    ring = [[Ring alloc] initWithFrame:CGRectMake(100, 100, 50, 50)];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(progressTimer) userInfo:nil repeats:YES];
    currentValue = 0;
    [self.view addSubview:ring];
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
    [ring setNeedsDisplay];
}

- (void)dealloc
{
    [ring release];
    [timer invalidate];
    timer = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
