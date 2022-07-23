//
//  PostDetailsViewController.m
//  GymBro
//
//  Created by Eric Moran on 7/20/22.
//

#import "PostDetailsViewController.h"
#import <Parse/Parse.h>
#import "../Models/PostCell.h"
#import "../Models/CommentCell.h"
#import "../Models/Post.h"

@interface PostDetailsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *commentArray;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;

@property (strong, nonatomic) UIRefreshControl *refreshControl;
- (IBAction)goHome:(id)sender;
- (IBAction)comment:(id)sender;


@end

@implementation PostDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"header"];
    
    [self fetchCommentsWithQuery];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchCommentsWithQuery) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)fetchCommentsWithQuery
{
    self.commentArray = [[NSMutableArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query whereKey:@"parent" equalTo:self.post];
    [query includeKey:@"author"];
    [query orderByDescending:@"createdAt"];
    query.limit = 200;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *comments, NSError *error) {
        if (comments != nil) {
            self.commentArray = comments;
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        [self.refreshControl endRefreshing];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.post valueForKeyPath:@"photoExists"] isEqual: @1])
    {
        if (indexPath.section == 0)
        {
            PostCell *postCell = [tableView dequeueReusableCellWithIdentifier:@"PostCell" forIndexPath:indexPath];
            postCell.post = self.post;
            postCell.tableView = self.tableView;
            if (indexPath.row == 0)
            {
                [postCell setPost];
                self.tableView.rowHeight = 450;
            }
            else
            {
                [postCell setPostImage];
                self.tableView.rowHeight = 300;
            }
            return postCell;
        }
        else
        {
            CommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
            commentCell.comment = self.commentArray[indexPath.row];
            [commentCell setComment];
            self.tableView.rowHeight = 300;
            return commentCell;
        }
    }
    else
    {
        if (indexPath.row == 0 && indexPath.section == 0)
        {
            PostCell *postCell = [tableView dequeueReusableCellWithIdentifier:@"PostCell" forIndexPath:indexPath];
            postCell.post = self.post;
            postCell.tableView = self.tableView;
            [postCell setPost];
            self.tableView.rowHeight = 300;
            return postCell;
        }
        else
        {
            CommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
            commentCell.comment = self.commentArray[indexPath.row];
            [commentCell setComment];
            self.tableView.rowHeight = 300;
            return commentCell;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        if ([self.post[@"photoExists"] isEqual: @1])
        {
            return 2;
        }
        return 1;
    }
    else
    {
        return self.commentArray.count;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    
    if (section == 0)
    {
        header.textLabel.text = @"Original Post";
    }
    if (section == 1)
    {
        header.textLabel.text = @"Comments";
    }
    
    header.textLabel.textColor = [UIColor blackColor];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (IBAction)comment:(id)sender {
    if (self.commentTextView.text.length == 0)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Comment"
                                     message:@"Please Type Something To Comment"
                                     preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
         {}];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        [Comment postWithText:self.commentTextView.text withParent:self.post withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (!error)
            {
                [self fetchCommentsWithQuery];
            }
            else
            {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
    
}

- (IBAction)goHome:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
