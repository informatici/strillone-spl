//
//  UIVoicedLabel.m
//  Strillone
//
//  Created by Emiliano Auricchio on 01/11/13.
//  Copyright (c) 2013 Informatici Senza Frontiere. All rights reserved.
//

#import "UIVoicedLabel.h"

@implementation UIVoicedLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void) setText:(NSString *)text {
    // Set the text by calling the base class method.
    [super setText:text];
    // Announce the new text.
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, text);
}



@end
