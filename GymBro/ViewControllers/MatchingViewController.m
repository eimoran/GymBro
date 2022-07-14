//
//  MatchingViewController.m
//  GymBro
//
//  Created by Eric Moran on 7/5/22.
//

#import "MatchingViewController.h"
#import "Parse/Parse.h"
#import "../Models/UserCell.h"

@interface MatchingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *userArray;
@property (strong, nonatomic) PFUser *currUser;
@property (strong, nonatomic) CLLocation *userLoc;

@end

@implementation MatchingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 250;
    
    self.userArray  = [[NSMutableArray alloc] init];
    self.currUser = [PFUser currentUser];
    double latitude = [[self.currUser[@"gym"] valueForKeyPath:@"geocodes.main.latitude"] doubleValue];
    double longitude = [[self.currUser[@"gym"] valueForKeyPath:@"geocodes.main.longitude"] doubleValue];
    self.userLoc = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    [self fetchUsersWithQuery];
}



- (void)fetchUsersWithQuery
{
    NSArray *friends = self.currUser[@"friends"];
    __block BOOL isValid;
    PFQuery *query = [PFUser query];
    for (PFUser *friend in friends)
    {
        [friend fetchIfNeeded];
        [query whereKey:@"username" notEqualTo:friend[@"username"]];
    }
    [query whereKey:@"username" notEqualTo:self.currUser[@"username"]];
    [query whereKeyExists:@"level"];
    [query whereKeyExists:@"gym"];
    query.limit = 100;
    [query orderByDescending:@"createdAt"];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            for (PFUser *user in users)
            {
                isValid = YES;
                for (PFUser *friend in friends)
                {
                    if ([user[@"username"] isEqual:friend[@"username"]])
                    {
                        isValid = NO;
                    }
                }
                if (isValid)
                {
                    
                    [self.userArray addObject:user];
                }
            }
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    cell.user = self.userArray[indexPath.row];
    double latitudeOne = [[cell.user[@"gym"] valueForKeyPath:@"geocodes.main.latitude"] doubleValue];
    double longitudeOne = [[cell.user[@"gym"] valueForKeyPath:@"geocodes.main.longitude"] doubleValue];
    CLLocation *userOneLoc = [[CLLocation alloc] initWithLatitude:latitudeOne longitude:longitudeOne];
    NSLog(@"%f", [self.userLoc distanceFromLocation:userOneLoc]);
    cell.distanceFromUser = [self.userLoc distanceFromLocation:userOneLoc];
    [cell setData];
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userArray.count;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
