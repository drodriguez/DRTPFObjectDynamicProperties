//
//  PAWViewController.m
//  AnyWall
//
//  Created by Christopher Bowns on 1/30/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "PAWWelcomeViewController.h"

#import "PAWWallViewController.h"
#import "PAWLoginViewController.h"
#import "PAWNewUserViewController.h"

@implementation PAWWelcomeViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Transition methods

- (IBAction)loginButtonSelected:(id)sender {
	PAWLoginViewController *loginViewController = [[PAWLoginViewController alloc] initWithNibName:nil bundle:nil];
	[self.navigationController presentViewController:loginViewController animated:YES completion:^{}];
}

- (IBAction)createButtonSelected:(id)sender {
	PAWNewUserViewController *newUserViewController = [[PAWNewUserViewController alloc] initWithNibName:nil bundle:nil];
	[self.navigationController presentViewController:newUserViewController animated:YES completion:^{}];
}

- (IBAction)gotoParse:(id)sender {
	UIApplication *ourApplication = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:@"https://www.parse.com/"];
    [ourApplication openURL:url];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
