//
//  GDBViewController.m
//  GDB
//
//  Created by Emiliano Auricchio on 21/04/13.
//  Copyright (c) 2013 Informatici Senza Frontiere. All rights reserved.
//

#import "StrilloneViewController.h"
#import "Constant.h"
#import "SVProgressHUD.h"
#import "SBJson.h"

#define IS_IOS6_AND_UP ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
#define IS_IOS7_AND_UP ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
#define MY_SPEECH_RATE  0.5
#define MY_SPEECH_MPX  1.0


@implementation StrilloneViewController

@synthesize top_left,top_right,bottom_left,bottom_right, hud, voiceLabel;

NSDictionary *sezioniDict;
NSMutableArray *edizioniArray, *sezioniArray;
NSString *language;

int tree_level = 0;
int testata_position = -1;
int sezione_position = -1;
int articolo_position = -1;

- (void) readMessage:(NSString *)text btn:(UIButton*)btn {
    
    //  NSData *textdata = [text dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    // if (textdata) {
    //   text = [[NSString alloc] initWithData:textdata encoding:NSASCIIStringEncoding];
    //  }
    
    
    NSData *dataText = [text dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    text = [[NSString alloc] initWithData:dataText encoding:NSASCIIStringEncoding];
    text = [self replaceHtmlEntities:text];
    
    if (text && [text length]>0 && ![text isEqualToString:@"(null)"]) {
        if (IS_IOS7_AND_UP && !UIAccessibilityIsVoiceOverRunning()) {
            [self parlaPeriOS7:text];
        } else {
            [voiceLabel setText:text];
            [btn setAccessibilityLabel:text];
            [btn setAccessibilityHint:text];
        }
    }
#if DEBUG_LOG
    NSLog(@"testo letto :%@",text);
#endif
}

- (NSString *)replaceHtmlEntities:(NSString *)htmlCode {
    
    NSMutableString *temp = [NSMutableString stringWithString:htmlCode];
    
    [temp replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&nbsp;" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    
    [temp replaceOccurrencesOfString:@"&Agrave;" withString:@"À" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Aacute;" withString:@"Á" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Acirc;" withString:@"Â" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Atilde;" withString:@"Ã" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Auml;" withString:@"Ä" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Aring;" withString:@"Å" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&AElig;" withString:@"Æ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Ccedil;" withString:@"Ç" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Egrave;" withString:@"È" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Eacute;" withString:@"É" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Ecirc;" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Euml;" withString:@"Ë" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Igrave;" withString:@"Ì" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Iacute;" withString:@"Í" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Icirc;" withString:@"Î" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Iuml;" withString:@"Ï" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&ETH;" withString:@"Ð" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Ntilde;" withString:@"Ñ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Ograve;" withString:@"Ò" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Oacute;" withString:@"Ó" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Ocirc;" withString:@"Ô" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Otilde;" withString:@"Õ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Ouml;" withString:@"Ö" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Oslash;" withString:@"Ø" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Ugrave;" withString:@"Ù" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Uacute;" withString:@"Ú" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Ucirc;" withString:@"Û" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Uuml;" withString:@"Ü" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&Yacute;" withString:@"Ý" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&THORN;" withString:@"Þ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&szlig;" withString:@"ß" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&agrave;" withString:@"à" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&aacute;" withString:@"á" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&acirc;" withString:@"â" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&atilde;" withString:@"ã" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&auml;" withString:@"ä" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&aring;" withString:@"å" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&aelig;" withString:@"æ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&ccedil;" withString:@"ç" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&egrave;" withString:@"è" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&eacute;" withString:@"é" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&ecirc;" withString:@"ê" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&euml;" withString:@"ë" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&igrave;" withString:@"ì" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&iacute;" withString:@"í" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&icirc;" withString:@"î" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&iuml;" withString:@"ï" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&eth;" withString:@"ð" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&ntilde;" withString:@"ñ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&ograve;" withString:@"ò" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&oacute;" withString:@"ó" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&ocirc;" withString:@"ô" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&otilde;" withString:@"õ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&ouml;" withString:@"ö" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&oslash;" withString:@"ø" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&ugrave;" withString:@"ù" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&uacute;" withString:@"ú" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&ucirc;" withString:@"û" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&uuml;" withString:@"ü" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&yacute;" withString:@"ý" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&thorn;" withString:@"þ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&yuml;" withString:@"ÿ" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    
    
    return [NSString stringWithString:temp];
    
}

AVSpeechSynthesizer *textToSpeech;

- (void)parlaPeriOS7 :(NSString*)text {
    
    if (!textToSpeech) textToSpeech = [AVSpeechSynthesizer new];
    
    [textToSpeech stopSpeakingAtBoundary:YES];
    NSString *language = [AVSpeechSynthesisVoice currentLanguageCode];
    if (language==nil) language = @"it-IT";
    AVSpeechUtterance *speak = [AVSpeechUtterance speechUtteranceWithString:text];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    float velocita = [defaults integerForKey:@"velocita"];
    
    if (!velocita || velocita == 0) {
        [speak setRate:MY_SPEECH_RATE];
    } else {
        velocita = velocita / 100;
        [speak setRate:velocita];
    }
    
    
    [speak setPitchMultiplier:MY_SPEECH_MPX];
    [speak setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:language]];
    [textToSpeech speakUtterance:speak];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    customHttp = [[CustomHttp alloc] init];
    [customHttp setDelegate:self];
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"nav_home", nil)];
    
    tree_level = 0;
    
    testata_position = -1;
    sezione_position = -1;
    articolo_position = -1;
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
}

- (void)datiOnline:(NSMutableArray *)listItem {
    
    sezioniArray = [[listItem valueForKey:@"giornale"] valueForKey:@"sezione"];
#if DEBUG_LOG
    NSLog(@"sezioniArray bytes %d",[sezioniArray count]);
#endif
    [self performSelectorOnMainThread:@selector(leggiEdizionePronta) withObject:nil waitUntilDone:NO];
    
}

-(void)leggiEdizionePronta {
    [SVProgressHUD dismiss];
    [self readMessage:[NSString stringWithFormat:NSLocalizedString(@"nav_read_success",nil),[[edizioniArray objectAtIndex:testata_position] valueForKey:@"nome"],[self data2StringExtend:[[edizioniArray objectAtIndex:testata_position] valueForKey:@"edizione"]]] btn:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100 && [[alertView textFieldAtIndex:0] text].length > 0) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:[alertView textFieldAtIndex:0].text forKey:@"utente"];
        [self viewDidAppear:YES];
    } else if ([[alertView textFieldAtIndex:0] text].length == 0){
        [self viewDidAppear:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:YES];
    [self setSizeButton];
    
    voiceLabel = [[UIVoicedLabel alloc] init];
    [voiceLabel setText:@""];
    
    /*
     utente = [[NSUserDefaults standardUserDefaults] stringForKey:@"utente"];
     
     if ([utente length]==0) {
     UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Strillone" message:@"Inserisci l'utente per l'accesso" delegate:self cancelButtonTitle:@"Salva" otherButtonTitles:nil];
     [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
     [alert setTag:100];
     UITextField* textField = [alert textFieldAtIndex:0];
     textField.text = @"";
     [textField setAccessibilityLabel:@"Campo inserimento utente"];
     [alert show];
     } else {
     */
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    if (internetStatus != NotReachable) {
        [SVProgressHUD showWithStatus:@""];
        
        NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:URL_XML_EDIZIONI]];
        NSURLResponse * response = nil;
        NSError * error = nil;
        NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //responseString = [responseString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        SBJsonParser *jsonReader = [[SBJsonParser alloc] init];
        
        NSMutableArray *jsonTestate = [jsonReader objectWithString:responseString];
        
        edizioniArray = [[jsonTestate valueForKey:@"testate"] valueForKey:@"testata"];
        
        [self pulizia];
        
#if DEBUG_LOG
        NSLog(@"jsonTestate %@",edizioniArray);
#endif
        [SVProgressHUD dismiss];
        
    } else {
        UIAlertView *avvisoRete = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"connecting_error",nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [avvisoRete show];
    }
    
}

- (void) pulizia {
    NSMutableArray *nuovaLista = [[NSMutableArray alloc] init];
    
    for (int i=0; i<[edizioniArray count]; i++) {
        
        if ([[[edizioniArray objectAtIndex:i] valueForKey:@"lingua"] isEqualToString:language] && [[edizioniArray objectAtIndex:i] valueForKey:@"beta"] == nil) {
            [nuovaLista addObject:[edizioniArray objectAtIndex:i]];
        }
    }
    
    edizioniArray = nuovaLista;
    
}

- (void) setSizeButton {
    
    //* first button
    
    [top_left setAccessibilityLabel:NSLocalizedString(@"cdupperleft", nil)];
    
    CGRect frameButton = top_left.frame;
    frameButton.origin.x = 0;
    frameButton.origin.y = 0;
    frameButton.size.width = [self window_width] / 2;
    frameButton.size.height = [self window_height] / 2;
    top_left.frame = frameButton;
    
    //* second button
    
    [top_right setAccessibilityLabel:NSLocalizedString(@"cdupperright", nil)];
    
    frameButton = top_right.frame;
    frameButton.origin.x = [self window_width] / 2;;
    frameButton.origin.y = 0;
    frameButton.size.width = [self window_width] / 2;
    frameButton.size.height = [self window_height] / 2;
    top_right.frame = frameButton;
    
    // third button
    
    [bottom_left setAccessibilityLabel:NSLocalizedString(@"cdlowerleft", nil)];
    
    frameButton = bottom_left.frame;
    frameButton.origin.x = 0;
    frameButton.origin.y = [self window_height] / 2;
    frameButton.size.width = [self window_width] / 2;
    frameButton.size.height = [self window_height] / 2;
    bottom_left.frame = frameButton;
    
    // four button
    
    [bottom_right setAccessibilityLabel:NSLocalizedString(@"cdlowerright", nil)];
    
    frameButton = bottom_right.frame;
    frameButton.origin.x = [self window_width] / 2;
    frameButton.origin.y = [self window_height] / 2;;
    frameButton.size.width = [self window_width] / 2;
    frameButton.size.height = [self window_height] / 2;
    bottom_right.frame = frameButton;
    
}

-(void) printLog {
#if DEBUG_LOG
    NSLog(@"*************************************");
    NSLog(@"Livello :%d",tree_level);
    NSLog(@"posEdizioni :%d",testata_position);
    NSLog(@"posSezioni :%d",sezione_position);
    NSLog(@"posArticoli :%d",articolo_position);
    NSLog(@"*************************************");
#endif
}


-(IBAction)btn1:(id)sender {
    [self printLog];
    [self setSizeButton];
    
    switch (tree_level) {
        case TESTATA:{
            tree_level = TESTATA;
            testata_position = 0;
            sezione_position = -1;
            articolo_position = -1;
            [self readMessage:NSLocalizedString(@"nav_home", nil) btn:(UIButton*)sender];
        }
            break;
        case SEZIONE:{
            tree_level = TESTATA;
            testata_position = -1;
            sezione_position = -1;
            articolo_position = -1;
            [self readMessage:NSLocalizedString(@"nav_go_testate", nil)btn:(UIButton*)sender];
        }
            break;
        case ARTICOLO:{
            tree_level = SEZIONE;
            articolo_position = -1;
            [self readMessage:NSLocalizedString(@"nav_go_sezioni", nil)btn:(UIButton*)sender];
        }
            break;
        default:
            break;
    }
}



-(IBAction)btn2:(id)sender {
    [self printLog];
    @try {
        switch (tree_level) {
            case TESTATA:{
                testata_position = testata_position - 1;
                articolo_position = 0;
                sezione_position = 0;
                if (testata_position < 0) {
                    testata_position = 0;
                }
                
                NSString *stringaDaLeggere = [NSString stringWithFormat:@"%@, %@",[[edizioniArray objectAtIndex:testata_position] valueForKey:@"nome"], [self data2StringExtend:[[edizioniArray objectAtIndex:testata_position] valueForKey:@"edizione"]] ];
                
                [self readMessage:stringaDaLeggere btn:(UIButton*)sender];
            }
                break;
                
            case SEZIONE:{
                sezione_position = sezione_position -1;
                articolo_position = 0;
                if (sezione_position < 0) {
                    sezione_position = 0;
                }
                [self readMessage:[[sezioniArray objectAtIndex:sezione_position] valueForKey:@"nome"] btn:(UIButton*)sender];
            }
                break;
                
            case ARTICOLO:{
                
                articolo_position = articolo_position -1;
                
                if ([[[[sezioniArray objectAtIndex:sezione_position] valueForKey:@"articolo"] valueForKey:@"titolo"] isKindOfClass:[NSString class]]) {
                    articolo_position = 0;
                    [self readMessage:[[[sezioniArray objectAtIndex:sezione_position] valueForKey:@"articolo"] valueForKey:@"titolo"] btn:(UIButton*)sender];
                } else {
                    if (articolo_position < 0) {
                        articolo_position = 0;
                    }
                    [self readMessage:[[[[sezioniArray objectAtIndex:sezione_position] valueForKey:@"articolo"] valueForKey:@"titolo"] objectAtIndex:articolo_position] btn:(UIButton*)sender];
                }
                
            }
                break;
            default:
                break;
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        [self readMessage:NSLocalizedString(@"datanotavailable", nil)btn:(UIButton*)sender];
    }
    
}

-(IBAction)btn3:(id)sender {
    [self printLog];
    
    [self setSizeButton];
    
    @try {
        switch (tree_level) {
            case TESTATA:{
                if (testata_position < 0) {
                    testata_position = 0;
                }
                
                if ([edizioniArray count] > 0) {
                    
                    Reachability *reachability = [Reachability reachabilityForInternetConnection];
                    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
                    
                    if (internetStatus != NotReachable) {
                        tree_level = SEZIONE;
                        sezione_position = -1;
                        
                        [self readMessage:@""btn:(UIButton*)sender];
                        
                        [SVProgressHUD showWithStatus:NSLocalizedString(@"caricamentoincorso", nil)];
                        
                        [customHttp sendRequest:[[edizioniArray objectAtIndex:testata_position] valueForKey:@"url"] restJson:nil methodHttp:@"GET"];
                        
                    } else {
                        UIAlertView *avvisoRete = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"connecting_error", nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [avvisoRete show];
                    }
                    
                } else {
                    [self readMessage:NSLocalizedString(@"datanotavailable", nil)btn:(UIButton*)sender];
                }
            }
                break;
                
            case SEZIONE:{
                if (sezione_position < 0) {
                    sezione_position = 0;
                }
                
                if ([[[sezioniArray  objectAtIndex:sezione_position] valueForKey:@"articolo"] count ] > 0) {
                    articolo_position = -1;
                    tree_level = ARTICOLO;
                    [self readMessage:[NSString stringWithFormat:NSLocalizedString(@"nav_enter_section",nil),[[sezioniArray objectAtIndex:sezione_position] valueForKey:@"nome"]] btn:(UIButton*)sender];
                }
                
            }
                break;
                
            case ARTICOLO: {
                if (articolo_position < 0) {
                    articolo_position = 0;
                }
                
                if ([[[[sezioniArray objectAtIndex:sezione_position] valueForKey:@"articolo"] valueForKey:@"titolo"] isKindOfClass:[NSString class]]) {
                    articolo_position = 0;
                    [self readMessage:[[[sezioniArray objectAtIndex:sezione_position] valueForKey:@"articolo"] valueForKey:@"testo"] btn:(UIButton*)sender];
                } else {
                    [self readMessage:[[[[sezioniArray objectAtIndex:sezione_position] valueForKey:@"articolo"] valueForKey:@"testo"] objectAtIndex:articolo_position] btn:(UIButton*)sender];
                }
                
            }
                break;
            default:
                break;
        }
        
    }
    @catch (NSException *exception) {
        [self readMessage:NSLocalizedString(@"datanotavailable", nil)btn:(UIButton*)sender];
    }
    
}

-(IBAction)btn4:(id)sender {
    [self printLog];
    @try {
        switch (tree_level) {
                
            case TESTATA:{
                testata_position = testata_position + 1;
                articolo_position = 0;
                sezione_position = 0;
                if (testata_position >= [edizioniArray count]) {
                    testata_position = [edizioniArray count] -1;
                }
                
                NSString *stringaDaLeggere = [NSString stringWithFormat:@"%@, %@",[[edizioniArray objectAtIndex:testata_position] valueForKey:@"nome"], [self data2StringExtend:[[edizioniArray objectAtIndex:testata_position] valueForKey:@"edizione"]] ];
                
                [self readMessage:stringaDaLeggere btn:(UIButton*)sender];
            }
                break;
                
            case SEZIONE: {
                articolo_position = 0;
                sezione_position = sezione_position+1;
                if (sezione_position >= [sezioniArray count]) {
                    sezione_position = [sezioniArray count] -1;
                }
                [self readMessage:[[sezioniArray objectAtIndex:sezione_position] valueForKey:@"nome"] btn:(UIButton*)sender];
            }
                break;
                
            case ARTICOLO:{
                
                articolo_position = articolo_position + 1;
                
                //NSLog(@"%@",[[[sezioniArray objectAtIndex:sezione_position] valueForKey:@"articolo"] valueForKey:@"titolo"]);
                
                if ([[[[sezioniArray objectAtIndex:sezione_position] valueForKey:@"articolo"] valueForKey:@"titolo"] isKindOfClass:[NSString class]]) {
                    articolo_position = 0;
                    [self readMessage:[[[sezioniArray objectAtIndex:sezione_position] valueForKey:@"articolo"] valueForKey:@"titolo"] btn:(UIButton*)sender];
                } else {
                    if (articolo_position >= [[[[sezioniArray objectAtIndex:sezione_position] valueForKey:@"articolo"] valueForKey:@"titolo"] count]) {
                        articolo_position = [[[[sezioniArray objectAtIndex:sezione_position] valueForKey:@"articolo"] valueForKey:@"titolo"] count] -1;
                    }
                    
                    [self readMessage:[[[[sezioniArray objectAtIndex:sezione_position] valueForKey:@"articolo"] valueForKey:@"titolo"] objectAtIndex:articolo_position] btn:(UIButton*)sender];
                }
            }
                break;
                
            default:
                break;
        }
        
    }
    @catch (NSException *exception) {
        [self readMessage:NSLocalizedString(@"datanotavailable", nil)btn:(UIButton*)sender];
    }
    
}

//* pre 6

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    [self setSizeButton];
    return YES;
}

//* post 6
- (BOOL)shouldAutorotate {
    [self updateViewConstraints];
    [self setSizeButton];
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    NSUInteger orientations = UIInterfaceOrientationMaskAll;
    return orientations;
}


- (CGFloat) window_height   {
    return CGRectGetHeight(self.view.bounds);
}

- (CGFloat) window_width   {
    return CGRectGetWidth(self.view.bounds);
}

-(NSString*)data2StringExtend :(NSString*)dataInput{
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"it_IT"];
    
    if ([language isEqualToString:@"en"]) {
        usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_EN"];
    }
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setLocale:usLocale];
    
    [dateFormater setDateFormat:@"yyyy-MM-dd"];
    NSDate *currentDate = [dateFormater dateFromString:dataInput];
    
    [dateFormater setDateStyle:NSDateFormatterFullStyle];
    NSString *convertedDateString = [dateFormater stringFromDate:currentDate];
    
    return convertedDateString;
    
}



@end
