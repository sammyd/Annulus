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
    UIView *ringHolder;
    NSTimer *timer;
}

@end
