//
//  ProfileViewController.m
//  GymBro
//
//  Created by Eric Moran on 7/5/22.
//

#import "ProfileViewController.h"
#import "ProfileFormViewController.h"
#import "Parse/Parse.h"
#import <CoreLocation/CoreLocation.h>
#import "MapKit/MapKit.h"

@interface ProfileViewController () <ProfileFormViewControllerDelegate, CLLocationManagerDelegate>

- (IBAction)updateInfo:(id)sender;


@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) IBOutlet UILabel *workoutPlanLabel;
@property (strong, nonatomic) IBOutlet UILabel *workoutTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (strong, nonatomic) IBOutlet UILabel *gymlabel;

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
    [self.locationManager requestLocation];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
     MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
     if (annotationView == nil) {
         annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
         annotationView.canShowCallout = true;
         annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
     }
    
    

    NSLog(@"Here");

     return annotationView;
 }

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [locations lastObject];
    NSLog(@"lat%f - lon%f", location.coordinate.latitude, location.coordinate.longitude);
    MKCoordinateRegion sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), MKCoordinateSpanMake(0.3, 0.3));
    [self.mapView setRegion:sfRegion animated:false];
    
    MKPointAnnotation *annotation = [MKPointAnnotation new];
    annotation.coordinate = location.coordinate;
    annotation.title = @"Picture!";
    NSLog(@"Works");
    [self.mapView addAnnotation:annotation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error.localizedDescription);
}


- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"APPEARED");
    [self displayInfo];
}


- (void)displayInfo
{
    NSLog(@"DISPLAYING INFO");
    PFUser *user = [PFUser currentUser];
    self.workoutPlanLabel.text = [NSString stringWithFormat:@"Workout Split: %@", user[@"workoutSplit"]];
    self.workoutTimeLabel.text = [NSString stringWithFormat:@"Time you workout: %@", user[@"workoutTime"]];
    self.genderLabel.text = [NSString stringWithFormat:@"Gender: %@", user[@"gender"]];
    self.levelLabel.text = [NSString stringWithFormat:@"Level: %@", user[@"level"]];
    
}



// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UINavigationController *navigationController = [segue destinationViewController];
    ProfileFormViewController *formController = (ProfileFormViewController*)navigationController.topViewController;
    formController.delegate = self;
}


- (IBAction)updateInfo:(id)sender {
//    [self performSegueWithIdentifier:@"profileForm" sender:self];
//    [self displayInfo];
}

- (void)updateProfile {
    NSLog(@"UPDATING PROFILE");
    [self displayInfo];
}

@end


