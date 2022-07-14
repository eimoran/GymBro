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
    
    self.userArray  = [[NSMutableArray alloc] init];
    
    [self fetchUsersWithQuery];
}



- (void)fetchUsersWithQuery
{
    PFUser *user = [PFUser currentUser];
    NSArray *friends = user[@"friends"];
    PFQuery *query = [PFUser query];
    for (PFUser *friend in friends)
    {
        [friend fetchIfNeeded];
        [query whereKey:@"username" notEqualTo:friend[@"username"]];
    }
    [query whereKey:@"username" notEqualTo:user[@"username"]];
    query.limit = 100;
    [query orderByDescending:@"createdAt"];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            for (PFUser *user in users)
            {
                for (PFUser *friend in friends)
                {
                    if (![user[@"username"] isEqual:friend[@"username"]])
                    {
                        [self.userArray addObject:user];
                    }
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
