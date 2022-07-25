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
    self.commentArray = self.post.comments;
    NSLog(@"COMMENTS %@:", self.commentArray);
    for (Comment *comment in self.commentArray)
    {
        [comment fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            [self.tableView reloadData];
            if (self.commentArray.count == self.post.comments.count)
            {
                [self.tableView reloadData];
            }
        }];
    }
    [self.refreshControl endRefreshing];
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
            Comment *comment = self.commentArray[self.commentArray.count - 1 - indexPath.row];
            CommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
            [comment fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                commentCell.comment = comment;
                [commentCell setComment];
                self.tableView.rowHeight = 300;
            }];
            commentCell.comment = comment;
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
            Comment *comment = self.commentArray[self.commentArray.count - 1 - indexPath.row];
            CommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
            [comment fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                commentCell.comment = comment;
                [commentCell setComment];
                self.tableView.rowHeight = 300;
            }];
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
        [Comment commentWithText:self.commentTextView.text withParent:self.post withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded)
            {
                [self fetchCommentsWithQuery];
                [self.tableView reloadData];
            }
            else
            {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
        [self fetchCommentsWithQuery];
        [self.tableView reloadData];
        NSLog(@"COMMENTS: %@", self.commentArray);
        self.commentTextView.text = @"";
    }
}

- (IBAction)goHome:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
