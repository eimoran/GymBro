//
//  Comment.m
//  GymBro
//
//  Created by Eric Moran on 7/20/22.
//

#import "Comment.h"
#import <Parse/Parse.h>

@implementation Comment

@dynamic commentID;
@dynamic userID;
@dynamic author;
@dynamic text;
@dynamic likeCount;
@dynamic profilePic;
@dynamic parent;

+ (void)postWithText:(NSString *)text withParent:(Post *)parent withCompletion:(PFBooleanResultBlock)completion
{
    Comment *newPost = [Comment new];
    newPost.author = [[PFUser currentUser] valueForKeyPath:@"username"];
    newPost.text = text;
    newPost.parent = parent;
    newPost.likeCount = @(0);
    
    [newPost saveInBackgroundWithBlock: completion];
}


+ (nonnull NSString *)parseClassName {
    return @"Comment";
}

@end
