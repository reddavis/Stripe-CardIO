//
//  STCChargesViewController.m
//  Stripe CardIO
//
//  Created by Red Davis on 27/08/2012.
//  Copyright (c) 2012 Red Davis. All rights reserved.
//

#import "STCChargesViewController.h"
#import "STCAddChargeViewController.h"
#import "STRStripeHTTPClient.h"
#import "STCLoadingView.h"
#import "STRCharge.h"


@interface STCChargesViewController ()

@property (strong, nonatomic) NSArray *charges;

- (void)addChargeButtonTapped:(id)sender;
- (void)refreshButtonTapped:(id)sender;
- (void)fetchCharges;

@end


@implementation STCChargesViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"Charges";
    
    self.charges = [NSArray array];
    
    UIBarButtonItem *addChargeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addChargeButtonTapped:)];
    self.navigationItem.rightBarButtonItem = addChargeButton;
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonTapped:)];
    self.navigationItem.leftBarButtonItem = refreshButton;
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self fetchCharges];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -

- (void)fetchCharges {
    
    self.charges = [NSArray array];
    [self.tableView reloadData];
    self.tableView.scrollEnabled = NO;
    
    STCLoadingView *loadingView = [[STCLoadingView alloc] initWithFrame:self.tableView.frame];
    [self.tableView addSubview:loadingView];
    
    STRStripeHTTPClient *client = [STRStripeHTTPClient sharedClient];
    [client fetchAllCharges:^(NSArray *charges) {
        
        self.charges = charges;
        [self.tableView reloadData];
        self.tableView.scrollEnabled = YES;
        [loadingView removeFromSuperview];
    } failure:^(NSError *error) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Loading Charges" message:[NSString stringWithFormat:@"%@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [loadingView removeFromSuperview];
        
        self.tableView.scrollEnabled = YES;
    }];
}

#pragma mark - Actions

- (void)refreshButtonTapped:(id)sender {
    
    [self fetchCharges];
}

- (void)addChargeButtonTapped:(id)sender {
    
    STCAddChargeViewController *addChargeViewController = [[STCAddChargeViewController alloc] initWithNibName:@"STCAddChargeViewController" bundle:nil];
    UINavigationController *addChargeNavigationController = [[UINavigationController alloc] initWithRootViewController:addChargeViewController];
    [self.navigationController presentModalViewController:addChargeNavigationController animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.charges.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    STRCharge *charge = [self.charges objectAtIndex:indexPath.row];
    
    NSString *labelText = charge.details;
    if (!labelText) {
        labelText = @"No Description";
    }
    
    if (charge.refunded) {
        labelText = [labelText stringByAppendingString:@" (refunded)"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = labelText;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %.2f", charge.currency, charge.amount.floatValue/100];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STRCharge *charge = [self.charges objectAtIndex:indexPath.row];
    return !charge.refunded;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STRCharge *charge = [self.charges objectAtIndex:indexPath.row];
    STRStripeHTTPClient *client = [STRStripeHTTPClient sharedClient];
    [client refundCharge:charge success:^(STRCharge *charge) {
        
        NSMutableArray *mutableChargesArray = [NSMutableArray arrayWithArray:self.charges];
        [mutableChargesArray replaceObjectAtIndex:indexPath.row withObject:charge];
        self.charges = [NSArray arrayWithArray:mutableChargesArray];
        
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } failure:^(NSError *error) {
        
        NSLog(@"%@", error);
    }];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return @"Refund";
}

@end
