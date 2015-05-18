//
//  GDBViewController.h
//  GDB
//
//  Created by Emiliano Auricchio on 21/04/13.
//  Copyright (c) 2013 Informatici Senza Frontiere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "CustomHttp.h"
#import "MBProgressHUD.h"
#import <AVFoundation/AVFoundation.h>
#import "UIVoicedLabel.h"

@class Reachability;
@class SBJsonStreamParser;
@class SBJsonStreamParserAdapter;

@interface StrilloneViewController : UIViewController <UITextFieldDelegate,CustomHttpDelegate, MBProgressHUDDelegate, AVSpeechSynthesizerDelegate> {

    IBOutlet UIButton *top_left,*top_right,*bottom_left,*bottom_right;
    CustomHttp *customHttp;
    MBProgressHUD *hud;
    IBOutlet UIVoicedLabel *voiceLabel;
    
    SBJsonStreamParser *parser;
    SBJsonStreamParserAdapter *adapter;
    
}

@property (nonatomic, strong) UIButton *top_left,*top_right,*bottom_left,*bottom_right;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UIVoicedLabel *voiceLabel;

-(void)parlaPeriOS7 :(NSString*)text;
-(IBAction)btn1:(id)sender;
-(IBAction)btn2:(id)sender;
-(IBAction)btn3:(id)sender;
-(IBAction)btn4:(id)sender;

- (CGFloat) window_height ;
- (CGFloat) window_width ;

@end

