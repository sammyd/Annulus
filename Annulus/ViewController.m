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
    ringHolder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    ring.backgroundLayer.frame = ringHolder.bounds;
    [ring.backgroundLayer setNeedsDisplay];
    ring.foregroundLayer.frame = ringHolder.bounds;
    [ring.foregroundLayer setNeedsDisplay];
    [ringHolder.layer addSublayer:ring.backgroundLayer];
    [ringHolder.layer addSublayer:ring.foregroundLayer];
    
    
    CGFloat y = 100;
    CGFloat x = 0;
    progressRings = [[NSMutableArray alloc] init];
    for (int i=0; i<50; i++) {
        Ring * r = [[[Ring alloc] init] autorelease];
        UIView *v = [[[UIView alloc] initWithFrame:CGRectMake(x, y, 100, 100)] autorelease];
        r.backgroundLayer.frame = v.bounds;
        r.foregroundLayer.frame = v.bounds;
        [r.backgroundLayer setNeedsDisplay];
        [r.foregroundLayer setNeedsDisplay];
        [v.layer insertSublayer:r.backgroundLayer below:ring.backgroundLayer];
        [v.layer insertSublayer:r.foregroundLayer below:ring.backgroundLayer];
        [self.view addSubview:v];
        [progressRings addObject:r];
        if(y > 600) {
            y = 0;
            x += 100;
        } else {
            y += 100;
        }
    }
    
    
    //timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(progressTimer) userInfo:nil repeats:YES];
    
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(progressTimer)];
    displayLink.frameInterval = 4;
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
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
    
    ring.startAngle = (currentValue - 0.1) * M_PI * 2;
    ring.endAngle = (currentValue + 0.1) * M_PI * 2;
    [ring updateSegment];
    
    for (Ring *r in progressRings) {
        r.startAngle = 0;
        r.endAngle = currentValue * M_PI * 2;
        [r updateSegment];
    }
    
}

- (void)dealloc
{
    [ring release];
    [ringHolder release];
    [progressRings release];
    //[timer invalidate];
    [displayLink invalidate];
    timer = nil;
    [super dealloc];
}

@end
