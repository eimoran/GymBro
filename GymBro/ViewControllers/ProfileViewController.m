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
#import "../AppDelegate.h"

static NSString * const clientID = @"ZQHYEONNNHSSRVKTPJLCMNP3IUBUHIEWLYM4O5ROWKEPZPJZ";
static NSString * const clientSecret = @"43SDDVTODTHINIW24OO4J1OK3QCZGSP1DEC53IQMZMXDXAHD";

@interface ProfileViewController () <ProfileFormViewControllerDelegate, CLLocationManagerDelegate>

- (IBAction)updateInfo:(id)sender;
- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size;


@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKPointOfInterestFilter *filter;
@property (strong, nonatomic) NSMutableArray *gyms;
@property (strong, nonatomic) NSString *lat;
@property (strong, nonatomic) NSString *lon;

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
    
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
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
                //pinView.animatesDrop = YES;
                pinView.canShowCallout = YES;
                CGSize size = CGSizeMake(20, 20);
                pinView.image = [self imageWithImage:[UIImage imageNamed:@"dumbbell.png"] convertToSize:size];
//                pinView.image = imageWithImage [UIImage imageNamed:@"dumbbell.png"];
                
                pinView.calloutOffset = CGPointMake(0, 32);
            } else {
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
//        NSLog(@"AUTHORIZED");
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
//    NSLog(@"UPDATED LOCATION");
    CLLocation *location = [locations lastObject];
    NSLog(@"lat%f - lon%f", location.coordinate.latitude, location.coordinate.longitude);
    self.lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    self.lon = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    NSLog(@"%@,%@", self.lat, self.lon);
    MKCoordinateRegion sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), MKCoordinateSpanMake(0.05, 0.05));
    [self.mapView setRegion:sfRegion animated:false];
    
    [self fetchLocationsWithQuery];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error.localizedDescription);
}

- (void)fetchLocationsWithQuery {
    NSDictionary *headers = @{ @"Accept": @"application/json",
                               @"Authorization": @"fsq34hUP8/Fm3u/fGWnAv/jMBKdyEQIlaf+ueJvtD52Wn8o=" };
    NSString *queryString = [NSString stringWithFormat:@"https://api.foursquare.com/v3/places/search?&ll=%@,%@&radius=10000&categories=18021", self.lat, self.lon];
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
//                                                        NSLog(@"response: %@", responseDictionary);
                                                        self.gyms = [[NSMutableArray alloc] init];
                                                        for (NSDictionary *gym in [responseDictionary valueForKeyPath:@"results"])
                                                        {
                                                            [self.gyms addObject:gym];
                                                            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                                                            double latitude = [[gym valueForKeyPath:@"geocodes.main.latitude"] doubleValue];
                                                            double longitude = [[gym valueForKeyPath:@"geocodes.main.longitude"] doubleValue];
                                                            annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                                                            annotation.title = [gym valueForKeyPath:@"name"];
                                                            
                                                            
                                                            [self.mapView addAnnotation:annotation];
                                                        }
                                                    }
                                                }];
    [dataTask resume];
    
    
}


//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id )annotation
//{
//    NSLog(@"VIEWFORANNOTATION");
//    // If it's the user location, just return nil.
//    if ([annotation isKindOfClass:[MKUserLocation class]])
//        return nil;
//
//    // Handle any custom annotations.
//    if ([annotation isKindOfClass:[MKPointAnnotation class]])
//    {
//        // Try to dequeue an existing pin view first.
//        MKAnnotationView *pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
//        pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
//        //pinView.animatesDrop = YES;
//        NSLog(@"NEW PIN");
//        pinView.image = [UIImage imageNamed:@"809670_body building_fitness_sports_weight_icon"];
//        pinView.canShowCallout = YES;
//        pinView.calloutOffset = CGPointMake(0, 32);
////        if (!pinView)
////        {
////            // If an existing pin view was not available, create one.
////            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
////            //pinView.animatesDrop = YES;
////            NSLog(@"NEW PIN");
////            pinView.image = [UIImage imageNamed:@"809670_body building_fitness_sports_weight_icon"];
////            pinView.canShowCallout = YES;
////            pinView.calloutOffset = CGPointMake(0, 32);
////        } else {
////            pinView.annotation = annotation;
////        }
//        return pinView;
//    }
//    return nil;
//}

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
}

@end


