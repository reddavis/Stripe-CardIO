//
//  STCAddChargeViewController.h
//  Stripe CardIO
//
//  Created by Red Davis on 27/08/2012.
//  Copyright (c) 2012 Red Davis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardIO.h"


@interface STCAddChargeViewController : UIViewController <CardIOPaymentViewControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UIButton *scanCardButton;
@property (weak, nonatomic) IBOutlet UILabel *loadingTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;

- (IBAction)scanCardButtonTapped:(id)sender;

@end
