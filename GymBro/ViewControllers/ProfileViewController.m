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
#import "GymDetailsViewController.h"
#import "Parse/Parse.h"
#import <CoreLocation/CoreLocation.h>
#import "MapKit/MapKit.h"
#import "../AppDelegate.h"

static NSString * const clientID = @"ZQHYEONNNHSSRVKTPJLCMNP3IUBUHIEWLYM4O5ROWKEPZPJZ";
static NSString * const clientSecret = @"43SDDVTODTHINIW24OO4J1OK3QCZGSP1DEC53IQMZMXDXAHD";

@interface ProfileViewController () <ProfileFormViewControllerDelegate, GymDetailsViewControllerDelegate, CLLocationManagerDelegate>

- (IBAction)updateInfo:(id)sender;
- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size;


@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKPointOfInterestFilter *filter;
@property (strong, nonatomic) NSMutableArray *gyms;
@property (strong, nonatomic) NSString *lat;
@property (strong, nonatomic) NSString *lon;

@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (strong, nonatomic) IBOutlet UILabel *workoutTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *workoutTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (strong, nonatomic) IBOutlet UILabel *gymLabel;

@property (strong, nonatomic) NSDictionary *currGym;

- (IBAction)logout:(id)sender;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [self.locationManager requestWhenInUseAuthorization];
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
                UIImageView *iconView = [[UIImageView alloc] initWithImage:[self imageWithImage:[UIImage imageNamed:@"dumbbell.png"] convertToSize:size]];
                            pinView.leftCalloutAccessoryView = iconView;
                pinView.canShowCallout = YES;
                 
                pinView.image = [self imageWithImage:[UIImage imageNamed:@"dumbbell.png"] convertToSize:size];
                
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

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}



- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [locations lastObject];
    self.lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    self.lon = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    MKCoordinateRegion userRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), MKCoordinateSpanMake(0.05, 0.05));
    [self.mapView setRegion:userRegion animated:false];
    
    [self fetchLocationsWithQuery:self.lat longitude:self.lon];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error.localizedDescription);
}

- (void)fetchLocationsWithQuery:lat longitude:lon{
    NSDictionary *headers = @{ @"Accept": @"application/json",
                               @"Authorization": @"fsq34hUP8/Fm3u/fGWnAv/jMBKdyEQIlaf+ueJvtD52Wn8o=" };
    NSString *queryString = [NSString stringWithFormat:@"https://api.foursquare.com/v3/places/search?&ll=%@,%@&radius=50000&categories=18021", lat, lon];
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
            self.gyms = [[NSMutableArray alloc] init];
            for (NSDictionary *gym in [responseDictionary valueForKeyPath:@"results"])
            {
                [self.gyms addObject:gym];
                GymPointAnnotation *annotation = [[GymPointAnnotation alloc] init];
                double latitude = [[gym valueForKeyPath:@"geocodes.main.latitude"] doubleValue];
                double longitude = [[gym valueForKeyPath:@"geocodes.main.longitude"] doubleValue];
                annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                annotation.title = [gym valueForKeyPath:@"name"];
                annotation.gym = gym;
                
                
                [self.mapView addAnnotation:annotation];
            }
        }
    }];
    [dataTask resume];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self displayInfo];
}


- (void)displayInfo
{
    PFUser *user = [PFUser currentUser];
    self.welcomeLabel.text = [NSString stringWithFormat:@"Welcome, %@!", user[@"username"]];
    self.workoutTypeLabel.text = [NSString stringWithFormat:@"Workout Split: %@", user[@"workoutSplit"]];
    self.workoutTimeLabel.text = [NSString stringWithFormat:@"Time you workout: %@", user[@"workoutTime"]];
    self.genderLabel.text = [NSString stringWithFormat:@"Gender: %@", user[@"gender"]];
    self.levelLabel.text = [NSString stringWithFormat:@"Level: %@", user[@"level"]];
    self.gymLabel.text = [NSString stringWithFormat:@"Local Gym: %@", [user[@"gym"] valueForKeyPath:@"name"]];
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
    
}


- (IBAction)updateInfo:(id)sender {
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
@end


