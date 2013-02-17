//
//  PAWWallPostsTableViewController.m
//  AnyWall
//
//  Created by Christopher Bowns on 2/6/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

static CGFloat const kPAWWallPostTableViewFontSize = 12.f;
static CGFloat const kPAWWallPostTableViewCellWidth = 310.f; // subject to change.

// Multiline cells:
static CGFloat const kPAWWallPostTableViewCellPadding = 14.f;
static CGFloat const kPAWWallPostTableViewCellUsernameHeight = 15.f;

static NSUInteger const kPAWTableViewMainSection = 0;

#import "PAWWallPostsTableViewController.h"

#import "PAWAppDelegate.h"

@interface PAWWallPostsTableViewController ()

// NSNotification callbacks
- (void)distanceFilterDidChange:(NSNotification *)note;
- (void)locationDidChange:(NSNotification *)note;
- (void)postWasCreated:(NSNotification *)note;

@end

@implementation PAWWallPostsTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
	self = [super initWithStyle:style];
	if (self) {
		// Customize the table:

		// The className to query on
		self.className = NSStringFromClass([PAWPost class]);

		// The key of the PFObject to display in the label of the default cell style
		self.textKey = PAWPostAttributes.title;

		// Whether the built-in pull-to-refresh is enabled
		self.pullToRefreshEnabled = YES;

		// Whether the built-in pagination is enabled
		self.paginationEnabled = YES;

		// The number of objects to show per page
		self.objectsPerPage = kPAWWallPostsSearch;
	}
	return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(distanceFilterDidChange:) name:kPAWFilterDistanceChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidChange:) name:kPAWLocationChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postWasCreated:) name:kPAWPostCreatedNotification object:nil];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;

	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWFilterDistanceChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWLocationChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWPostCreatedNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWFilterDistanceChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWLocationChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPAWPostCreatedNotification object:nil];
}

#pragma mark - NSNotification callbacks

- (void)distanceFilterDidChange:(NSNotification *)note {
	[self loadObjects];
}

- (void)locationDidChange:(NSNotification *)note {
	[self loadObjects];
}

- (void)postWasCreated:(NSNotification *)note {
	[self loadObjects];
}

#pragma mark - PFQueryTableViewController subclass methods

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}

// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
	PFQuery *query = [PFQuery queryWithClassName:self.className];

	// If no objects are loaded in memory, we look to the cache first to fill the table
	// and then subsequently do a query against the network.
	if ([self.objects count] == 0) {
		query.cachePolicy = kPFCachePolicyCacheThenNetwork;
	}

	// Query for posts near our current location.

	// Get our current location:
	PAWAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	CLLocation *currentLocation = appDelegate.currentLocation;
	CLLocationAccuracy filterDistance = appDelegate.filterDistance;

	// And set the query to look by location
	PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
	[query whereKey:PAWPostAttributes.geopoint nearGeoPoint:point withinKilometers:filterDistance / kPAWMetersInAKilometer];
	[query includeKey:PAWPostAttributes.user];

	return query;
}

// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object. 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PAWPost *)post {
	static NSString *CellIdentifier = @"Cell";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}

	// Configure the cell
	cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
	cell.textLabel.numberOfLines = 0;
	cell.textLabel.text = post.title;
	cell.detailTextLabel.text = post.subtitle;
	cell.textLabel.font = [cell.textLabel.font fontWithSize:kPAWWallPostTableViewFontSize];

	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForNextPageAtIndexPath:indexPath];
	cell.textLabel.font = [cell.textLabel.font fontWithSize:kPAWWallPostTableViewFontSize];
	return cell;
}

#pragma mark - UITableViewDataSource protocol methods

#pragma mark - UITableViewDelegate protocol methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// call super because we're a custom subclass.
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Account for the load more cell at the bottom of the tableview if we hit the pagination limit:
	if ( (NSUInteger)indexPath.row >= [self.objects count]) {
		return [tableView rowHeight];
	}

	// The default value for all rows:
	CGFloat rowHeight = [tableView rowHeight];

	// Retrieve the text for this row:
	PAWPost *post = [self.objects objectAtIndex:indexPath.row];
	NSString *text = post.title;

	// Calculate what the frame to fit this will be:
	CGSize theSize = [text sizeWithFont:[UIFont systemFontOfSize:kPAWWallPostTableViewFontSize] constrainedToSize:CGSizeMake(kPAWWallPostTableViewCellWidth, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];

	// And return this height plus cell padding plus the username size (or the row height
	CGFloat textHeight = theSize.height + kPAWWallPostTableViewCellPadding + kPAWWallPostTableViewCellUsernameHeight;
	if (textHeight > rowHeight) {
		rowHeight = textHeight;
	}
	return rowHeight;
}

#pragma mark - PAWWallViewControllerSelection protocol methods

- (void)highlightCellForPost:(PAWPost *)post {
	// Find the cell matching this object.
	for (PAWPost *postFromObject in [self objects]) {
		if ([post equalToPost:postFromObject]) {
			// We found the object, scroll to the cell position where this object is.
			NSUInteger index = [[self objects] indexOfObject:postFromObject];

			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:kPAWTableViewMainSection];
			[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
			[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];

			return;
		}
	}

	// Don't scroll for posts outside the search radius.
	if ([post.title compare:kPAWWallCantViewPost] != NSOrderedSame) {
		// We couldn't find the post, so scroll down to the load more cell.
		NSUInteger rows = [self.tableView numberOfRowsInSection:kPAWTableViewMainSection];
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(rows - 1) inSection:kPAWTableViewMainSection];
		[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (void)unhighlightCellForPost:(PAWPost *)post {
	// Deselect the post's row.
	for (PAWPost *postFromObject in [self objects]) {
		if ([post equalToPost:postFromObject]) {
			NSUInteger index = [[self objects] indexOfObject:postFromObject];
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
			[self.tableView deselectRowAtIndexPath:indexPath animated:YES];

			return;
		}
	}
}

@end
