//
//  TDSignatureView.m
//  Trinity Developers
//
//  Created by Jahid Hassan on 4/1/13.
//  Copyright (c) 2013 Jahid Hassan. All rights reserved.
//

#import "TDSignatureView.h"

@interface TDSignatureField() {CGPoint controlPoints[5];}
@property (nonatomic, TD_STRONG) UIBezierPath *_bezierPath;
@property (atomic, assign) uint pointCounter;
@property (nonatomic, TD_STRONG) UIColor *fieldBackground;

- (void)doCanvasReset;
- (void)closeCanvas;

@end

@implementation TDSignatureView
@synthesize overlayView;
@synthesize signatureField;
@synthesize inBounds;

- (id)init
{
    self = [super init];
    if (self) {
        [self setPreferences];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setPreferences];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setPreferences];
    }
    return self;
}

- (void)setPreferences
{
    [self setUserInteractionEnabled:YES];
    [self setMultipleTouchEnabled:NO];
    
    [self registerForNotifications];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performTapAction:)];
    tapGesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGesture];
}

- (void)loadView
{
    if(!overlayView) {
        overlayView = [UIView new];
        [overlayView setBackgroundColor:[UIColor blackColor]];
        [overlayView setOpaque:YES];
    }
    
    if(!signatureField) {
        signatureField = [TDSignatureField new];
        [signatureField setBackgroundColor:self.backgroundColor];
        [signatureField setOpaque:YES];
    }
    
    [signatureField setFrame:self.frame];
    [overlayView setFrame:inBounds];
    [overlayView setAlpha:0.0];
    [[[[UIApplication sharedApplication] windows] lastObject] addSubview:overlayView];
    
    [[[[UIApplication sharedApplication] windows] lastObject] addSubview:signatureField];
    [UIView animateWithDuration:0.25
                     animations:^{
                         [signatureField setFrame:[self getFieldRect]];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.25
                                          animations:^{
                                              [overlayView setAlpha:0.8];
                                          }
                                          completion:^(BOOL finished) {
                                              [self drawComponentes];
                                          }];
                     }];
    
}

NSInteger tagClose;
- (void)drawComponentes
{
    tagClose = 33112;
    [[signatureField viewWithTag:tagClose] removeFromSuperview];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"Close" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(signatureField.bounds.size.width-80, 0.0f, 80, 30)];
    [cancelButton addTarget:self action:@selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTag:tagClose];
    [signatureField addSubview:cancelButton];
}

- (void)performTapAction:(UITapGestureRecognizer *)gestureRecognizer
{
    [self loadView];
}

- (CGRect)getFieldRect
{
    CGFloat margin = 50.f;
    CGFloat height = inBounds.size.height * (self.bounds.size.height/self.bounds.size.width);
    
    return CGRectMake(margin, (inBounds.size.height-height)/2, inBounds.size.width - 2*margin, height);
}

- (void)closeView: (UIButton *)sender
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         [overlayView setAlpha:0.0];
                         for(id v in signatureField.subviews) [v removeFromSuperview];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.25
                                          animations:^{
                                            [signatureField setFrame:self.frame];
                                          }
                                          completion:^(BOOL finished) {
                                              [overlayView removeFromSuperview];
                                              [signatureField removeFromSuperview];
                                              [self setPreview];
                                          }];
                     }];
}

- (void)setPreview
{
    static NSInteger PREVIEW_TAG = 6671101;
    UIGraphicsBeginImageContext(self.bounds.size);
    [signatureField.image drawInRect:self.bounds];
    UIImageView *imgview = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];
    UIGraphicsEndImageContext();
    imgview.tag = PREVIEW_TAG;
    [[self viewWithTag:PREVIEW_TAG] removeFromSuperview];
    [self addSubview:imgview];
}

#pragma mark - Notifications
- (void)registerForNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(deviceOrientationDidChange:)
               name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)unregisterFromNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    inBounds = [[[UIApplication sharedApplication] keyWindow] bounds];
    [self setTransformForCurrentOrientation:YES];
   
}

- (void)setTransformForCurrentOrientation:(BOOL)animated
{
    NSLog(@"Frame : %@", NSStringFromCGRect(self.bounds));
    
    // Stay in sync with the superview
    if (overlayView) {
        [overlayView setFrame:inBounds];
        [overlayView setNeedsDisplay];
        
        [signatureField setFrame:[self getFieldRect]];
        [signatureField setNeedsDisplay];
        [[signatureField viewWithTag:tagClose] setFrame:CGRectMake(signatureField.bounds.size.width-80, 0.0f, 80, 30)];
        
        [self setNeedsDisplay];
    }
}

- (void)dealloc
{
    [self unregisterFromNotifications];
#if !__has_feature(objc_arc)
    [overlayView release];
    [signatureField release];
#if NS_BLOCKS_AVAILABLE
    //
#endif
    [super dealloc];
#endif
}

@end

@implementation TDSignatureField
{
    UIImage *imgRaw;
}
@synthesize _bezierPath;
@synthesize fieldBackground;
@synthesize pointCounter;

- (id)init
{
    self = [super init];
    if (self) {
        [self setPreferences];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setPreferences];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setPreferences];
    }
    return self;
}

- (void)setPreferences
{
    [self setUserInteractionEnabled:YES];
    [self setMultipleTouchEnabled:NO];
    
    _bezierPath = [UIBezierPath bezierPath];
    [_bezierPath setLineWidth:2.0];
}

#pragma mark -
#pragma mark DRAWING CODE
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
        
        [self drawLineSegmentImage];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setNeedsDisplay];
    [_bezierPath removeAllPoints];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)drawLineSegmentImage
{
    if(!fieldBackground) {
        [self setFieldBackground:self.backgroundColor];
    }
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    if (!imgRaw){
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
        [fieldBackground setFill];
        [rectpath fill];
    }
    [imgRaw drawAtPoint:CGPointZero];
    [[UIColor blackColor] setStroke];
    [_bezierPath stroke];
    imgRaw = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self setImage:imgRaw];
    pointCounter = 0;
}

- (void)doCanvasReset
{
    imgRaw = nil;
    [self setImage:imgRaw];
}

- (UIImage *)image
{
    return imgRaw;
}

@end
