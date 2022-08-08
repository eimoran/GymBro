//
//  HomeViewController.m
//  GymBro
//
//  Created by Eric Moran on 7/5/22.
//

#import "HomeViewController.h"
#import "../Models/UserCell.h"
#import "../Models/PostCell.h"
#import "../Models/Post.h"
#import "PostDetailsViewController.h"
#import "../API/APIManager.h"

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *userArray;
@property (strong, nonatomic) PFUser *currUser;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *postArray;
@property (strong, nonatomic) NSMutableArray *likedPostsArray;

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIButton *friendsButton;
@property (weak, nonatomic) IBOutlet UIButton *composeButton;


@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.currUser = [PFUser currentUser];
    UIImage *friendsIcon = [UIImage imageNamed:@"friends.png"];
    friendsIcon = [APIManager resizeImage:friendsIcon withSize:CGSizeMake(45, 45)];
    [self.friendsButton setTitle:@"" forState:UIControlStateNormal];
    [self.friendsButton setImage:friendsIcon forState:UIControlStateNormal];
    
    UIImage *composeIcon = [UIImage imageNamed:@"compose.png"];
    composeIcon = [APIManager resizeImage:composeIcon withSize:CGSizeMake(45, 45)];
    [self.composeButton setTitle:@"" forState:UIControlStateNormal];
    [self.composeButton setImage:composeIcon forState:UIControlStateNormal];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"GymBro";
    titleLabel.font = [UIFont fontWithName:@"Menlo Bold" size:30];
    self.navigationItem.titleView = titleLabel;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.postArray = [APIManager fetchPostswithTableView:self.tableView andRefresh:self.refreshControl];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchPostsWithQuery) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithHue:0.6 saturation:0.15 brightness:1 alpha:1];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHue:0.6 saturation:0.15 brightness:1 alpha:1];
    
    self.tabBarController.tabBar.barTintColor = [UIColor colorWithHue:0.6 saturation:0.15 brightness:1 alpha:1];
    self.tabBarController.tabBar.backgroundColor = [UIColor colorWithHue:0.6 saturation:0.15 brightness:1 alpha:1];
    self.view.backgroundColor = [UIColor colorWithHue:0.6 saturation:0.15 brightness:1 alpha:1];
}



// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"postDetails"])
    {
        UINavigationController *navController = [segue destinationViewController];
        PostDetailsViewController *postDetailsVC = (PostDetailsViewController *)navController.topViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        postDetailsVC.post = self.postArray[indexPath.row];
    }
}

- (void)fetchPostsWithQuery
{
    self.postArray = [APIManager fetchPostswithTableView:self.tableView andRefresh:self.refreshControl];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    cell.post = self.postArray[indexPath.row];
    cell.homeVC = self;
    cell.tableView = self.tableView;
    [cell setPost];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.postArray.count;
}


@end
