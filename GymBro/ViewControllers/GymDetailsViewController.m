//
//  GymDetailsViewController.m
//  GymBro
//
//  Created by Eric Moran on 7/11/22.
//

#import "GymDetailsViewController.h"

@interface GymDetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *gymName;
@property (weak, nonatomic) IBOutlet UIImageView *gymPhotosView;
@property (strong, nonatomic) NSMutableArray *gymPhotos;
@property (nonatomic) NSInteger index;
@property (strong, nonatomic) NSTimer *timer;

- (IBAction)selectGym:(id)sender;


@end

@implementation GymDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.gymName.text = [self.gym valueForKeyPath:@"name"];
    [self fetchPhotosWithQuery];
    self.timer = [NSTimer scheduledTimerWithTimeInterval: 2.0
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
    NSLog(@"%@", currPhoto);
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:currPhoto]];
    self.gymPhotosView.image = [UIImage imageWithData:imageData];
    
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
            
            NSLog(@"%@", photos);
            for (NSDictionary *photo in photos)
            {
                NSString *prefix = [photo valueForKeyPath:@"prefix"];
                NSString *suffix = [photo valueForKeyPath:@"suffix"];
                [self.gymPhotos addObject:[NSString stringWithFormat:@"%@original%@", prefix, suffix]];
            }
        }
    }];
    [dataTask resume];
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
    
}
@end
