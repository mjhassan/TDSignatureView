//
//  TDSignatureView.h
//  Trinity Developers
//
//  Created by Jahid Hassan on 4/1/13.
//  Copyright (c) 2013 Jahid Hassan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDSignatureView : UIView{
    UIBezierPath *_bezierPath;
    CGPoint controlPoints[5];
    uint pointCounter;
}
@property (nonatomic) UIColor *_predefinedColor;
@property (strong, nonatomic)  UIImage *temporaryImage;

- (UIImage *)getDrawingImage;

@end
