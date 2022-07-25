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

+ (void)commentWithText:(NSString *)text withParent:(Post *)parent withCompletion:(PFBooleanResultBlock)completion
{
    Comment *newPost = [Comment new];
    newPost.author = [[PFUser currentUser] valueForKeyPath:@"username"];
    newPost.text = text;
//    newPost.parent = parent;
    newPost.likeCount = @(0);
    
    [newPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            NSMutableArray *parentComments = [[NSMutableArray alloc] initWithArray:parent[@"comments"]];
            [parentComments addObject:newPost];
            parent.comments = parentComments;
            parent.commentCount = @(parentComments.count);
            [parent saveInBackground];
        }
        else
        {
            NSLog(@"ERROR: %@", error.localizedDescription);
        }
    }];
}


+ (nonnull NSString *)parseClassName {
    return @"Comment";
}

@end
