//
//  Post.m
//  GymBro
//
//  Created by Eric Moran on 7/19/22.
//

#import "Post.h"
#import <Parse/Parse.h>

@implementation Post

@dynamic postID;
@dynamic userID;
@dynamic author;
@dynamic text;
@dynamic image;
@dynamic likeCount;
@dynamic commentCount;
@dynamic profilePic;

+ (void) postUserImage: ( UIImage * _Nullable )image withCaption: ( NSString * _Nullable )caption withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Post *newPost = [Post new];
    newPost.image = [self getPFFileFromImage:image];
    newPost.author = [[PFUser currentUser] valueForKeyPath:@"username"];
    newPost.text = caption;
    newPost.likeCount = @(0);
    newPost.commentCount = @(0);
    newPost.photoExists = YES;
    
    [newPost saveInBackgroundWithBlock: completion];
}

+ (void)postWithText:(NSString *)text withCompletion:(PFBooleanResultBlock)completion
{
    Post *newPost = [Post new];
    newPost.author = [[PFUser currentUser] valueForKeyPath:@"username"];
    newPost.text = text;
    newPost.likeCount = @(0);
    newPost.commentCount = @(0);
    newPost.photoExists = NO;
    
    [newPost saveInBackgroundWithBlock: completion];
}

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
 
    // check if image is not nil
    if (!image) {
        return nil;
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}

+ (nonnull NSString *)parseClassName {
    return @"Post";
}

@end
