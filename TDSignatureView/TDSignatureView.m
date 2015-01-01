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
@property (atomic, assign) BOOL hasEdited;

- (void)doCanvasReset;
- (void)closeCanvas;
- (void)doLayoutRefresh;

@end

@implementation TDSignatureView { NSUserDefaults *userPreferences;}
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
    userPreferences = [NSUserDefaults standardUserDefaults];
    
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
        [signatureField setAutoresizesSubviews:YES];
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

- (void)drawComponentes
{
    for(id sv in signatureField.subviews) [sv removeFromSuperview];
    
    CGFloat alpha = 0.6f;
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, signatureField.bounds.size.width, 40)];
    [topView setBackgroundColor:[UIColor blackColor]];
    [topView setAlpha:alpha];
    [signatureField addSubview:topView];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"Close" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(signatureField.bounds.size.width-83, 5.0f, 80, 30)];
    [cancelButton.layer setBorderWidth:1.f];
    [cancelButton.layer setBorderColor:self.backgroundColor.CGColor];
    [cancelButton.layer setCornerRadius:5.f];
    [cancelButton addTarget:self action:@selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
    [signatureField addSubview:cancelButton];
    
    
    CGFloat xOrigin = signatureField.bounds.size.width-83.f, yOrigin = signatureField.bounds.size.height-40.f;
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, yOrigin, signatureField.bounds.size.width, 40)];
    [bottomView setBackgroundColor:[UIColor blackColor]];
    [bottomView setAlpha:alpha];
    [signatureField addSubview:bottomView];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [doneButton setFrame:CGRectMake(xOrigin, yOrigin+5.f, 80, 30)];
    [doneButton.layer setBorderWidth:1.f];
    [doneButton.layer setBorderColor:self.backgroundColor.CGColor];
    [doneButton.layer setCornerRadius:5.f];
    [doneButton addTarget:self action:@selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
    [signatureField addSubview:doneButton];
    xOrigin -= doneButton.bounds.size.width+10.f;
    
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [resetButton setTitle:@"Reset" forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [resetButton setFrame:CGRectMake(xOrigin, yOrigin+5.f, 80, 30)];
    [resetButton.layer setBorderWidth:1.f];
    [resetButton.layer setBorderColor:self.backgroundColor.CGColor];
    [resetButton.layer setCornerRadius:5.f];
    [resetButton addTarget:signatureField action:@selector(doCanvasReset) forControlEvents:UIControlEventTouchUpInside];
    [signatureField addSubview:resetButton];
    xOrigin -= doneButton.bounds.size.width+10.f;
    
    
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButton setImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
    [settingsButton setFrame:CGRectMake(5.f, yOrigin+5.f, 30.f, 30.f)];
    [settingsButton addTarget:self action:@selector(showSettings:) forControlEvents:UIControlEventTouchUpInside];
    [signatureField addSubview:settingsButton];
    
    UIButton *storeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [storeButton setTitle:@"Preview" forState:UIControlStateNormal];
    [storeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [storeButton setFrame:CGRectMake(settingsButton.frame.origin.x+ settingsButton.frame.size.width+10.f, yOrigin+5.f, 80.f, 30.f)];
    [storeButton.layer setBorderWidth:1.f];
    [storeButton.layer setBorderColor:self.backgroundColor.CGColor];
    [storeButton.layer setCornerRadius:5.f];
    [storeButton addTarget:self action:@selector(showSettings:) forControlEvents:UIControlEventTouchUpInside];
    [signatureField addSubview:storeButton];
}

- (void)performTapAction:(UITapGestureRecognizer *)gestureRecognizer
{
    [self loadView];
}

- (CGRect)getFieldRect
{
    CGFloat margin = 50.f;
    CGFloat width  = (inBounds.size.width-2*margin);
    CGFloat factor = width / self.bounds.size.width;
    CGFloat height = self.bounds.size.height * factor;
    
    return CGRectMake(margin, (inBounds.size.height-height)/2, width, height);
}

static NSInteger CLOSE_TAG = 1u << 8;
static NSInteger SAVE_TAG = 1u << 16;
- (void)closeView: (UIButton *)sender
{
    if ([(NSString *)[sender titleForState:UIControlStateNormal] caseInsensitiveCompare:@"CLOSE"] == NSOrderedSame) {
        if (signatureField.hasEdited) {
            UIAlertView *closeAlert = [[UIAlertView alloc] initWithTitle:@"WARNING!" message:@"Closing action will lose signature. Do you really want to continue?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
            [closeAlert setTag:CLOSE_TAG];
            [closeAlert show];
        }else [self closeActionWithPreview:NO];
    }else if ([(NSString *)[sender titleForState:UIControlStateNormal] caseInsensitiveCompare:@"DONE"] == NSOrderedSame)
    {
        [userPreferences setObject:@0 forKey:@"SaveAskPreference"];
        if(![[userPreferences objectForKey:@"SaveAskPreference"] boolValue]) {
        UIAlertView *closeAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Do you want to save this signature?\nWARNING: Do not save signature if you are on shared device." delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"OK", nil];
        
        UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 40)];
        [accessoryView setBackgroundColor:[UIColor clearColor]];
        UIButton *checkBoxButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 5.0, 30.0, 30.0)];
        [checkBoxButton setImage:[UIImage imageNamed:@"fancyUnchecked"] forState:UIControlStateNormal];
        [checkBoxButton setImage:[UIImage imageNamed:@"fancyUnchecked"] forState:UIControlStateHighlighted];
        [checkBoxButton setImage:[UIImage imageNamed:@"fancyChecked"] forState:UIControlStateSelected];
        [checkBoxButton addTarget:self action:@selector(savePreferences:) forControlEvents:UIControlEventTouchUpInside];
        [accessoryView addSubview:checkBoxButton];
        UILabel *declaimer = [[UILabel alloc] initWithFrame:CGRectMake(30.f, 0, 220.f, 40)];
        [declaimer setBackgroundColor:[UIColor clearColor]];
        [declaimer setText:@"Don't show this message."];
        [declaimer setFont:[UIFont systemFontOfSize:10.f]];
        [accessoryView addSubview:declaimer];
        [closeAlert setValue:accessoryView  forKey:@"accessoryView"];
        
        [closeAlert setTag:SAVE_TAG];
        [closeAlert show];
        } else {
            [self closeActionWithPreview:YES];
        }
        
    }
}

- (void)closeActionWithPreview:(BOOL)hasPreview
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
                                              if(!hasPreview) [signatureField doCanvasReset];
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
    imgview.backgroundColor = [UIColor yellowColor];
    UIGraphicsEndImageContext();
    imgview.tag = PREVIEW_TAG;
    [[self viewWithTag:PREVIEW_TAG] removeFromSuperview];
    [self addSubview:imgview];
    
    if (signatureField.image && [[userPreferences objectForKey:@"SavePreference"] boolValue]) {
        [self saveSignatures];
    }
}

- (void)savePreferences:(UIButton *)sender
{
    sender.selected = !sender.isSelected;
    
    CGRect _frame = sender.frame;
    if (sender.isSelected) {
        _frame.origin.x += 2;
        _frame.origin.y -= 2;
    }else {
        _frame.origin.x -= 2;
        _frame.origin.y += 2;
    }
    [sender setFrame:_frame];
    
    [userPreferences setObject:@(sender.isSelected) forKey:@"SaveAskPreference"];
    [userPreferences synchronize];
}

- (void)saveSignatures
{
    NSLog(@"Saving Signature");
}

- (void)showSettings:(UIButton *)sender
{
    NSLog(@"Showing settings");
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
    // Stay in sync with the superview
    if (overlayView) {
        [overlayView setFrame:inBounds];
        [overlayView setNeedsDisplay];
        
        [signatureField setFrame:[self getFieldRect]];
        [signatureField setNeedsDisplay];
        [self drawComponentes];
        [signatureField doLayoutRefresh];
        [self setNeedsDisplay];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == CLOSE_TAG && buttonIndex == 1) {
        [self closeActionWithPreview:NO];
    }else if (alertView.tag == SAVE_TAG) {
        [userPreferences setObject:@(buttonIndex) forKey:@"SavePreference"];
        [userPreferences synchronize];
        [self closeActionWithPreview:YES];
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

#pragma mark -
#pragma mark -

@implementation TDSignatureField
{
    UIImage *imgRaw;
}
@synthesize _bezierPath;
@synthesize fieldBackground;
@synthesize pointCounter;
@synthesize hasEdited;

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
    hasEdited = YES;
}

- (void)doCanvasReset
{
    imgRaw = nil;
    [self setImage:imgRaw];
    hasEdited = NO;
}

- (void)doLayoutRefresh
{
    if(!imgRaw) return;
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    [imgRaw drawInRect:self.bounds];
    imgRaw = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setImage:imgRaw];
}

- (UIImage *)image
{
    return imgRaw;
}

@end
