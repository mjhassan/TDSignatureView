//
//  TDSignatureView.h
//  Trinity Developers
//
//  Created by Jahid Hassan on 4/1/13.
//  Copyright (c) 2013 Jahid Hassan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@protocol TDSignatureDelegate;

//typedef NS_OPTIONS(NSUInteger, <#_name#>) <#new#>;

#ifndef TD_INSTANCETYPE
#if __has_feature(objc_instancetype)
#define TD_INSTANCETYPE instancetype
#else
#define TD_INSTANCETYPE id
#endif
#endif

#ifndef TD_STRONG
#if __has_feature(objc_arc)
#define TD_STRONG strong
#else
#define TD_STRONG retain
#endif
#endif

#ifndef TD_WEAK
#if __has_feature(objc_arc_weak)
#define TD_WEAK weak
#elif __has_feature(objc_arc)
#define TD_WEAK unsafe_unretained
#else
#define TD_WEAK assign
#endif
#endif

@interface TDSignatureField : UIImageView
- (id)init;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (id)initWithFrame:(CGRect)frame;
- (UIImage *)getDrawingImage;
@end

@interface TDSignatureView : UIView
@property (atomic, TD_STRONG) UIView *overlayView;
@property (atomic, TD_STRONG) TDSignatureField *signatureField;
@property (atomic, assign) CGRect inBounds;
@end
