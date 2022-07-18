//
//  FriendsViewController.m
//  GymBro
//
//  Created by Eric Moran on 7/15/22.
//

#import "FriendsViewController.h"
#import "../Models/UserCell.h"
#import <Parse/Parse.h>

@interface FriendsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *userArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) PFUser *currUser;
@property (strong, nonatomic) CLLocation *userLoc;

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 270;
    
    self.currUser = [PFUser currentUser];
    [self setLocalGym];
    
    [self fetchUsersWithQuery];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchUsersWithQuery) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)fetchUsersWithQuery
{
    self.userArray = [[NSMutableArray alloc] init];
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" notEqualTo:self.currUser[@"username"]];
    [query orderByDescending:@"createdAt"];
    query.limit = 100;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            [self filterFriends:users];
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    cell.user = self.userArray[indexPath.row];
    cell.distanceFromUser = [self getDistance:cell.user];
    [cell setData];
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userArray.count;
}

- (void)setLocalGym
{
    double latitude = [[self.currUser[@"gym"] valueForKeyPath:@"geocodes.main.latitude"] doubleValue];
    double longitude = [[self.currUser[@"gym"] valueForKeyPath:@"geocodes.main.longitude"] doubleValue];
    self.userLoc = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
}

- (long)getDistance:(PFUser *)userOne
{
    double latitudeOne = [[userOne[@"gym"] valueForKeyPath:@"geocodes.main.latitude"] doubleValue];
    double longitudeOne = [[userOne[@"gym"] valueForKeyPath:@"geocodes.main.longitude"] doubleValue];
    CLLocation *userOneLoc = [[CLLocation alloc] initWithLatitude:latitudeOne longitude:longitudeOne];
    
    return [self.userLoc distanceFromLocation:userOneLoc];
}

- (void)filterFriends:(NSArray *)users
{
    __block BOOL isValid;
    NSArray *friends = self.currUser[@"friends"];
    for (PFUser *user in users)
    {
        isValid = NO;
        for (PFUser *friend in friends)
        {
            [friend fetchIfNeeded];
            if ([user[@"username"] isEqual:friend[@"username"]])
            {
                isValid = YES;
            }
        }
        if (isValid)
        {
            [self.userArray addObject:user];
        }
    }
}

@end
