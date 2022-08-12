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
#import "FilterViewController.h"

@interface MatchingViewController () <UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate, FilterViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *userArray;
@property (strong, nonatomic) NSMutableArray *compatibilityArray;
@property (strong, nonatomic) PFUser *currUser;
@property (strong, nonatomic) CLLocation *userLoc;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (nonatomic) NSInteger rowCount;

@end

@implementation MatchingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.currUser = [PFUser currentUser];
    self.filterButton.hidden = YES;    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 00, 30)];
    titleLabel.text = @"Your Matches!";
    titleLabel.font = [UIFont fontWithName:@"Menlo Bold" size:18];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    self.tabBarController.tabBar.barTintColor = [UIColor colorWithHue:0 saturation:0.15 brightness:1 alpha:1];
    self.tabBarController.tabBar.backgroundColor = [UIColor colorWithHue:0 saturation:0.15 brightness:1 alpha:1];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithHue:0 saturation:0.15 brightness:1 alpha:1];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHue:0 saturation:0.15 brightness:1 alpha:1];
    self.tabBarController.tabBar.barTintColor = [UIColor colorWithHue:0 saturation:0.15 brightness:1 alpha:1];
    self.tabBarController.tabBar.backgroundColor = [UIColor colorWithHue:0 saturation:0.15 brightness:1 alpha:1];
    self.view.backgroundColor = [UIColor colorWithHue:0 saturation:0.15 brightness:1 alpha:1];
    
    if (!self.currUser[@"gym"])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing Profile Fields"
                                                                       message:@"Please Add Your Local Gym to Your Profile"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                             {}];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if (!self.currUser[@"profileImages"])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing Profile Fields"
                                                                       message:@"Please Add Images To Your Profile"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                             {}];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if ([self.currUser[@"bio"] isEqual:@""])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing Profile Fields"
                                                                       message:@"Please Add a Bio To Your Profile"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                             {}];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        self.filterButton.hidden = NO;
        UIImage *filterIcon = [UIImage imageNamed:@"filter.png"];
        filterIcon = [APIManager resizeImage:filterIcon withSize:CGSizeMake(45, 45)];
        [self.filterButton setTitle:@"" forState:UIControlStateNormal];
        [self.filterButton setImage:filterIcon forState:UIControlStateNormal];
        
        
        
        [self setLocalGym];
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        
        self.userArray = [[NSMutableArray alloc] init];
        [self fetchUsersWithQuery];
        
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(refreshUser) forControlEvents:UIControlEventValueChanged];
        [self.tableView insertSubview:self.refreshControl atIndex:0];
    }
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
    self.userArray = [APIManager fetchUsersWithQuery:self.currUser withPriorityArray:self.currUser[@"priorityArray"] withGenderFilter:[self.currUser[@"genderFilter"] intValue]];
    self.rowCount = self.userArray.count;
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UINavigationController *navVC = [segue destinationViewController];
    FilterViewController *filterVC = navVC.topViewController;
    filterVC.delegate = self;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.user = self.userArray[indexPath.row];
    cell.distanceFromUser = [APIManager getDistance:self.currUser from:cell.user];
    cell.controller = self;
    cell.rightUtilityButtons = [self rightButtons];
    cell.indexPath = indexPath;
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
            
            [self.userArray removeObjectAtIndex:cellIndexPath.row/2];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cellIndexPath.row+1 inSection:cellIndexPath.section], cellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
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
            [self.userArray removeObjectAtIndex:cellIndexPath.row/2];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cellIndexPath.row+1 inSection:cellIndexPath.section], cellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            NSLog(@"Error Rejecting User: %@", error.localizedDescription);
        }
    }];
}
- (void)setFiltersWithArray:(NSArray *)arr andGenderFilter:(NSInteger) gender
{
    self.userArray = [APIManager fetchUsersWithQuery:self.currUser withPriorityArray:arr withGenderFilter:(int)(gender)];
    [self.tableView reloadData];
}


@end
