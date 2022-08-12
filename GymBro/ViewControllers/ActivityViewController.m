//
//  ActivityViewController.m
//  GymBro
//
//  Created by Eric Moran on 8/11/22.
//

#import "ActivityViewController.h"
#import "../API/APIManager.h"
#import "../Models/PostCell.h"
#import "PostDetailsViewController.h"

@interface ActivityViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *postArray;
@property (strong, nonatomic) NSMutableArray *likedPostArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
- (IBAction)goBack:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
- (IBAction)changeSection:(id)sender;

@end

@implementation ActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self fetchPostsAndLikes];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Your Activity";
    titleLabel.font = [UIFont fontWithName:@"Menlo Bold" size:20];
    self.navigationItem.titleView = titleLabel;
    
    UIImage *backIcon = [UIImage imageNamed:@"back.png"];
    backIcon = [APIManager resizeImage:backIcon withSize:CGSizeMake(40,30)];
    [self.backButton setTitle:@"" forState:UIControlStateNormal];
    [self.backButton setImage:backIcon forState:UIControlStateNormal];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchPostsAndLikes) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"postDetails"])
    {
        UINavigationController *navController = [segue destinationViewController];
        PostDetailsViewController *postDetailsVC = (PostDetailsViewController *)navController.topViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (self.segmentedControl.selectedSegmentIndex == 0)
        {
            postDetailsVC.post = self.postArray[indexPath.row];
        }
        else
        {
            postDetailsVC.post = self.likedPostArray[indexPath.row];
        }
    }
}


- (void)fetchPostsAndLikes
{
    self.postArray = [[NSMutableArray alloc] init];
    self.postArray = [APIManager fetchPostsOfUser:[PFUser currentUser]];
    self.likedPostArray = [[NSMutableArray alloc] init];
    self.likedPostArray = [PFUser currentUser][@"likedPosts"];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
            cell.post = self.postArray[indexPath.row];
            cell.tableView = self.tableView;
            [cell setPost];
            break;
        case 1:
            cell.post = self.likedPostArray[indexPath.row];
            cell.tableView = self.tableView;
            [cell setPost];
            break;
    }
    
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
            return self.postArray.count;
            break;
        case 1:
            return self.likedPostArray.count;
            break;
    }
    return self.postArray.count;
}

- (IBAction)changeSection:(id)sender {
    [self.tableView reloadData];
}

- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
