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

@end

@implementation MatchingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 250;
    
    
    [self fetchUsersWithQuery];
}

- (void)saveFriend
{
    PFUser *user = [PFUser currentUser];
    NSMutableArray *friendsArray = [[NSMutableArray alloc] initWithArray:user[@"friends"]];
    [friendsArray addObject:[[self.userArray objectAtIndex:0] valueForKeyPath:@"objectId"]];
    user[@"friends"] = friendsArray;
    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            NSLog(@"%@", user[@"friends"]);
        }
        else
        {
            NSLog(@"Error Updating Profile: %@", error.localizedDescription);
        }
    }];

}

- (void)fetchUsersWithQuery
{
    PFUser *user = [PFUser currentUser];
    if (user[@"friends"] == nil)
    {
        user[@"friends"] = [[NSMutableArray alloc] init];
    }
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" notEqualTo:user[@"username"]];
    query.limit = 100;
    [query orderByDescending:@"createdAt"];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            self.userArray = users;
            [self.tableView reloadData];
            [self saveFriend];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    cell.user = self.userArray[indexPath.row];
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
