//
//  ViewController.m
//  TDSignatureViewDemo
//
//  Created by Jahid Hassan on 12/11/14.
//  Copyright (c) 2014 Jahid Hassan. All rights reserved.
//

#import "ViewController.h"
#import "TDSignatureView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    TDSignatureView *signatureView = [[TDSignatureView alloc] initWithFrame:CGRectMake(432, 425, 160, 120)];
    signatureView.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:signatureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
