//
//  FilterViewController.m
//  GymBro
//
//  Created by Eric Moran on 7/28/22.
//

#import "FilterViewController.h"
#import "UIKit/UIKit.h"
#import <Parse/Parse.h>
#import "../Models/PriorityCell.h"
#import "../API/APIManager.h"

@interface FilterViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)confirm:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
- (IBAction)setDefaultFilters:(id)sender;
@property (strong, nonatomic) PFUser *currUser;


@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 200;
    
    UIImage *confirmIcon = [UIImage imageNamed:@"filter2.png"];
    confirmIcon = [APIManager resizeImage:confirmIcon withSize:CGSizeMake(40, 40)];
    [self.confirmButton setTitle:@"" forState:UIControlStateNormal];
    [self.confirmButton setImage:confirmIcon forState:UIControlStateNormal];
    
    self.currUser = [PFUser currentUser];
    NSArray *filterArray = self.currUser[@"filterArray"];
    
    self.workoutType = [filterArray[0] intValue];
    self.workoutTime = [filterArray[1] intValue];
    self.level = [filterArray[2] intValue];
    self.gender = [self.currUser[@"genderFilter"] intValue];
    self.distance = [self.currUser[@"distanceFilter"] intValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (indexPath.row < 3)
    {
        PriorityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PriorityCell"];
        cell.filterVC = self;
        cell.indexPath = indexPath;
        
        switch (indexPath.row) {
            case 0:
                cell.traitLabel.text = @"Workout Type:";
                cell.filterValue = self.workoutType;
                break;
            case 1:
                cell.traitLabel.text = @"Workout Time:";
                cell.filterValue = self.workoutTime;
                break;
            case 2:
                cell.traitLabel.text = @"Level:";
                cell.filterValue = self.level;
                break;
            default:
                break;
        }
        [cell setFilter];
        return cell;
    }
    else if (indexPath.row == 3)
    {
        PriorityCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"PriorityCell2" forIndexPath:indexPath];
        cell2.filterVC = self;
        cell2.traitLabel.text = @"Gender";
        cell2.filterValue = self.gender;
        [cell2 setFilter];
        return cell2;
    }
    else
    {
        PriorityCell *cell3 = [tableView dequeueReusableCellWithIdentifier:@"PriorityCell3" forIndexPath:indexPath];
        cell3.filterVC = self;
        cell3.traitLabel.text = @"Distance";
        cell3.filterValue = self.distance;
        [cell3 setFilter];
        return cell3;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


- (IBAction)setDefaultFilters:(id)sender {
    self.workoutType = 5;
    self.workoutTime = 3;
    self.level = 1;
    self.gender = 0;
    self.distance = 62;
    [self.tableView reloadData];
}


- (IBAction)confirm:(id)sender {
    NSArray *newPriorityArray = [[NSArray alloc] initWithObjects:@(self.workoutType), @(self.workoutTime), @(self.level), nil];
    PFUser *user = [PFUser currentUser];
    user[@"priorityArray"] = newPriorityArray;
    user[@"distanceFilter"] = @(self.distance);
    user[@"genderFilter"] = @(self.gender);
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self.delegate setFiltersWithArray:newPriorityArray andGenderFilter:self.gender];
        [self.tableView reloadData];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}
@end
