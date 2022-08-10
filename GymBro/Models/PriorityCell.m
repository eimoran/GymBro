//
//  PriorityCell.m
//  GymBro
//
//  Created by Eric Moran on 7/28/22.
//

#import "PriorityCell.h"

@interface PriorityCell () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;
- (IBAction)textChanged:(id)sender;

@end


@implementation PriorityCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.picker.delegate = self;
    self.picker.dataSource = self;
    self.distanceTextField.delegate = self;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    [nc addObserver:self selector:@selector(keyboardWillShow:) name:
    UIKeyboardWillShowNotification object:nil];

    [nc addObserver:self selector:@selector(keyboardWillHide:) name:
    UIKeyboardWillHideNotification object:nil];

    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
    action:@selector(didTapAnywhere:)];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)picker numberOfRowsInComponent:(NSInteger)component {
    if ([self.reuseIdentifier isEqual:@"PriorityCell"])
    {
        return 5;
    }
    else
    {
        return 3;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString * title = nil;
    if ([self.reuseIdentifier isEqual:@"PriorityCell"])
    {
        switch(row) {
            case 0:
                title = @"5";
                break;
            case 1:
                title = @"4";
                break;
            case 2:
                title = @"3";
                break;
            case 3:
                title = @"2";
                break;
            case 4:
                title = @"1";
                break;
        }
    }
    else
    {
        switch (row) {
            case 0:
                title = @"No Preference";
                break;
            case 1:
                title = @"Male";
                break;
            case 2:
                title = @"Female";
                break;
            default:
                break;
        }
    }
    return title;
}

- (void)pickerView:(UIPickerView *)picker
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    //Here, like the table view you can get the each section of each row if you've multiple sections
    if ([self.reuseIdentifier isEqual:@"PriorityCell"])
    {
        self.filterValue = (int)(5 - row);
        switch (self.indexPath.row) {
            case 0:
                self.filterVC.workoutType = self.filterValue;
                break;
            case 1:
                self.filterVC.workoutTime = self.filterValue;
                break;
            case 2:
                self.filterVC.level = self.filterValue;
                break;
            default:
                break;
        }
    }
    else if ([self.reuseIdentifier isEqual:@"PriorityCell2"])
    {
        self.filterValue = (int)row;
        self.filterVC.gender = self.filterValue;
    }
}

- (void)setFilter
{
    if ([self.reuseIdentifier isEqual:@"PriorityCell"])
    {
        [self.picker selectRow:(5-self.filterValue) inComponent:0 animated:YES];
    }
    else if ([self.reuseIdentifier isEqual:@"PriorityCell2"])
    {
        [self.picker selectRow:self.filterValue inComponent:0 animated:YES];
    }
    else
    {
        self.distanceTextField.delegate = self;
        self.distanceTextField.text = [NSString stringWithFormat:@"%d", self.filterVC.distance];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    /* for backspace */
    if([string length]==0){
        return YES;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if (newLength > 2)
    {
        return NO;
    }
    
    /*  limit to only numeric characters  */
    NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    for (int i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        if ([myCharSet characterIsMember:c]) {
            return YES;
        }
    }
    
    return NO;
}

- (IBAction)textChanged:(id)sender {
    self.filterVC.distance = [self.distanceTextField.text intValue];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.filterVC.view endEditing:YES];
    return YES;
}

-(void)didTapAnywhere: (UITapGestureRecognizer*) recognizer {
    [self.filterVC.view endEditing:YES];
}

-(void) keyboardWillShow:(NSNotification *) note {
    [self.filterVC.view addGestureRecognizer:self.tapRecognizer];
}

-(void) keyboardWillHide:(NSNotification *) note
{
    [self.filterVC.view removeGestureRecognizer:self.tapRecognizer];
}

@end
