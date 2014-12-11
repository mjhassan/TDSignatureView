//
//  TDSignatureView.m
//  Trinity Developers
//
//  Created by Jahid Hassan on 4/1/13.
//  Copyright (c) 2013 Jahid Hassan. All rights reserved.
//

#import "TDSignatureView.h"

@implementation TDSignatureView
@synthesize temporaryImage=_temporaryImage;

- (id)init
{
    self = [super init];
    if (self) {
        [self setMultipleTouchEnabled:NO];
        [self set_predefinedColor:self.backgroundColor];
        _bezierPath = [UIBezierPath bezierPath];
        [_bezierPath setLineWidth:2.0];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setMultipleTouchEnabled:NO];
        [self set_predefinedColor:self.backgroundColor];
        _bezierPath = [UIBezierPath bezierPath];
        [_bezierPath setLineWidth:2.0];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setMultipleTouchEnabled:NO];
        [self set_predefinedColor:[UIColor whiteColor]];
        [self setBackgroundColor:self._predefinedColor];
        _bezierPath = [UIBezierPath bezierPath];
        [_bezierPath setLineWidth:2.0];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self drawCleanButton];
    [self.temporaryImage drawInRect:rect];
    [_bezierPath stroke];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    controlPoints[pointCounter = 0] = [[touches anyObject] locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    controlPoints[++pointCounter] = [[touches anyObject] locationInView:self];
    if (pointCounter == 4) {
        controlPoints[3] = CGPointMake((controlPoints[2].x + controlPoints[4].x) / 2.0, (controlPoints[2].y + controlPoints[4].y) / 2.0);
        [_bezierPath moveToPoint:controlPoints[0]];
        [_bezierPath addCurveToPoint:controlPoints[3]
                       controlPoint1:controlPoints[1]
                       controlPoint2:controlPoints[2]
         ];
        [self setNeedsDisplay];
        controlPoints[0] = controlPoints[3];
        controlPoints[1] = controlPoints[4];
        pointCounter = 1;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self drawLineSegmentImage];
    [self setNeedsDisplay];
    [_bezierPath removeAllPoints];
     pointCounter = 0;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)drawLineSegmentImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    if (!self.temporaryImage){
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
        [self._predefinedColor setFill];
        [rectpath fill];
    }
    [self.temporaryImage drawAtPoint:CGPointZero];
    [[UIColor blackColor] setStroke];
    [_bezierPath stroke];
    self.temporaryImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)cancelButtonPressed: (UIButton *)sender
{
    [self resetImage];
    [self setNeedsDisplay];
}

- (void)drawCleanButton
{
    UIImage *image = [UIImage imageNamed:@"cancel.png"];
    CGFloat buttonSize = image.size.width;
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(self.bounds.size.width-buttonSize, 0.0f, buttonSize, buttonSize);
    [cancelButton setImage:image forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];
}

- (void)resetImage {
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, self.window.screen.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
    CGContextFillRect(context, self.bounds);
    self.temporaryImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
}

- (UIImage *)getDrawingImage
{
    return self.temporaryImage;
}

@end
