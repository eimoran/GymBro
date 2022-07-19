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

@property (weak, nonatomic) IBOutlet UITableView *friendsTableView;
@property (weak, nonatomic) IBOutlet UITableView *pendingTableView;
@property (weak, nonatomic) IBOutlet UITableView *requestTableView;

@property (strong, nonatomic) NSMutableArray *friendsArray;
@property (strong, nonatomic) NSMutableArray *pendingFriendsArray;
@property (strong, nonatomic) NSMutableArray *friendRequestsArray;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) PFUser *currUser;
@property (strong, nonatomic) CLLocation *userLoc;

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.friendsTableView.delegate = self;
    self.friendsTableView.dataSource = self;
    self.friendsTableView.rowHeight = 250;
    self.pendingTableView.delegate = self;
    self.pendingTableView.dataSource = self;
    self.pendingTableView.rowHeight = 250;
    self.requestTableView.delegate = self;
    self.requestTableView.dataSource = self;
    self.requestTableView.rowHeight = 250;
    
    self.currUser = [PFUser currentUser];
    [self setLocalGym];
    
    [self fetchUsersWithQuery];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchUsersWithQuery) forControlEvents:UIControlEventValueChanged];
    [self.friendsTableView insertSubview:self.refreshControl atIndex:0];
}

- (void)fetchUsersWithQuery
{
    self.friendsArray = [[NSMutableArray alloc] init];
    self.friendRequestsArray = [[NSMutableArray alloc] init];
    self.pendingFriendsArray = [[NSMutableArray alloc] init];
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" notEqualTo:self.currUser[@"username"]];
    [query orderByDescending:@"createdAt"];
    query.limit = 100;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            [self filterFriends:users];
            [self.friendsTableView reloadData];
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
    if ([tableView isEqual: self.friendsTableView])
    {
        cell.user = self.friendsArray[indexPath.row];
    }
    else if ([tableView isEqual:self.requestTableView])
    {
        cell.user = self.friendRequestsArray[indexPath.row];
    }
    else
    {
        cell.user = self.pendingFriendsArray[indexPath.row];
    }
    cell.distanceFromUser = [self getDistance:cell.user];
    [cell setData];
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.friendsTableView])
    {
        NSLog(@"FRIENDS: %lu", (unsigned long)self.friendsArray.count);
        return self.friendsArray.count;
    }
    else if ([tableView isEqual:self.requestTableView])
    {
        NSLog(@"REQUESTS: %lu", (unsigned long)self.friendRequestsArray.count);
        return self.friendRequestsArray.count;
    }
    else
    {
        NSLog(@"PENDING: %lu", (unsigned long)self.pendingFriendsArray.count);
        return self.pendingFriendsArray.count;
    }
    
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
    __block BOOL isValidFriend;
    __block BOOL isValidPendingFriend;
    __block BOOL isValidFriendRequest;
    
    NSArray *friends = self.currUser[@"friends"];
    NSArray *pendingFriends = self.currUser[@"pendingFriends"];
    NSArray *friendRequests= self.currUser[@"friendRequests"];
    
    for (PFUser *user in users)
    {
        NSLog(@"USERNAME: %@", user[@"username"]);
        isValidFriend = NO;
        isValidPendingFriend = NO;
        isValidFriendRequest = NO;
        for (NSString *friend in friends)
        {
            if ([user[@"username"] isEqual:friend])
            {
                isValidFriend = YES;
            }
        }
        for (NSString *request in friendRequests)
        {
            if ([user[@"username"] isEqual:request])
            {
                isValidFriendRequest = YES;
            }
        }
        for (NSString *pendingFriend in pendingFriends)
        {
            if ([user[@"username"] isEqual:pendingFriend])
            {
                NSLog(@"VALID PENDING");
                isValidPendingFriend = YES;
            }
        }
        if (isValidFriend)
        {
            [self.friendsArray addObject:user];
            NSLog(@"FRIEND COUNT: %lu", (unsigned long)self.pendingFriendsArray.count);
            [self.friendsTableView reloadData];
        }
        else if (isValidFriendRequest)
        {
            [self.friendRequestsArray addObject:user];
            NSLog(@"REQUEST COUNT: %lu", (unsigned long)self.pendingFriendsArray.count);
            [self.requestTableView reloadData];
        }
        else if (isValidPendingFriend)
        {
            [self.pendingFriendsArray addObject:user];
            NSLog(@"PENDING COUNT: %lu", (unsigned long)self.pendingFriendsArray.count);
            [self.pendingTableView reloadData];
        }
    }
}

@end
