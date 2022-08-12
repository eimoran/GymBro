//
//  ProfileViewController.m
//  GymBro
//
//  Created by Eric Moran on 7/5/22.
//

#import "ProfileViewController.h"
#import "ProfileFormViewController.h"
#import "LoginViewController.h"
#import "../Models/GymPointAnnotation.h"
#import "../Models/GymDetailsButton.h"
#import "../Models/SearchBarCell.h"
#import "../Models/Post.h"
#import "GymDetailsViewController.h"
#import "Parse/Parse.h"
#import <CoreLocation/CoreLocation.h>
#import "UIImageView+AFNetworking.h"
#import "MapKit/MapKit.h"
#import "../AppDelegate.h"
#import "../API/APIManager.h"

static NSString * const clientID = @"ZQHYEONNNHSSRVKTPJLCMNP3IUBUHIEWLYM4O5ROWKEPZPJZ";
static NSString * const clientSecret = @"43SDDVTODTHINIW24OO4J1OK3QCZGSP1DEC53IQMZMXDXAHD";

@interface ProfileViewController () <ProfileFormViewControllerDelegate, GymDetailsViewControllerDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKPointOfInterestFilter *filter;
@property (strong, nonatomic) NSMutableArray *gyms;
@property (strong, nonatomic) NSMutableArray *searchBarGyms;
@property (strong, nonatomic) NSString *lat;
@property (strong, nonatomic) NSString *lon;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (strong, nonatomic) IBOutlet UILabel *workoutTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *workoutTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (strong, nonatomic) IBOutlet UILabel *gymLabel;

@property (strong, nonatomic) NSDictionary *currGym;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *postCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendCountLabel;

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;
@property (strong, nonatomic) PFUser *currUser;

@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

- (IBAction)logout:(id)sender;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.currUser = [PFUser currentUser];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 00, 30)];
    titleLabel.text = self.currUser[@"username"];
    titleLabel.font = [UIFont fontWithName:@"Menlo Bold" size:20];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    self.postCountLabel.text = [NSString stringWithFormat:@"%lu", [APIManager fetchPostCountOfUser:self.currUser]];
    
    NSArray *currUserFriends = self.currUser[@"friends"];
    self.friendCountLabel.text = [NSString stringWithFormat:@"%lu", currUserFriends.count];
    
    UIImage *logoutIcon = [UIImage imageNamed:@"logout.png"];
    logoutIcon = [APIManager resizeImage:logoutIcon withSize:CGSizeMake(45, 45)];
    [self.logoutButton setTitle:@"" forState:UIControlStateNormal];
    [self.logoutButton setImage:logoutIcon forState:UIControlStateNormal];
    
    UIImage *editProfileIcon = [UIImage imageNamed:@"edit.png"];
    editProfileIcon = [APIManager resizeImage:editProfileIcon withSize:CGSizeMake(45, 45)];
    [self.editProfileButton setTitle:@"" forState:UIControlStateNormal];
    [self.editProfileButton setImage:editProfileIcon forState:UIControlStateNormal];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    self.searchBar.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.hidden = YES;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [self.locationManager requestWhenInUseAuthorization];
    
    UITapGestureRecognizer *profileImageChange = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseProfilePic)];
    [profileImageChange setDelegate:self];
    [self.profileImageView addGestureRecognizer:profileImageChange];
    
    self.searchBar.delegate = self;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    [nc addObserver:self selector:@selector(keyboardWillShow:) name:
    UIKeyboardWillShowNotification object:nil];

    [nc addObserver:self selector:@selector(keyboardWillHide:) name:
    UIKeyboardWillHideNotification object:nil];

    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
    action:@selector(didTapAnywhere:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHue:0.3 saturation:0.15 brightness:1 alpha:1];
    self.view.backgroundColor = [UIColor colorWithHue:0.3 saturation:0.15 brightness:1 alpha:1];
    
    self.tabBarController.tabBar.barTintColor = [UIColor colorWithHue:0.3 saturation:0.15 brightness:1 alpha:1];
    self.tabBarController.tabBar.backgroundColor = [UIColor colorWithHue:0.3 saturation:0.15 brightness:1 alpha:1];
    UIView *topBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, self.view.frame.size.width)];
    [self.view insertSubview:topBackground atIndex:0];
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2.0;
}

- (void)chooseProfilePic
{
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    self.profileImageView.image = info[UIImagePickerControllerOriginalImage];
    
    CGSize size = CGSizeMake(500, 500);
    self.profileImageView.image = [APIManager resizeImage:self.profileImageView.image withSize:size];
    self.currUser[@"profilePic"] = [Post getPFFileFromImage:self.profileImageView.image];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [[PFUser currentUser] saveInBackground];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(nonnull NSString *)searchText
{
    if (searchText.length < 3)
    {
        self.tableView.hidden = YES;
    }
    else
    {
        self.tableView.hidden = NO;
        self.searchBarGyms = [[NSMutableArray alloc] init];
        NSDictionary *headers = @{ @"Accept": @"application/json",
                                   @"Authorization": @"fsq34hUP8/Fm3u/fGWnAv/jMBKdyEQIlaf+ueJvtD52Wn8o=" };

        NSString *queryString = [NSString stringWithFormat:@"https://api.foursquare.com/v3/autocomplete?query=%@&ll=%@,%@&types=place&limit=20", searchText, self.lat, self.lon];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:queryString]
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
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                self.searchBarGyms = [[NSMutableArray alloc] init];
                for (NSDictionary *gym in [responseDictionary valueForKeyPath:@"results.place"])
                {
                    NSArray *gymID = [gym valueForKeyPath:@"categories.id"];
                    if (gymID.count > 0)
                    {
                        if ([[gym valueForKeyPath:@"categories.id"][0] isEqual:@18021])
                        {
                            [self.searchBarGyms addObject:gym];
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }];
        [dataTask resume];
    }
}

- (void)buttonTouchDown:(GymDetailsButton *)sender
{
    self.currGym = sender.gym;
    [self performSegueWithIdentifier:@"gymDetails" sender:nil];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(GymPointAnnotation *)annotation {
    
    // If it's the user location, just return nil.
        if ([annotation isKindOfClass:[MKUserLocation class]])
            return nil;
        
        // Handle any custom annotations.
        if ([annotation isKindOfClass:[MKPointAnnotation class]])
        {
            // Try to dequeue an existing pin view first.
            MKAnnotationView *pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
            if (!pinView)
            {
                // If an existing pin view was not available, create one.
                pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
                
                
                GymDetailsButton* rightButton = [GymDetailsButton buttonWithType:UIButtonTypeDetailDisclosure];
                pinView.rightCalloutAccessoryView = rightButton;
                [rightButton addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
                rightButton.gym = annotation.gym;
                
                
                CGSize size = CGSizeMake(20, 20);
                UIImageView *iconView = [[UIImageView alloc] initWithImage:[APIManager imageWithImage:[UIImage imageNamed:@"dumbbell.png"] convertToSize:size]];
                            pinView.leftCalloutAccessoryView = iconView;
                pinView.canShowCallout = YES;
                 
                pinView.image = [APIManager imageWithImage:[UIImage imageNamed:@"dumbbell.png"] convertToSize:size];
                
                pinView.calloutOffset = CGPointMake(0, 32);
            }
            
            else
            {
                pinView.annotation = annotation;
            }
            return pinView;
        }
        return nil;
 }

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager
{
    if (manager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse || manager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways)
    {
        [manager requestLocation];
    }
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [locations lastObject];
    self.lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    self.lon = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    MKCoordinateRegion userRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), MKCoordinateSpanMake(0.05, 0.05));
    [self.mapView setRegion:userRegion animated:false];
    
    self.gyms = [APIManager fetchLocationsWithLat:self.lat Lon:self.lon Map:self.mapView];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error.localizedDescription);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    SearchBarCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchBarCell"];
    cell.gym = self.searchBarGyms[indexPath.row];
    [cell setInfo];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchBarGyms.count;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currGym = self.searchBarGyms[indexPath.row];
    [self performSegueWithIdentifier:@"gymDetails" sender:nil];
}


- (void)viewDidAppear:(BOOL)animated
{
    [self displayInfo];
}


- (void)displayInfo
{
    PFUser *user = [PFUser currentUser];
    PFFileObject *pic = user[@"profilePic"];
    
    NSURL *url = [NSURL URLWithString:pic.url];
    
    if (pic)
    {
        [self.profileImageView setImageWithURL:url];
    }
    
    self.workoutTypeLabel.text = [NSString stringWithFormat:@"Workout Split: %@", user[@"workoutSplit"]];
    NSMutableAttributedString *postText = [[NSMutableAttributedString alloc] initWithString:self.workoutTypeLabel.text];
    NSRange boldRange = [self.workoutTypeLabel.text rangeOfString:@"Workout Split: "];
    [postText addAttribute: NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:boldRange];
    [self.workoutTypeLabel setAttributedText: postText];
    
    self.bioLabel.text = [NSString stringWithFormat:@"Bio: %@", user[@"bio"]];
    NSMutableAttributedString *postText2 = [[NSMutableAttributedString alloc] initWithString:self.bioLabel.text];
    NSRange boldRange2 = [self.bioLabel.text rangeOfString:@"Bio: "];
    [postText2 addAttribute: NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:boldRange2];
    [self.bioLabel setAttributedText: postText2];
    
    self.workoutTimeLabel.text = [NSString stringWithFormat:@"Time You Workout: %@", user[@"workoutTime"]];
    NSMutableAttributedString *postText3 = [[NSMutableAttributedString alloc] initWithString:self.workoutTimeLabel.text];
    NSRange boldRange3 = [self.workoutTimeLabel.text rangeOfString:@"Time You Workout: "];
    [postText3 addAttribute: NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:boldRange3];
    [self.workoutTimeLabel setAttributedText: postText3];
    
    self.genderLabel.text = [NSString stringWithFormat:@"Gender: %@", user[@"gender"]];
    NSMutableAttributedString *postText4 = [[NSMutableAttributedString alloc] initWithString:self.genderLabel.text];
    NSRange boldRange4 = [self.genderLabel.text rangeOfString:@"Gender: "];
    [postText4 addAttribute: NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:boldRange4];
    [self.genderLabel setAttributedText: postText4];
    
    self.levelLabel.text = [NSString stringWithFormat:@"Level: %@", user[@"level"]];
    NSMutableAttributedString *postText5 = [[NSMutableAttributedString alloc] initWithString:self.levelLabel.text];
    NSRange boldRange5 = [self.levelLabel.text rangeOfString:@"Level: "];
    [postText5 addAttribute: NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:boldRange5];
    [self.levelLabel setAttributedText: postText5];
    
    if (!user[@"gym"])
    {
        self.gymLabel.text = [NSString stringWithFormat:@"Local Gym: n/a"];
    }
    else
    {
        self.gymLabel.text = [NSString stringWithFormat:@"Local Gym: %@", [user[@"gym"] valueForKeyPath:@"name"]];
    }
    NSMutableAttributedString *postText6 = [[NSMutableAttributedString alloc] initWithString:self.gymLabel.text];
    NSRange boldRange6 = [self.gymLabel.text rangeOfString:@"Local Gym: "];
    [postText6 addAttribute: NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:boldRange6];
    [self.gymLabel setAttributedText: postText6];
}



// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"gymDetails"])
    {
        UINavigationController *navController = [segue destinationViewController];
        GymDetailsViewController *detailsVC = navController.topViewController;
        detailsVC.gym = self.currGym;
        detailsVC.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"profileForm"])
    {
        UINavigationController *navigationController = [segue destinationViewController];
        ProfileFormViewController *formController = (ProfileFormViewController*)navigationController.topViewController;
        formController.delegate = self;
    }
    else if ([segue.identifier isEqual:@"Activity"])
    {
        UINavigationController *navVC = [segue destinationViewController];
        
    }
    
}


- (IBAction)logout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if (!error)
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            self.view.window.rootViewController = loginVC;
        }
    }];
}


-(void)didTapAnywhere: (UITapGestureRecognizer*) recognizer {
    [self.view endEditing:YES];
}

-(void) keyboardWillShow:(NSNotification *) note {
    [self.view addGestureRecognizer:self.tapRecognizer];
}

-(void) keyboardWillHide:(NSNotification *) note
{
    [self.view removeGestureRecognizer:self.tapRecognizer];
}
@end


