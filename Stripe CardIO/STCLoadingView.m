//
//  STRLoadingView.m
//  StripeDemo
//
//  Created by Red Davis on 25/08/2012.
//  Copyright (c) 2012 Red Davis. All rights reserved.
//

#import "STCLoadingView.h"


@interface STCLoadingView ()

@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end


@implementation STCLoadingView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:self.spinner];
        [self.spinner startAnimating];
    }
    
    return self;
}

#pragma mark - View Setup

- (void)layoutSubviews {
    
//    self.spinner.frame = CGRectMake(floorf(self.frame.size.width/2), floorf(self.frame.size.height/2), 10, 10);
    self.spinner.center = self.center;
}

@end
