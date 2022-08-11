//
//  ProfileFormCell.m
//  GymBro
//
//  Created by Eric Moran on 8/5/22.
//

#import "ProfileFormCell.h"

@interface ProfileFormCell () <UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *picker;

@end

@implementation ProfileFormCell 

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    if ([self.reuseIdentifier isEqual:@"ProfileFormBio"])
    {
        self.bioTextView.delegate = self;
    }
    else
    {
        self.picker.delegate = self;
        self.picker.dataSource = self;
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.controller.bio = self.bioTextView.text;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    /* for backspace */
    if([text length] == 0){
        return YES;
    }
    
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    if (newLength > 260)
    {
        return NO;
    }
    
    return YES;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
    
}

- (NSInteger)pickerView:(UIPickerView *)picker numberOfRowsInComponent:(NSInteger)component {
    if ([self.reuseIdentifier isEqual:@"ProfileFormSplit"])
    {
        return 7;
    }
    else if ([self.reuseIdentifier isEqual:@"ProfileFormTime"])
    {
        return 4;
    }
    else if ([self.reuseIdentifier isEqual:@"ProfileFormGender"])
    {
        return 2;
    }
    else if ([self.reuseIdentifier isEqual:@"ProfileFormLevel"])
    {
        return 3;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString * title = nil;
    if ([self.reuseIdentifier isEqual:@"ProfileFormSplit"])
    {
        switch(row) {
            case 0:
                title = @"Whole Body Split";
                break;
            case 1:
                title = @"Upper/Lower Body Split";
                break;
            case 2:
                title = @"Push/Pull/Legs";
                break;
            case 3:
                title = @"Four Day Split";
                break;
            case 4:
                title = @"Five Day Split";
                break;
            case 5:
                title = @"Yoga";
                break;
            case 6:
                title = @"Other";
                break;
        }
    }
    else if ([self.reuseIdentifier isEqual:@"ProfileFormTime"])
    {
        switch(row) {
            case 0:
                title = @"Morning (6am - 12pm)";
                break;
            case 1:
                title = @"Afternoon (12 - 5pm)";
                break;
            case 2:
                title = @"Evening (5 - 9pm)";
                break;
            case 3:
                title = @"Late Night (past 9pm)";
                break;
        }
    }
    else if ([self.reuseIdentifier isEqual:@"ProfileFormGender"])
    {
        switch(row) {
            case 0:
                title = @"Male";
                break;
            case 1:
                title = @"Female";
                break;
        }
    }
    else if ([self.reuseIdentifier isEqual:@"ProfileFormLevel"])
    {
        switch(row) {
            case 0:
                title = @"Novice";
                break;
            case 1:
                title = @"Intermediate";
                break;
            case 2:
                title = @"Advanced";
                break;
        }
    }
    
    return title;
}

- (void)pickerView:(UIPickerView *)picker
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    if ([self.reuseIdentifier isEqual:@"ProfileFormSplit"])
    {
        switch(row) {
            case 0:
                self.controller.split = @"Whole Body Split";
                break;
            case 1:
                self.controller.split = @"Upper And Lower Body Split";
                break;
            case 2:
                self.controller.split = @"Push/Pull/Legs";
                break;
            case 3:
                self.controller.split = @"Four Day Split";
                break;
            case 4:
                self.controller.split = @"Five Day Split";
                break;
            case 5:
                self.controller.split = @"Yoga";
                break;
            case 6:
                self.controller.split = @"Other";
                break;
        }
    }
    else if ([self.reuseIdentifier isEqual:@"ProfileFormTime"])
    {
        switch(row) {
            case 0:
                self.controller.time = @"Morning (6am - 12pm)";
                break;
            case 1:
                self.controller.time = @"Afternoon (12 - 5pm)";
                break;
            case 2:
                self.controller.time = @"Evening (5 - 9pm)";
                break;
            case 3:
                self.controller.time = @"Late Night (past 9pm)";
                break;
        }
    }
    else if ([self.reuseIdentifier isEqual:@"ProfileFormGender"])
    {
        switch(row) {
            case 0:
                self.controller.gender = @"Male";
                break;
            case 1:
                self.controller.gender = @"Female";
                break;
        }
    }
    else if ([self.reuseIdentifier isEqual:@"ProfileFormLevel"])
    {
        switch(row) {
            case 0:
                self.controller.level = @"Novice";
                break;
            case 1:
                self.controller.level = @"Intermediate";
                break;
            case 2:
                self.controller.level = @"Advanced";
                break;
        }
    }
}

- (void)setTraits
{
    if ([self.reuseIdentifier isEqual:@"ProfileFormSplit"])
    {
        [self.picker selectRow:self.traitValue inComponent:0 animated:YES];
    }
    else if ([self.reuseIdentifier isEqual:@"ProfileFormTime"])
    {
        [self.picker selectRow:self.traitValue inComponent:0 animated:YES];
    }
    else if ([self.reuseIdentifier isEqual:@"ProfileFormGender"])
    {
        [self.picker selectRow:self.traitValue inComponent:0 animated:YES];
    }
    else if ([self.reuseIdentifier isEqual:@"ProfileFormLevel"])
    {
        [self.picker selectRow:self.traitValue inComponent:0 animated:YES];
    }
}

@end
