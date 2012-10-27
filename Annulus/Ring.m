//
//  Ring.m
//  Annulus
//
//  Created by Sam Davies on 26/10/2012.
//  Copyright (c) 2012 VisualPutty. All rights reserved.
//

#import "Ring.h"

@implementation Ring

@synthesize startAngle = _startAngle;
@synthesize endAngle = _endAngle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self drawBackgroundAnnulusInRect:rect];
    [self drawForegroundSegmentInRect:rect];

}


- (void)drawForegroundSegmentInRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorSpaceRef colorSpace  = CGColorSpaceCreateDeviceRGB();
    
    CGContextSaveGState(context);
    {
        CGFloat bigLineThickness = MIN(rect.size.width,rect.size.height)/5; // NB: copy/pasted from other method
        CGFloat lineThickness = bigLineThickness - 4;
        
        CGPoint centre = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        CGFloat radius = MIN(self.bounds.size.height, self.bounds.size.width) / 2 - bigLineThickness / 2;
        UIBezierPath *segment = [UIBezierPath bezierPathWithArcCenter:centre radius:radius startAngle:self.startAngle endAngle:self.endAngle clockwise:YES];
        
        CGContextSaveGState(context);
        {
            // Drop into core graphics
            CGContextAddPath(context, segment.CGPath);
            CGContextSetLineWidth(context, lineThickness);
            CGContextSetLineCap(context, kCGLineCapRound);
            
            // Let's change it from a single line to an outline
            CGContextReplacePathWithStrokedPath(context);
            
            [[UIColor colorWithRed:0.1 green:0.6 blue:0.9 alpha:1] set];
            
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
            
            CGContextAddRect(context, rect);
            
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


- (void)drawBackgroundAnnulusInRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    {
        CGFloat lineThickness = MIN(rect.size.width,rect.size.height)/5;
        CGFloat shadowDepth = lineThickness * 0.5;
        
        CGPoint centre = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        CGFloat radius = MIN(self.bounds.size.height, self.bounds.size.width) / 2 - lineThickness / 2;
        UIBezierPath *ring = [UIBezierPath bezierPathWithArcCenter:centre radius:radius startAngle:0 endAngle:M_PI*2 clockwise:YES];
        
        [[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1] set];
        
        ring.lineWidth = lineThickness;
        
        [ring stroke];
        
        
        // Inner shadow
        CGContextSaveGState(context);
        UIBezierPath *mask = [UIBezierPath bezierPathWithArcCenter:centre radius:(radius - lineThickness/2) startAngle:0 endAngle:M_PI*2 clockwise:YES];
        
        CGRect boundingRect = CGRectMake(-2 * shadowDepth, -2 * shadowDepth, rect.size.width + 4 * shadowDepth, rect.size.height + 4 * shadowDepth);
        
        CGContextAddRect(context, boundingRect);
        CGContextAddPath(context, mask.CGPath);
        CGContextEOClip(context);
        
        ring = [UIBezierPath bezierPathWithArcCenter:centre radius:(radius - lineThickness/2 - 2) startAngle:0 endAngle:M_PI*2 clockwise:YES];
        [[UIColor blackColor] setFill];
        CGContextAddPath(context, ring.CGPath);
        CGContextSetShadowWithColor(context, CGSizeMake(0, 0), shadowDepth, [UIColor blackColor].CGColor);
        CGContextSetBlendMode (context, kCGBlendModeNormal);
        CGContextFillPath(context);
        CGContextRestoreGState(context);
        
        
        // Outer shadow
        CGContextSaveGState(context);
        mask = [UIBezierPath bezierPathWithArcCenter:centre radius:(radius + lineThickness/2) startAngle:0 endAngle:M_PI*2 clockwise:YES];
        CGContextAddPath(context, mask.CGPath);
        CGContextEOClip(context);
        
        CGContextAddRect(context, boundingRect);
        
        ring = [UIBezierPath bezierPathWithArcCenter:centre radius:(radius + lineThickness/2 + 2) startAngle:0 endAngle:M_PI*2 clockwise:YES];
        [[UIColor blackColor] setFill];
        CGContextAddPath(context, ring.CGPath);
        CGContextSetShadowWithColor(context, CGSizeMake(0, 0), shadowDepth, [UIColor blackColor].CGColor);
        CGContextSetBlendMode (context, kCGBlendModeNormal);
        CGContextEOFillPath(context);
        CGContextRestoreGState(context);
        
        
    }
    CGContextRestoreGState(context);
}


@end
