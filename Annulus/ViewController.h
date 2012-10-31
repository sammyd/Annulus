//
//  ViewController.h
//  Annulus
//
//  Created by Sam Davies on 26/10/2012.
//  Copyright (c) 2012 VisualPutty. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Ring.h"

@interface ViewController : UIViewController {
    Ring *ring;
    NSMutableArray *progressRings;
    UIView *ringHolder;
    NSTimer *timer;
    CADisplayLink *displayLink;
}

@end
