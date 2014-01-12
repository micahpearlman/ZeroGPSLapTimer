//
//  ZOTrackSelectViewController.m
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/4/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import "ZOTrackSelectViewController.h"
#import "ZOMapViewController.h"
#import "ZOTrackCollection.h"

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
    return [[ZOTrackCollection instance].tracks count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSInteger idx = [indexPath row];
	if ( idx == [[ZOTrackCollection instance].tracks count] ) {
		static NSString *CellIdentifier = @"new-track-cell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
		[cell.textLabel setText:@"[Add New Track]"];
		return cell;
	} else {
		static NSString *CellIdentifier = @"track-cell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

		NSArray* tracks = [[ZOTrackCollection instance] tracks];
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
	if ( idx == [[ZOTrackCollection instance].tracks count] ) {
		return NO;	// can't add add track button
	}
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		NSArray* tracks = [[ZOTrackCollection instance] tracks];
		NSDictionary* track = [tracks objectAtIndex:[indexPath row]];
		[[ZOTrackCollection instance] removeTrack:track];

        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}



- (IBAction) onAddTrack:(id)sender {
	
	//[self.tableView setEditing:YES animated:YES];
//	ZOMapViewController* trackMapEditor =
//	[self.navigationController pushViewController:<#(UIViewController *)#> animated:<#(BOOL)#>]
}

@end
