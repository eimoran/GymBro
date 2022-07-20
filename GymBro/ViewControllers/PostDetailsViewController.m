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
    
    self.commentArray = [[NSMutableArray alloc] init];
    
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
//    self.commentArray = [[NSMutableArray alloc] init];
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

//GET COMMENTS TO WORK
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0)
    {
        PostCell *postCell = [tableView dequeueReusableCellWithIdentifier:@"PostCell" forIndexPath:indexPath];
        postCell.post = self.post;
        [postCell setPost];
        self.tableView.rowHeight = 450;
        return postCell;
    }
    else
    {
        CommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
        commentCell.comment = self.commentArray[indexPath.row-1];
        [commentCell setComment];
        self.tableView.rowHeight = 300;
        return commentCell;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"ROW COUNT: %lu", 1 + self.commentArray.count);
    return 1 + self.commentArray.count;
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
