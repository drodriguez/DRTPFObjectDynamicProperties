//
//  PAWWallPostsTableViewController.h
//  AnyWall
//
//  Created by Christopher Bowns on 2/6/12.
//  Copyright (c) 2012 Parse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "PAWWallViewController.h"

@interface PAWWallPostsTableViewController : PFQueryTableViewController <PAWWallViewControllerHighlight>

- (void)highlightCellForPost:(PAWPost *)post;
- (void)unhighlightCellForPost:(PAWPost *)post;

@end
