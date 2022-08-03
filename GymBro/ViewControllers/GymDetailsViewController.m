//
//  GymDetailsViewController.m
//  GymBro
//
//  Created by Eric Moran on 7/11/22.
//

#import "GymDetailsViewController.h"
#import "Parse/Parse.h"
#import "../Models/UserCell.h"
#import "../API/APIManager.h"

@interface GymDetailsViewController () <UITableViewDelegate, UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *gymName;
@property (weak, nonatomic) IBOutlet UIImageView *gymPhotosView;

@property (strong, nonatomic) NSMutableArray *userArray;

@property (strong, nonatomic) NSMutableArray *gymPhotos;
@property (nonatomic) NSInteger index;
@property (strong, nonatomic) NSTimer *timer;

- (IBAction)selectGym:(id)sender;


@end

@implementation GymDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 100;
    
    self.userArray = [[NSMutableArray alloc] init];
    self.gymName.text = [self.gym valueForKeyPath:@"name"];
    [self.tableView reloadData];
    [self fetchPhotosWithQuery];
    [self fetchUsersWithQuery];
    self.timer = [NSTimer scheduledTimerWithTimeInterval: 3.0
                                                  target: self
                                                selector:@selector(setGymPhotos)
                                                userInfo: nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.timer invalidate];
}

- (void)setGymPhotos {
    if (self.index == self.gymPhotos.count - 1)
    {
        self.index = 0;
    }
    else
    {
        self.index++;
    }
    NSString *currPhoto = [self.gymPhotos objectAtIndex:self.index];
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:currPhoto]];
    self.gymPhotosView.image = [UIImage imageWithData:imageData];
}

- (void)fetchUsersWithQuery
{
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" notEqualTo:user[@"username"]];
    [query whereKey:@"gymID" equalTo:[self.gym valueForKeyPath:@"fsq_id"]];
    query.limit = 100;
    [query orderByDescending:@"createdAt"];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            self.userArray = users;
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)fetchPhotosWithQuery
{
    NSString *fsq_id = [self.gym valueForKeyPath:@"fsq_id"];
    NSDictionary *headers = @{ @"Accept": @"application/json",
                               @"Authorization": @"fsq34hUP8/Fm3u/fGWnAv/jMBKdyEQIlaf+ueJvtD52Wn8o=" };
    NSString *requestString = [NSString stringWithFormat:@"https://api.foursquare.com/v3/places/%@/photos?limit=20", fsq_id];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            NSDictionary *photos = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            self.gymPhotos = [[NSMutableArray alloc] init];
            for (NSDictionary *photo in photos)
            {
                NSString *prefix = [photo valueForKeyPath:@"prefix"];
                NSString *suffix = [photo valueForKeyPath:@"suffix"];
                [self.gymPhotos addObject:[NSString stringWithFormat:@"%@original%@", prefix, suffix]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setGymPhotos];
            });
        }
    }];
    [dataTask resume];
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


- (IBAction)selectGym:(id)sender {
    PFUser *user = [PFUser currentUser];
    user[@"gymID"] = [self.gym valueForKeyPath:@"fsq_id"];
    user[@"gym"] = self.gym;
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success!"
                                                                           message:@"Successfully Selected Gym"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                 {}];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:^{
                [self.delegate displayInfo];
            }];
            
        }
        else
        {
            NSLog(@"Error Saving Profile: %@", error.localizedDescription);
        }
    }];
}
@end
