//
//  PAWSettingsViewController.m
//  AnyWall
//
//  Created by Christopher Bowns on 1/30/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import "PAWSettingsViewController.h"

#import "PAWAppDelegate.h"
#import <Parse/Parse.h>

@interface PAWSettingsViewController ()

- (NSString *)distanceLabelForCell:(NSIndexPath *)indexPath;
- (PAWLocationAccuracy)distanceForCell:(NSIndexPath *)indexPath;

@property (nonatomic, assign) CLLocationAccuracy filterDistance;

@end

// UITableView enum-based configuration via Fraser Speirs: http://speirs.org/blog/2008/10/11/a-technique-for-using-uitableview-and-retaining-your-sanity.html
typedef enum {
	kPAWSettingsTableViewDistance = 0,
	kPAWSettingsTableViewLogout,
	kPAWSettingsTableViewNumberOfSections
} kPAWSettingsTableViewSections;

typedef enum {
	kPAWSettingsLogoutDialogLogout = 0,
	kPAWSettingsLogoutDialogCancel,
	kPAWSettingsLogoutDialogNumberOfButtons
} kPAWSettingsLogoutDialogButtons;

static uint16_t const kPAWSettingsTableViewDistanceNumberOfRows = 2;
static uint16_t const kPAWSettingsTableViewLogoutNumberOfRows = 1;

@implementation PAWSettingsViewController

@synthesize tableView;
@synthesize filterDistance;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		PAWAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		self.filterDistance = appDelegate.filterDistance;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Custom setters

// Always fault our filter distance through to the app delegate. We just cache it locally because it's used in the tableview's cells.
- (void)setFilterDistance:(CLLocationAccuracy)aFilterDistance {
	PAWAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	appDelegate.filterDistance = aFilterDistance;
	filterDistance = aFilterDistance;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Private helper methods

- (NSString *)distanceLabelForCell:(NSIndexPath *)indexPath {
	NSString *cellText = nil;
	switch (indexPath.row) {
		case 0:
			cellText = @"250 feet";
			break;
		case 1:
			cellText = @"1000 feet";
			break;
		case kPAWSettingsTableViewDistanceNumberOfRows: // never reached.
		default:
			cellText = @"The universe";
			break;
	}
	return cellText;
}

- (PAWLocationAccuracy)distanceForCell:(NSIndexPath *)indexPath {
	PAWLocationAccuracy distance = 0.0;
	switch (indexPath.row) {
		case 0:
			distance = 250;
			break;
		case 1:
			distance = 1000;
			break;
		case kPAWSettingsTableViewDistanceNumberOfRows: // never reached.
		default:
			distance = 10000 * kPAWFeetToMiles;
			break;
	}

	return distance;
}

#pragma mark - UINavigationBar-based actions

- (IBAction)done:(id)sender {
	[self.presentingViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return kPAWSettingsTableViewNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch ((kPAWSettingsTableViewSections)section) {
		case kPAWSettingsTableViewDistance:
			return kPAWSettingsTableViewDistanceNumberOfRows;
			break;
		case kPAWSettingsTableViewLogout:
			return kPAWSettingsTableViewLogoutNumberOfRows;
			break;
		case kPAWSettingsTableViewNumberOfSections:
			return 0;
			break;
	};
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"SettingsTableView";
	if (indexPath.section == kPAWSettingsTableViewDistance) {
		UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
		if ( cell == nil )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		}

		// Configure the cell.
		cell.textLabel.text = [self distanceLabelForCell:indexPath];

		if (self.filterDistance == 0.0) {
			NSLog(@"We have a zero filter distance!");
		}

		PAWLocationAccuracy filterDistanceInFeet = self.filterDistance * ( 1 / kPAWFeetToMeters);
		PAWLocationAccuracy distanceForCell = [self distanceForCell:indexPath];
		if (abs(distanceForCell - filterDistanceInFeet) < 0.001 ) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}

		return cell;
	} else if (indexPath.section == kPAWSettingsTableViewLogout) {
		UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:identifier];
		if ( cell == nil )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		}

		// Configure the cell.
		cell.textLabel.text = @"Log out of AnyWall";
		cell.textLabel.textAlignment = UITextAlignmentCenter;

		return cell;
	}
	else {
		return nil;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch ((kPAWSettingsTableViewSections)section) {
		case kPAWSettingsTableViewDistance:
			return @"Search Distance";
			break;
		case kPAWSettingsTableViewLogout:
			return @"";
			break;
		case kPAWSettingsTableViewNumberOfSections:
			return @"";
			break;
	}
}

#pragma mark - UITableViewDelegate methods

// Called after the user changes the selection.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kPAWSettingsTableViewDistance) {
		[aTableView deselectRowAtIndexPath:indexPath animated:YES];

		// if we were already selected, bail and save some work.
		UITableViewCell *selectedCell = [aTableView cellForRowAtIndexPath:indexPath];
		if (selectedCell.accessoryType == UITableViewCellAccessoryCheckmark) {
			return;
		}

		// uncheck all visible cells.
		for (UITableViewCell *cell in [aTableView visibleCells]) {
			if (cell.accessoryType != UITableViewCellAccessoryNone) {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
		}
		selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;

		PAWLocationAccuracy distanceForCellInFeet = [self distanceForCell:indexPath];
		self.filterDistance = distanceForCellInFeet * kPAWFeetToMeters;
	} else if (indexPath.section == kPAWSettingsTableViewLogout) {
		[aTableView deselectRowAtIndexPath:indexPath animated:YES];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log out of AnyWall?" message:nil delegate:self cancelButtonTitle:@"Log out" otherButtonTitles:@"Cancel", nil];
		[alertView show];
	}
}

#pragma mark - UIAlertViewDelegate methods

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == kPAWSettingsLogoutDialogLogout) {
		// Log out.
		[PFUser logOut];

		[self.presentingViewController dismissModalViewControllerAnimated:YES];

		PAWAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		[appDelegate presentWelcomeViewController];
	} else if (buttonIndex == kPAWSettingsLogoutDialogCancel) {
		return;
	}
}

// Nil implementation to avoid the default UIAlertViewDelegate method, which says:
// "Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button"
// Since we have "Log out" at the cancel index (to get it out from the normal "Ok whatever get this dialog outta my face"
// position, we need to deal with the consequences of that.
- (void)alertViewCancel:(UIAlertView *)alertView {
	return;
}

@end
