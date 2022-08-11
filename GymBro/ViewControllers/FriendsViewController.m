//
//  FriendsViewController.m
//  GymBro
//
//  Created by Eric Moran on 7/15/22.
//

#import "FriendsViewController.h"
#import "../Models/UserCell.h"
#import "../API/APIManager.h"
#import <Parse/Parse.h>

@interface FriendsViewController () <UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *friendsArray;
@property (strong, nonatomic) NSMutableArray *pendingFriendsArray;
@property (strong, nonatomic) NSMutableArray *friendRequestsArray;

@property (strong, nonatomic) PFUser *currUser;
@property (strong, nonatomic) CLLocation *userLoc;

- (IBAction)refresh:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
- (IBAction)switchSegments:(id)sender;
@property (nonatomic) NSInteger rowCount;
@property int segment;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
- (IBAction)goBack:(id)sender;

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Friends";
    titleLabel.font = [UIFont fontWithName:@"Menlo Bold" size:25];
    self.navigationItem.titleView = titleLabel;
    
    UIImage *backIcon = [UIImage imageNamed:@"back.png"];
    backIcon = [APIManager resizeImage:backIcon withSize:CGSizeMake(40,30)];
    [self.backButton setTitle:@"" forState:UIControlStateNormal];
    [self.backButton setImage:backIcon forState:UIControlStateNormal];
    
    UIImage *refreshIcon = [UIImage imageNamed:@"refresh.png"];
    refreshIcon = [APIManager resizeImage:refreshIcon withSize:CGSizeMake(45, 45)];
    [self.refreshButton setTitle:@"" forState:UIControlStateNormal];
    [self.refreshButton setImage:refreshIcon forState:UIControlStateNormal];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.currUser = [PFUser currentUser];
    [self setLocalGym];
    
    [self fetchUsersWithQuery];
    
}

- (void)fetchUsersWithQuery
{
    self.friendsArray = [[NSMutableArray alloc] init];
    self.friendRequestsArray = [[NSMutableArray alloc] init];
    self.pendingFriendsArray = [[NSMutableArray alloc] init];
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" notEqualTo:self.currUser[@"username"]];
    query.limit = 100;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            [self filterFriends:users];
            self.rowCount = users.count;
            [self.tableView reloadData];
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
    if (indexPath.row % 2 == 0)
    {
        UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
        switch (self.segmentedControl.selectedSegmentIndex) {
            case 0:
                cell.user = self.friendsArray[indexPath.row/2];
                break;
            case 1:
                cell.delegate = self;
                cell.rightUtilityButtons = [self rightButtons];
                cell.user = self.friendRequestsArray[indexPath.row/2];
                break;
            case 2:
                cell.user = self.pendingFriendsArray[indexPath.row/2];
                break;
            default:
                break;
        }
        cell.distanceFromUser = [self getDistance:cell.user];
        cell.controller = self;
        [cell setData];
        return cell;
    }
    else
    {
        UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"separator" forIndexPath:indexPath];
        cell.indexPath = indexPath;
        [cell createSeparator];
        return cell;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            return self.friendsArray.count * 2;
            break;
        case 1:
            return self.friendRequestsArray.count * 2;
            break;
        default:
            return self.pendingFriendsArray.count * 2;
            break;
    }
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
            [self acceptFriendRequest:cell];
            break;
        case 1:
            [self rejectFriendRequest:cell];
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (void)acceptFriendRequest:(UserCell *)cell
{
    PFUser *acceptedUser = cell.user;
    PFUser *user = [PFUser currentUser];
    NSMutableArray *friendsArray = [[NSMutableArray alloc] initWithArray:user[@"friends"]];
    [friendsArray addObject:[acceptedUser valueForKeyPath:@"username"]];
    user[@"friends"] = friendsArray;
    
    NSMutableArray *friendRequestsArray = [[NSMutableArray alloc] initWithArray:user[@"friendRequests"]];
    [friendRequestsArray removeObjectIdenticalTo:[acceptedUser valueForKeyPath:@"username"]];
    user[@"friendRequests"] = friendRequestsArray;
    
    NSMutableArray *otherFriendsArray = [[NSMutableArray alloc] initWithArray:acceptedUser[@"friends"]];
    [otherFriendsArray addObject:[user valueForKeyPath:@"username"]];
    
    NSMutableArray *otherPendingFriendsArray = [[NSMutableArray alloc] initWithArray:acceptedUser[@"pendingFriends"]];
    [otherPendingFriendsArray removeObjectIdenticalTo:[user valueForKeyPath:@"username"]];
    
    NSDictionary *params = @{@"username": [acceptedUser valueForKeyPath:@"username"],
                             @"friends": otherFriendsArray,
                             @"pendingFriends": otherPendingFriendsArray};
    
    [PFCloud callFunctionInBackground:@"acceptFriendRequest" withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
    }];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            [self.friendRequestsArray removeObjectAtIndex:cellIndexPath.row/2];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cellIndexPath.row+1 inSection:cellIndexPath.section], cellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            NSLog(@"Error Sending Friend Request: %@", error.localizedDescription);
        }
    }];
}

- (void)rejectFriendRequest:(UserCell *)cell
{
    PFUser *rejectedUser = cell.user;
    PFUser *user = [PFUser currentUser];
    NSMutableArray *rejectedUsers = [[NSMutableArray alloc] initWithArray:user[@"rejectedUsers"]];
    [rejectedUsers addObject:rejectedUser[@"username"]];
    NSMutableArray *friendRequests = [[NSMutableArray alloc] initWithArray:user[@"friendRequests"]];
    [friendRequests removeObjectIdenticalTo:rejectedUser[@"username"]];
    user[@"rejectedUsers"] = rejectedUsers;
    user[@"friendRequests"] = friendRequests;
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            [self.friendRequestsArray removeObjectAtIndex:cellIndexPath.row/2];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cellIndexPath.row+1 inSection:cellIndexPath.section], cellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            NSLog(@"Error Rejected User: %@", error.localizedDescription);
        }
    }];
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
                isValidPendingFriend = YES;
            }
        }
        if (isValidFriend)
        {
            [self.friendsArray addObject:user];
            [self.tableView reloadData];
        }
        else if (isValidFriendRequest)
        {
            [self.friendRequestsArray addObject:user];
        }
        else if (isValidPendingFriend)
        {
            [self.pendingFriendsArray addObject:user];
        }
    }
}

- (IBAction)refresh:(id)sender {
    [self fetchUsersWithQuery];
}
- (IBAction)switchSegments:(id)sender {
    [self.tableView reloadData];
}
- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
