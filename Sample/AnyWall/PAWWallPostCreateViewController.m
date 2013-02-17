//
//  PAWWallPostCreateViewController.m
//  AnyWall
//
//  Created by Christopher Bowns on 1/31/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "PAWWallPostCreateViewController.h"

#import "PAWAppDelegate.h"
#import <Parse/Parse.h>

@interface PAWWallPostCreateViewController ()

- (void)updateCharacterCount:(UITextView *)aTextView;
- (BOOL)checkCharacterCount:(UITextView *)aTextView;
- (void)textInputChanged:(NSNotification *)note;

@end

@implementation PAWWallPostCreateViewController

@synthesize textView;
@synthesize characterCount;
@synthesize postButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextViewTextDidChangeNotification object:textView];
	[self updateCharacterCount:textView];
	[self checkCharacterCount:textView];

	// Show the keyboard/accept input.
	[textView becomeFirstResponder];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:textView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:textView];
}

#pragma mark UINavigationBar-based actions

- (IBAction)cancelPost:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)postPost:(id)sender {
	// Resign first responder to dismiss the keyboard and capture in-flight autocorrect suggestions
	[textView resignFirstResponder];

	// Capture current text field contents:
	[self updateCharacterCount:textView];
	BOOL isAcceptableAfterAutocorrect = [self checkCharacterCount:textView];

	if (!isAcceptableAfterAutocorrect) {
		[textView becomeFirstResponder];
		return;
	}

	// Data prep:
	PAWAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	CLLocationCoordinate2D currentCoordinate = appDelegate.currentLocation.coordinate;
	PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude longitude:currentCoordinate.longitude];
	PFUser *user = [PFUser currentUser];

	// Stitch together a postObject and send this async to Parse
	PFObject *postObject = [PFObject objectWithClassName:kPAWParsePostsClassKey];
	[postObject setObject:textView.text forKey:kPAWParseTextKey];
	[postObject setObject:user forKey:kPAWParseUserKey];
	[postObject setObject:currentPoint forKey:kPAWParseLocationKey];
	// Use PFACL to restrict future modifications to this object.
	PFACL *readOnlyACL = [PFACL ACL];
	[readOnlyACL setPublicReadAccess:YES];
	[readOnlyACL setPublicWriteAccess:NO];
	[postObject setACL:readOnlyACL];
	[postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		if (error) {
			NSLog(@"Couldn't save!");
			NSLog(@"%@", error);
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			[alertView show];
			return;
		}
		if (succeeded) {
			NSLog(@"Successfully saved!");
			NSLog(@"%@", postObject);
			dispatch_async(dispatch_get_main_queue(), ^{
				[[NSNotificationCenter defaultCenter] postNotificationName:kPAWPostCreatedNotification object:nil];
			});
		} else {
			NSLog(@"Failed to save.");
		}
	}];

	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark UITextView notification methods

- (void)textInputChanged:(NSNotification *)note {
	// Listen to the current text field and count characters.
	UITextView *localTextView = [note object];
	[self updateCharacterCount:localTextView];
	[self checkCharacterCount:localTextView];
}

#pragma mark Private helper methods

- (void)updateCharacterCount:(UITextView *)aTextView {
	NSUInteger count = aTextView.text.length;
	characterCount.text = [NSString stringWithFormat:@"%i/140", count];
	if (count > kPAWWallPostMaximumCharacterCount || count == 0) {
		characterCount.font = [UIFont boldSystemFontOfSize:characterCount.font.pointSize];
	} else {
		characterCount.font = [UIFont systemFontOfSize:characterCount.font.pointSize];
	}
}

- (BOOL)checkCharacterCount:(UITextView *)aTextView {
	NSUInteger count = aTextView.text.length;
	if (count > kPAWWallPostMaximumCharacterCount || count == 0) {
		postButton.enabled = NO;
		return NO;
	} else {
		postButton.enabled = YES;
		return YES;
	}
}

@end
