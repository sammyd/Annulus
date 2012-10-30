//
//  Ring.h
//  Annulus
//
//  Created by Sam Davies on 26/10/2012.
//  Copyright (c) 2012 VisualPutty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Ring : NSObject {
    CGFloat currentSegmentAngle;
}

@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, assign) CGFloat endAngle;
@property (nonatomic, retain) CALayer *foregroundLayer;
@property (nonatomic, retain) CALayer *backgroundLayer;

- (void)updateSegment;

@end
