//
//  GymPointAnnotation.h
//  GymBro
//
//  Created by Eric Moran on 7/11/22.
//

#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GymPointAnnotation : MKPointAnnotation

@property (strong, nonatomic) NSDictionary *gym;

@end

NS_ASSUME_NONNULL_END
