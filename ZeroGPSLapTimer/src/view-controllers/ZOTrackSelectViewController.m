//
//  ZOTrackSelectViewController.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/4/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOTrackSelectViewController.h"
#import "ZOTrackCollection.h"
#import "ZOTrackEditViewController.h"
#import "ZOSessionSelectViewController.h"

@interface ZOTrackSelectViewController ()

@end

@implementation ZOTrackSelectViewController



- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

	
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
		
	[self.navigationController setHidesBottomBarWhenPushed:YES];
}

- (void) viewWillAppear:(BOOL)animated {
	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[ZOTrackCollection instance].trackInfos count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSInteger idx = [indexPath row];
	if ( idx == [[ZOTrackCollection instance].trackInfos count] ) {	// new track
		static NSString *CellIdentifier = @"new-track-cell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
		[cell.textLabel setText:@"[Add New Track]"];
		return cell;
	} else {
		static NSString *CellIdentifier = @"track-cell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

		NSArray* tracks = [[ZOTrackCollection instance] trackInfos];
		NSDictionary* track = [tracks objectAtIndex:idx];
		[cell.textLabel setText:[track objectForKey:@"name"]];
		return cell;
	}
		// Configure the cell...
	
    return nil;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
	NSInteger idx = [indexPath row];
	if ( idx == [[ZOTrackCollection instance].trackInfos count] ) {
		return NO;	// can't add add track button
	}
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		NSArray* tracks = [[ZOTrackCollection instance] trackInfos];
		NSDictionary* track = [tracks objectAtIndex:[indexPath row]];
		[[ZOTrackCollection instance] removeTrackInfo:track];

        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}



// see: http://stackoverflow.com/questions/6427817/tableviewcontroller-editingstyle-and-insertion
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

	// get the selected track
	//NSIndexPath* selectedIndexPath = [self.tableView indexPathForSelectedRow];
	NSIndexPath* selectedIndexPath = [self.tableView indexPathForCell:sender];
	NSArray* tracks = [[ZOTrackCollection instance] trackInfos];
	NSDictionary* selectedTrackInfo = nil;
	ZOTrack* track = nil;

	if ( [segue.identifier isEqualToString:@"new-track"]  ) { // if not a new track get the selection
		return;	// do nothing
	}
	
	selectedTrackInfo = [tracks objectAtIndex:[selectedIndexPath row]];
	track = [ZOTrack trackFromTrackInfo:selectedTrackInfo];


	if ( [segue.identifier isEqualToString:@"track-sessions"] ) {
		ZOSessionSelectViewController* sessionsViewController = (ZOSessionSelectViewController*)segue.destinationViewController;
		sessionsViewController.track = track;
	} else if ( [segue.identifier isEqualToString:@"edit-track"] ) {
		ZOTrackEditViewController* trackEditViewController = (ZOTrackEditViewController*)segue.destinationViewController;
		trackEditViewController.track = track;
	}

}




@end
