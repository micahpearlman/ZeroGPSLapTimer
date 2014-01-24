//
//  ZOLapTimeViewController.h
//  ZeroGPSLapTimer
//
//  Created by Micah Pearlman on 1/24/14.
//  Copyright (c) 2014 Micah Pearlman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZOLapTimeViewController : UIViewController

@property (nonatomic,retain) IBOutlet UILabel* trackName;
@property (nonatomic,retain) IBOutlet UILabel* currentLapTime;
@property (nonatomic,retain) IBOutlet UILabel* previousLapTime;
@property (nonatomic,retain) IBOutlet UITableView* tableView;

@end