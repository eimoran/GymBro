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
@property (strong, nonatomic) NSMutableArray *compatibilityArray;
@property (strong, nonatomic) PFUser *currUser;
@property (strong, nonatomic) CLLocation *userLoc;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation MatchingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 270;
    
    self.userArray  = [[NSMutableArray alloc] init];
    self.currUser = [PFUser currentUser];
    [self setLocalGym];
    
    [self fetchUsersWithQuery];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshUser) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)setLocalGym
{
    double latitude = [[self.currUser[@"gym"] valueForKeyPath:@"geocodes.main.latitude"] doubleValue];
    double longitude = [[self.currUser[@"gym"] valueForKeyPath:@"geocodes.main.longitude"] doubleValue];
    self.userLoc = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
}

- (void)refreshUser
{
    [self setLocalGym];
    [self fetchUsersWithQuery];
}


- (void)fetchUsersWithQuery
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" notEqualTo:self.currUser[@"username"]];
    [query whereKeyExists:@"level"];
    [query whereKeyExists:@"gym"];
    [query orderByDescending:@"createdAt"];
    query.limit = 100;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            [self setScores:users];
            [self compatibilitySort];
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

- (long)getDistance:(PFUser *)userOne
{
    double latitudeOne = [[userOne[@"gym"] valueForKeyPath:@"geocodes.main.latitude"] doubleValue];
    double longitudeOne = [[userOne[@"gym"] valueForKeyPath:@"geocodes.main.longitude"] doubleValue];
    CLLocation *userOneLoc = [[CLLocation alloc] initWithLatitude:latitudeOne longitude:longitudeOne];
    
    return [self.userLoc distanceFromLocation:userOneLoc];
}


- (void)setScores:(NSArray *)users
{
    NSArray *friends = self.currUser[@"friends"];
    NSArray *pendingFriends = self.currUser[@"pendingFriends"];
    __block BOOL isValid;
    __block BOOL isValidPendingFriend;
    self.compatibilityArray = [[NSMutableArray alloc] init];
    self.userArray = [[NSMutableArray alloc] init];
    NSString *currSplit = self.currUser[@"workoutSplit"];
    NSString *currTime = self.currUser[@"workoutTime"];
    NSString *currLevel = self.currUser[@"level"];
    for (PFUser *user in users)
    {
        isValid = YES;
        isValidPendingFriend = YES;
        for (NSString *friend in friends)
        {
            if ([user[@"username"] isEqual:friend])
            {
                isValid = NO;
            }
        }
        for (NSString *pendingFriend in pendingFriends)
        {
            if ([user[@"username"] isEqual:pendingFriend])
            {
                isValid = NO;
            }
        }
        if (isValid)
        {
            NSInteger score = 0;
            if ([[user valueForKeyPath:@"workoutSplit"] isEqual:currSplit])
            {
                score += 3;
            }
            
            if ([[user valueForKeyPath:@"workoutTime"] isEqual:currTime])
            {
                score += 2;
            }
            if ([[user valueForKeyPath:@"level"] isEqual:currLevel])
            {
                score += 1;
            }
            long distance = [self getDistance:user]*0.00062317;
            
            if (distance <= 1)
            {
                score += 4;
            }
            else if (distance <= 5)
            {
                score += 3;
            }
            else if (distance <= 10)
            {
                score += 2;
            }
            else
            {
                score += 1;
            }
            [self.userArray addObject:user];
            [self.compatibilityArray addObject:@(score)];
        }
    }
}

- (void)compatibilitySort
{
    NSMutableArray *sortedArray = [[NSMutableArray alloc] init];
    int i = 0;
    for (int x = 0; x < self.userArray.count; x++)
    {
        PFUser *user = self.userArray[x];
        for (i = 0; i < sortedArray.count; i++)
        {
            long y = [self.userArray indexOfObject:sortedArray[i]];
            if (self.compatibilityArray[x] > self.compatibilityArray[y])
            {
                [sortedArray insertObject:user atIndex:i];
                break;
            }
        }
        if (i == sortedArray.count)
        {
            [sortedArray addObject:user];
        }
    }
    self.userArray = sortedArray;
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    cell.user = self.userArray[indexPath.row];
    cell.distanceFromUser = [self getDistance:cell.user];
    cell.controller = self;
    [cell setData];
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userArray.count;
}

@end
