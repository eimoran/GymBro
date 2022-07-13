//
//  APIManager.h
//  GymBro
//
//  Created by Eric Moran on 7/12/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject

+ (NSMutableArray *)fetchUsersWithQuery:gym;
+ (NSMutableArray *)fetchPhotosWithQuery:gym;



@end

NS_ASSUME_NONNULL_END
