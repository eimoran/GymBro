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
#import "../Models/Comment.h"


@interface PostDetailsViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *commentArray;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (strong, nonatomic) PFUser *currUser;

@property (strong, nonatomic) UIRefreshControl *refreshControl;
- (IBAction)goHome:(id)sender;
- (IBAction)comment:(id)sender;


@end

@implementation PostDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.currUser = [PFUser currentUser];
    self.commentTextView.delegate = self;
    self.commentTextView.text = @"Write a Comment";
    self.commentTextView.textColor = [UIColor lightGrayColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"header"];
    
    [self fetchComments];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchComments) forControlEvents:UIControlEventValueChanged];
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

NSInteger intSort(id num1, id num2, void* context)
{
    int v1 = [num1[@"likeCount"] intValue];
    int v2 = [num2[@"likeCount"] intValue];
    if (v1 < v2)
        return NSOrderedAscending;
    else if (v1 > v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

- (void)fetchComments
{
    __block NSArray *comments = [[NSArray alloc] init];
    self.commentArray = [[NSMutableArray alloc] init];
    [self.post fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [self.tableView reloadData];
        PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
        [query orderByAscending:@"likeCount"];
        query.limit = 100;
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            comments = objects;
            NSLog(@"%@", objects);
            NSArray *postComments = [[NSArray alloc] initWithArray:self.post[@"comments"]];
            NSLog(@"POST COMMENTS: %@", postComments);
            for (Comment *comment in comments)
            {
                for (Comment *postComment in postComments)
                {
                    if ([comment.objectId isEqual:postComment.objectId])
                    {
                        NSLog(@"COMMENT: %@", comment);
                        [self.commentArray addObject:comment];
                    }
                }
            }
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Post has photo
    tableView.rowHeight = UITableViewAutomaticDimension;
    if ([[self.post valueForKeyPath:@"photoExists"] isEqual: @1])
    {
        if (indexPath.section == 0 && indexPath.row == 0)
        {
            PostCell *postCell = [tableView dequeueReusableCellWithIdentifier:@"PostCell" forIndexPath:indexPath];
            postCell.post = self.post;
            postCell.tableView = self.tableView;
            [postCell setPost];
            return postCell;
        }
        else if (indexPath.section == 0 && indexPath.row == 1)
        {
//            tableView.rowHeight = 400;
            PostCell *postCell = [tableView dequeueReusableCellWithIdentifier:@"PostCell2" forIndexPath:indexPath];
            postCell.post = self.post;
            postCell.tableView = self.tableView;
            [postCell setPostImage];
            return postCell;
        }
        else
        {
            CommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
            commentCell.comment = self.commentArray[self.commentArray.count - 1 - indexPath.row];
            [commentCell setComment];
            return commentCell;
        }
    }
    // Post doesn't have photo
    else
    {
        if (indexPath.section == 0)
        {
            PostCell *postCell = [tableView dequeueReusableCellWithIdentifier:@"PostCell" forIndexPath:indexPath];
            postCell.post = self.post;
            postCell.tableView = self.tableView;
            [postCell setPost];
            
            return postCell;
            
        }
        else
        {
            Comment *comment = self.commentArray[self.commentArray.count - 1 - indexPath.row];
            CommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
            commentCell.comment = comment;
            [commentCell setComment];
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
    return 15;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Write a Comment"])
    {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Write a Comment";
    }
    [textView resignFirstResponder];
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
                [self fetchComments];
                [self.tableView reloadData];
            }
            else
            {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
        self.commentTextView.text = @"";
    }
}

- (IBAction)goHome:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
