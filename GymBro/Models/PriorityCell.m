//
//  PriorityCell.m
//  GymBro
//
//  Created by Eric Moran on 7/28/22.
//

#import "PriorityCell.h"

@interface PriorityCell () <UIPickerViewDelegate, UIPickerViewDataSource>

@end


@implementation PriorityCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.picker.delegate = self;
    self.picker.dataSource = self;
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
        NSLog(@"1 - 5");
        NSLog(@"TITLE: %@, INDEX ROW: %ld", self.traitLabel.text, (long)self.indexPath.row);
        return 5;
    }
    else
    {
        NSLog(@"GENDER");
        NSLog(@"TITLE: %@, INDEX ROW: %ld", self.traitLabel.text, (long)self.indexPath.row);
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
            case 3:
                self.filterVC.distance1 = self.filterValue;
                break;
            case 4:
                self.filterVC.distance2 = self.filterValue;
                break;
            case 5:
                self.filterVC.distance3 = self.filterValue;
                break;
            default:
                break;
        }
    }
    else
    {
        switch (row) {
            case 0:
                self.filterVC.gender = 0;
                break;
            case 1:
                self.filterVC.gender = 1;
                break;
            case 2:
                self.filterVC.gender = 2;
                break;
            default:
                break;
        }
    }
}

- (void)setFilter
{
    if ([self.reuseIdentifier isEqual:@"PriorityCell"])
    {
        [self.picker selectRow:(5-self.filterValue) inComponent:0 animated:YES];
    }
    else
    {
        [self.picker selectRow:self.filterValue inComponent:0 animated:YES];
    }
}


@end
