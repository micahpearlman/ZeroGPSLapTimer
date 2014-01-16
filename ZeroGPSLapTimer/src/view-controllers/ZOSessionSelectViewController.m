//
//  ZOTrackSessionViewController.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/11/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOSessionSelectViewController.h"
#import "ZOTrackCollection.h"

@interface ZOSessionSelectViewController () {
	NSArray*		_sessionInfos;
}

@end

@implementation ZOSessionSelectViewController

- (id)initWithStyle:(UITableViewStyle)style
{
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
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
	NSString* name = [ZOTrackCollection instance].currentTrack.name;
	self.navigationItem.title = [name stringByAppendingString:@" Sessions"];
}

- (void) viewWillAppear:(BOOL)animated  {
	[super viewWillAppear:animated];
	_sessionInfos = [ZOTrackCollection instance].currentTrack.sessionInfos;
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
    return [_sessionInfos count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
	NSInteger idx = [indexPath row];
	if ( idx == [_sessionInfos count] ) {	// new session
		static NSString *CellIdentifier = @"new-session-cell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
		[cell.textLabel setText:@"[Start New Session]"];
		return cell;


	} else {
		static NSString *CellIdentifier = @"session-cell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
		NSDictionary* sessionInfo = [_sessionInfos objectAtIndex:[indexPath row]];
		[cell.textLabel setText:[sessionInfo objectForKey:@"name"]];

		return cell;
		
	}
    
    return nil;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
	NSInteger idx = [indexPath row];
	if ( idx == [_sessionInfos count] ) {
		return NO;	// can't add add track button
	}
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSDictionary* sessionInfo = [_sessionInfos objectAtIndex:[indexPath row]];
		[[ZOTrackCollection instance].currentTrack removeSessionInfo:sessionInfo];
		_sessionInfos = [ZOTrackCollection instance].currentTrack.sessionInfos;

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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
	NSIndexPath* selectedIndexPath = [self.tableView indexPathForSelectedRow];
	if ( [selectedIndexPath row] == [_sessionInfos count] ) {	// new session
		// we are creating a new track so make sure to null out selected track
		[ZOTrackCollection instance].currentTrack.currentSessionInfo = nil;
	} else {

		[ZOTrackCollection instance].currentTrackInfo = [_sessionInfos objectAtIndex:[selectedIndexPath row]];
		
	}

}


@end
