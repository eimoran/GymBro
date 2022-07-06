//
//  ProfileFormViewController.m
//  GymBro
//
//  Created by Eric Moran on 7/5/22.
//

#import "ProfileFormViewController.h"
#import "../Models/WorkoutSplitCell.h"
#import "../Models/WorkoutTimeCell.h"
#import "../Models/GenderCell.h"
#import "Parse/Parse.h"


@interface ProfileFormViewController () <UITableViewDelegate, UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)submit:(id)sender;

@end

@implementation ProfileFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // Do any additional setup after loading the view.
    self.tableView.rowHeight = 200;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (indexPath.row == 0)
    {
        WorkoutSplitCell *splitCell = [tableView dequeueReusableCellWithIdentifier:@"WorkoutSplitCell" forIndexPath:indexPath];
        splitCell.controller = self;
        return splitCell;
    }
    else if (indexPath.row == 1)
    {
        WorkoutTimeCell *workoutTimeCell = [tableView dequeueReusableCellWithIdentifier:@"WorkoutTimeCell" forIndexPath:indexPath];
        workoutTimeCell.controller = self;
        return workoutTimeCell;
    }
    else if (indexPath.row == 2)
    {
        GenderCell *genderCell = [tableView dequeueReusableCellWithIdentifier:@"GenderCell" forIndexPath:indexPath];
        genderCell.controller = self;
        return genderCell;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)submit:(id)sender {
    if (self.time == nil)
    {
        self.time = @"Morning (6am - 12pm)";
    }
    if (self.split == nil)
    {
        self.split = @"Whole-Body Split";
    }
    if (self.gender == nil)
    {
        self.gender = @"Male";
    }
    NSLog(@"%@, %@, %@", self.split, self.time, self.gender);
    
}
@end
