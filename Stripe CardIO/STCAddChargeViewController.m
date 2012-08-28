//
//  STCAddChargeViewController.m
//  Stripe CardIO
//
//  Created by Red Davis on 27/08/2012.
//  Copyright (c) 2012 Red Davis. All rights reserved.
//

#import "STCAddChargeViewController.h"
#import "STRStripeHTTPClient.h"


@interface STCAddChargeViewController ()

@property (copy, nonatomic) NSString *cardIOKey;

@end


@implementation STCAddChargeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"Create Charge";
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self.navigationController action:@selector(dismissModalViewControllerAnimated:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    NSURL *cardIOKeyURL = [[NSBundle mainBundle] URLForResource:@"CardIOKey" withExtension:nil];
    NSError *readingKeyError = nil;
    NSString *cardIOKey = [NSString stringWithContentsOfURL:cardIOKeyURL encoding:NSUTF8StringEncoding error:&readingKeyError];
    
    if (readingKeyError) {
        NSLog(@"Error reading CardIO Key %@", readingKeyError);
    }
    else {
        self.cardIOKey = cardIOKey;
    }

}

- (void)viewDidUnload {
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.loadingSpinner.hidden = YES;
    
    [self.amountTextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (void)scanCardButtonTapped:(id)sender {
    
    [self.view endEditing:YES];
    
    CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    scanViewController.appToken = self.cardIOKey;
    [self presentModalViewController:scanViewController animated:YES];
}

#pragma mark - CardIOPaymentViewControllerDelegate

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
            
    NSMutableDictionary *cardDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:info.cardNumber, @"number", [NSNumber numberWithInteger:info.expiryMonth], @"exp_month", [NSNumber numberWithInteger:info.expiryYear], @"exp_year", nil];
    
    if (info.cvv) {
        [cardDictionary setObject:info.cvv forKey:@"cvc"];
    }
    
    NSNumber *amount = [NSNumber numberWithFloat:self.amountTextField.text.floatValue*100];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:amount, @"amount", @"usd", @"currency", cardDictionary, @"card", nil];
    
    if (self.descriptionTextField.text) {
        [params setObject:self.descriptionTextField.text forKey:@"description"];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
        self.amountTextField.enabled = NO;
        self.scanCardButton.enabled = NO;
        self.loadingTextField.hidden = NO;
        self.loadingSpinner.hidden = NO;
        [self.loadingSpinner startAnimating];

        STRStripeHTTPClient *client = [STRStripeHTTPClient sharedClient];
        [client createCharge:amount params:params success:^(STRCharge *charge) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"A charge was created" delegate:nil cancelButtonTitle:@"Cool!" otherButtonTitles:nil];
            
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
               [alert show];
            }];
        } failure:^(NSError *error) {
            
            self.amountTextField.enabled = YES;
            self.scanCardButton.enabled = YES;
            self.loadingTextField.hidden = YES;
            self.loadingSpinner.hidden = YES;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

@end
