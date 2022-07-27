//
//  MatchingViewController.m
//  GymBro
//
//  Created by Eric Moran on 7/5/22.
//

#import "MatchingViewController.h"
#import "Parse/Parse.h"
#import "../Models/UserCell.h"
#import "../API/APIManager.h"

@interface MatchingViewController () <UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate>

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
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    
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
    self.userArray = [APIManager fetchUsersWithQuery:self.currUser];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
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
    cell.delegate = self;
    cell.user = self.userArray[indexPath.row];
    cell.distanceFromUser = [APIManager getDistance:self.currUser from:cell.user];
    cell.controller = self;
    cell.rightUtilityButtons = [self rightButtons];
    [cell setData];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userArray.count;
}


- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    UIImage *checkImage = [UIImage imageNamed:@"add-user.png"];
    UIImage *rejectImage = [UIImage imageNamed:@"close.png"];
    checkImage = [APIManager imageWithImage:checkImage convertToSize:CGSizeMake(50, 50)];
    rejectImage = [APIManager imageWithImage:rejectImage convertToSize:CGSizeMake(50, 50)];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.0f green:0.0f blue:1.4f alpha:1.0]
                                                 icon:checkImage];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.8f green:0.0f blue:0.0f alpha:1.0]
                                                icon:rejectImage];
    
    return rightUtilityButtons;
}

- (void)swipeableTableViewCell:(UserCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    switch (index)
    {
        case 0:
            [self acceptUser:cell];
            break;
        case 1:
            [self rejectUser:cell];
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (void)acceptUser:(UserCell *)cell
{
    PFUser *acceptedUser = cell.user;
    PFUser *user = [PFUser currentUser];
    NSMutableArray *pendingFriendsArray = [[NSMutableArray alloc] initWithArray:user[@"pendingFriends"]];
    [pendingFriendsArray addObject:[acceptedUser valueForKeyPath:@"username"]];
    user[@"pendingFriends"] = pendingFriendsArray;
    
    NSMutableArray *otherUserFriendRequestArray = [[NSMutableArray alloc] initWithArray:user[@"friendRequests"]];
    [otherUserFriendRequestArray addObject:[user valueForKeyPath:@"username"]];
    acceptedUser[@"friendRequests"] = otherUserFriendRequestArray;
    
    NSDictionary *params = @{@"username": [acceptedUser valueForKeyPath:@"username"],
                             @"friendRequests": otherUserFriendRequestArray};
    
    [PFCloud callFunctionInBackground:@"sendFriendRequest" withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
    }];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            [self.userArray removeObjectAtIndex:cellIndexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            NSLog(@"Error Sending Friend Request: %@", error.localizedDescription);
        }
    }];
}

- (void)rejectUser:(UserCell *)cell
{
    PFUser *rejectedUser = cell.user;
    PFUser *user = [PFUser currentUser];
    NSMutableArray *rejectedUsers = [[NSMutableArray alloc] initWithArray:user[@"rejectedUsers"]];
    [rejectedUsers addObject:rejectedUser[@"username"]];
    user[@"rejectedUsers"] = rejectedUsers;
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            [self.userArray removeObjectAtIndex:cellIndexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            NSLog(@"Error Rejected User: %@", error.localizedDescription);
        }
    }];
}

@end
