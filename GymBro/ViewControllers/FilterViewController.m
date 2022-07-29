//
//  FilterViewController.m
//  GymBro
//
//  Created by Eric Moran on 7/28/22.
//

#import "FilterViewController.h"
#import "UIKit/UIKit.h"
#import "../Models/PriorityCell.h"

@interface FilterViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)confirm:(id)sender;

@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 200;
    
    self.workoutType = 5;
    self.workoutTime = 5;
    self.level = 5;
    self.distance1 = 5;
    self.distance2 = 5;
    self.distance3 = 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    PriorityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PriorityCell"];
    cell.filterVC = self;
    cell.row = indexPath.row;
    switch (indexPath.row) {
        case 0:
            cell.traitLabel.text = @"Workout Type:";
            break;
        case 1:
            cell.traitLabel.text = @"Workout Time:";
            break;
        case 2:
            cell.traitLabel.text = @"Level:";
            break;
        case 3:
            cell.traitLabel.text = @"Within 1 Mile Of Your Gym";
            break;
        case 4:
            cell.traitLabel.text = @"Within 5 Miles Of Your Gym";
            break;
        case 5:
            cell.traitLabel.text = @"Within 10 Miles Of Your Gym";
            break;
        default:
            break;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)confirm:(id)sender {
    [self.delegate setFiltersWithArray:[[NSArray alloc] initWithObjects:@(self.workoutType), @(self.workoutTime), @(self.level), @(self.distance1), @(self.distance2), @(self.distance3), nil]];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
