//
//  Comment.h
//  GymBro
//
//  Created by Eric Moran on 7/20/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface Comment : PFObject<PFSubclassing>

@property (strong, nonatomic) NSString *commentID;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) Post *parent;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSNumber *likeCount;
@property (strong, nonatomic) NSString *profilePic;

+ (void) commentWithText: (NSString * _Nullable)text withParent: (Post *)parent withCompletion: (PFBooleanResultBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
