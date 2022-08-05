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
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithHue:0.58 saturation:0.40 brightness:0.66 alpha:1];
    self.tabBarController.tabBar.backgroundColor = [UIColor colorWithHue:0.6 saturation:0.66 brightness:0.66 alpha:1];
//    self.view.backgroundColor = [UIColor colorWithHue:0.6 saturation:0.66 brightness:0.66 alpha:1];
    UIImage *friendsIcon = [UIImage imageNamed:@"friends.png"];
    friendsIcon = [APIManager resizeImage:friendsIcon withSize:CGSizeMake(50, 50)];
    [self.friendsButton setTitle:@"" forState:UIControlStateNormal];
    [self.friendsButton setImage:friendsIcon forState:UIControlStateNormal];
    
    UIImage *composeIcon = [UIImage imageNamed:@"compose.png"];
    composeIcon = [APIManager resizeImage:composeIcon withSize:CGSizeMake(50, 50)];
    [self.composeButton setTitle:@"" forState:UIControlStateNormal];
    [self.composeButton setImage:composeIcon forState:UIControlStateNormal];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.postArray = [APIManager fetchPostswithTableView:self.tableView andRefresh:self.refreshControl];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchPostsWithQuery) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
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
    cell.hasBeenLiked = NO;
    for (Post *post in cell.post[@"likedPosts"])
    {
        if ([cell.post isEqual:post])
        {
            cell.hasBeenLiked = YES;
        }
    }
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
