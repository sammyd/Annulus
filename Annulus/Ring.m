//
//  Ring.m
//  Annulus
//
//  Created by Sam Davies on 26/10/2012.
//  Copyright (c) 2012 VisualPutty. All rights reserved.
//

#import "Ring.h"
#import <QuartzCore/QuartzCore.h>


@implementation Ring

@synthesize startAngle = _startAngle;
@synthesize endAngle = _endAngle;
@synthesize foregroundLayer = _foregroundLayer;
@synthesize backgroundLayer = _backgroundLayer;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        self.backgroundLayer = [CALayer layer];
        self.backgroundLayer.delegate = self;
        self.foregroundLayer = [CALayer layer];
        self.foregroundLayer.delegate = self;
        
        currentSegmentAngle = 0;
    }
    return self;
}

- (void)dealloc
{
    [_foregroundLayer release];
    [_backgroundLayer release];
    [super dealloc];
}


- (void)drawForegroundSegmentInContext:(CGContextRef)context
{    
    CGColorSpaceRef colorSpace  = CGColorSpaceCreateDeviceRGB();
    
    CGContextSaveGState(context);
    {
        CGFloat bigLineThickness = MIN(self.foregroundLayer.bounds.size.width,self.foregroundLayer.bounds.size.height)/5; // NB: copy/pasted from other method
        CGFloat lineThickness = bigLineThickness - 4;
        
        CGPoint centre = CGPointMake(self.foregroundLayer.bounds.size.width / 2, self.foregroundLayer.bounds.size.height / 2);
        CGFloat radius = MIN(self.foregroundLayer.bounds.size.height, self.foregroundLayer.bounds.size.width) / 2 - bigLineThickness / 2;
        UIBezierPath *segment = [UIBezierPath bezierPathWithArcCenter:centre radius:radius startAngle:self.startAngle endAngle:self.endAngle clockwise:YES];
        
        CGContextSaveGState(context);
        {
            // Drop into core graphics
            CGContextAddPath(context, segment.CGPath);
            CGContextSetLineWidth(context, lineThickness);
            CGContextSetLineCap(context, kCGLineCapRound);
            
            // Let's change it from a single line to an outline
            CGContextReplacePathWithStrokedPath(context);
            
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.1 green:0.6 blue:0.9 alpha:1].CGColor);
            
            // So now we can fill with this. Magic.
            CGContextFillPath(context);
            
            
            // Now need to rebuild the path in the context
            // Drop into core graphics
            CGContextAddPath(context, segment.CGPath);
            CGContextSetLineWidth(context, lineThickness);
            CGContextSetLineCap(context, kCGLineCapButt);
            
            // Let's change it from a single line to an outline
            CGContextReplacePathWithStrokedPath(context);
            
            // I think we should now try using it as a mask
            CGContextClip(context);

            {
                CGGradientRef myGradient;
                size_t num_locations = 3;
                CGFloat locations[3] = { 0.0, 0.5, 1.0 };
                CGFloat components[12] = { 0.2, 0.2, 0.2, 0.2,  // Start color
                                           1.0, 1.0, 1.0, 0.4,
                                           0.2, 0.2, 0.2, 0.2 }; // End color

                myGradient = CGGradientCreateWithColorComponents (colorSpace, components, locations, num_locations);
                CGContextDrawRadialGradient(context, myGradient, centre, radius - lineThickness/2, centre, radius + lineThickness/2, 0);
                CGGradientRelease(myGradient);
            }
        }
        CGContextRestoreGState(context);
        
        
        CGContextSaveGState(context);
        {
            // Drop into core graphics
            CGContextAddPath(context, segment.CGPath);
            CGContextSetLineWidth(context, lineThickness);
            CGContextSetLineCap(context, kCGLineCapButt);
            
            // Let's change it from a single line to an outline
            CGContextReplacePathWithStrokedPath(context);
            
            CGContextAddRect(context, self.foregroundLayer.bounds);
            
            // I think we should now try using it as a mask
            CGContextEOClip(context);
            
            // And now for the 2 end pieces
            {
                CGGradientRef myGradient;
                size_t num_locations = 2;
                CGFloat locations[2] = {0.0, 1.0};
                CGFloat components[8] = { 1.0, 1.0, 1.0, 0.4,
                                  0.2, 0.2, 0.2, 0.2 };
                myGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations);
                
                
                CGPoint end = CGPointMake(centre.x + radius * cos(self.startAngle), centre.y + radius * sin(self.startAngle));
                CGContextDrawRadialGradient(context, myGradient, end, 0, end, lineThickness/2, 0);
                end = CGPointMake(centre.x + radius * cos(self.endAngle), centre.y + radius * sin(self.endAngle));
                CGContextDrawRadialGradient(context, myGradient, end, 0, end, lineThickness/2, 0);
                CGGradientRelease(myGradient);
            }
        }
        CGContextRestoreGState(context);

        
    }
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
}


- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)layerContext
{
    if (layer == self.foregroundLayer) {
        [self drawForegroundSegmentInContext:layerContext];
    } else if(layer == self.backgroundLayer) {
        [self drawBackgroundLayerInContext:layerContext];
    }
}

- (void)drawBackgroundLayerInContext:(CGContextRef)layerContext
{
    CGContextSaveGState(layerContext);
    {
        CGFloat lineThickness = MIN(self.backgroundLayer.bounds.size.width, self.backgroundLayer.bounds.size.height)/5;
        CGFloat shadowDepth = lineThickness * 0.5;
        
        CGPoint centre = CGPointMake(self.backgroundLayer.bounds.size.width / 2, self.backgroundLayer.bounds.size.height / 2);
        CGFloat radius = MIN(self.backgroundLayer.bounds.size.height, self.backgroundLayer.bounds.size.width) / 2 - lineThickness / 2;
        UIBezierPath *ring = [UIBezierPath bezierPathWithArcCenter:centre radius:radius startAngle:0 endAngle:M_PI*2 clockwise:YES];
        
        // Stroke the ring
        CGContextSaveGState(layerContext);
        CGFloat greyColour[4] = {0.3, 0.3, 0.3, 1.0};
        CGContextSetStrokeColor(layerContext, greyColour);
        CGContextAddPath(layerContext, ring.CGPath);
        CGContextSetLineWidth(layerContext, lineThickness);
        CGContextStrokePath(layerContext);
        CGContextRestoreGState(layerContext);
        
        
        // Inner shadow
        CGContextSaveGState(layerContext);
        UIBezierPath *mask = [UIBezierPath bezierPathWithArcCenter:centre radius:(radius - lineThickness/2) startAngle:0 endAngle:M_PI*2 clockwise:YES];
        
        CGRect boundingRect = CGRectMake(-2 * shadowDepth, -2 * shadowDepth, self.backgroundLayer.bounds.size.width + 4 * shadowDepth, self.backgroundLayer.bounds.size.height + 4 * shadowDepth);
        
        CGContextAddRect(layerContext, boundingRect);
        CGContextAddPath(layerContext, mask.CGPath);
        CGContextEOClip(layerContext);
        
        ring = [UIBezierPath bezierPathWithArcCenter:centre radius:(radius - lineThickness/2 - 2) startAngle:0 endAngle:M_PI*2 clockwise:YES];
        CGContextSetFillColorWithColor(layerContext, [UIColor blackColor].CGColor);
        CGContextAddPath(layerContext, ring.CGPath);
        CGContextSetShadowWithColor(layerContext, CGSizeMake(0, 0), shadowDepth, [UIColor blackColor].CGColor);
        CGContextSetBlendMode (layerContext, kCGBlendModeNormal);
        CGContextFillPath(layerContext);
        CGContextRestoreGState(layerContext);
        
        
        // Outer shadow
        CGContextSaveGState(layerContext);
        mask = [UIBezierPath bezierPathWithArcCenter:centre radius:(radius + lineThickness/2) startAngle:0 endAngle:M_PI*2 clockwise:YES];
        CGContextAddPath(layerContext, mask.CGPath);
        CGContextEOClip(layerContext);
        
        CGContextAddRect(layerContext, boundingRect);
        
        ring = [UIBezierPath bezierPathWithArcCenter:centre radius:(radius + lineThickness/2 + 2) startAngle:0 endAngle:M_PI*2 clockwise:YES];
        CGContextSetFillColorWithColor(layerContext, [UIColor blackColor].CGColor);
        CGContextAddPath(layerContext, ring.CGPath);
        CGContextSetShadowWithColor(layerContext, CGSizeMake(0, 0), shadowDepth, [UIColor blackColor].CGColor);
        CGContextSetBlendMode (layerContext, kCGBlendModeNormal);
        CGContextEOFillPath(layerContext);
        CGContextRestoreGState(layerContext);
        
        
    }
    CGContextRestoreGState(layerContext);
}

- (void)updateSegment
{
    CGFloat newRequestedAngle = ABS(self.endAngle - self.startAngle);
    CGFloat rotationRequired = self.startAngle;
    self.startAngle = 0;
    self.endAngle = newRequestedAngle;
    if(ABS(newRequestedAngle - currentSegmentAngle) > 0.01) {
        // So we've been asked for a new angle - we'll have to redraw
        [self.foregroundLayer setNeedsDisplay];
        // And make sure we save off the current segment angle for next time
        currentSegmentAngle = ABS(self.endAngle - self.startAngle);
    }
    
    // Now let's rotate the foreground layer
    // We wrap this in a transaction so we can disable the implicit animations
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    [self.foregroundLayer setAffineTransform:CGAffineTransformMakeRotation(rotationRequired)];
    [CATransaction commit];
}

@end
