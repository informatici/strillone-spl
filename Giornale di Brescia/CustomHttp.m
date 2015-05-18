//
//  CustomHttp.m
//
//  Created by Emiliano Auricchio on 12/05/12.
//  Copyright (c) 2012 ELFapps. All rights reserved.
//

#import "CustomHttp.h"
#import "StrilloneAppDelegate.h"
#import <CommonCrypto/CommonDigest.h>
#import "SBJson.h"
#import "SVProgressHUD.h"

@implementation CustomHttp

@synthesize delegate = _delegate;

BOOL hostActive, internetActive;

-(void) sendRequest:(NSString *)urlRequest restJson:(NSDictionary*)restJson methodHttp:(NSString*)methodHttp {
   
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

        SBJsonParser *jsonReader = [[SBJsonParser alloc] init];
    
        Reachability *reachability = [Reachability reachabilityForInternetConnection];    
        NetworkStatus internetStatus = [reachability currentReachabilityStatus];
        
        if (internetStatus != NotReachable) {
            @try {
                
                NSURL *url = [NSURL URLWithString:urlRequest];
#if DEBUG_LOG
                NSLog(@"url :%@\n  methodHttp : %@",url, methodHttp);
#endif
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                
                [request setHTTPMethod:methodHttp];
                [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                [request setValue:[NSString stringWithFormat:@"%@",[[NSLocale preferredLanguages] objectAtIndex:0]] forHTTPHeaderField:@"Accept-Language"];
                [request setTimeoutInterval:60];
                
                [NSURLConnection
                 sendAsynchronousRequest:request
                 queue:[[NSOperationQueue alloc] init]
                 completionHandler:^(NSURLResponse *response,
                                     NSData *responseData,
                                     NSError *error) 
                 {
                     if (error == nil)
                     {
                         NSMutableString *responseString = [[NSMutableString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

                         
#if DEBUG_LOG
                         NSLog(@"risposta CustomHttp:\n%lu",(unsigned long)[responseString length]);
#endif

                         if ([responseString length] == 0) {
                          //   NSLog(@"codifica UTF8 andata male, provo ASCII");
                             responseString = [[NSMutableString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
                         }
                         
                         responseString = [NSMutableString stringWithString:[responseString stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
                         responseString = [NSMutableString stringWithString:[responseString stringByReplacingOccurrencesOfString:@"\r" withString:@""]];
                         responseString = [NSMutableString stringWithString:[responseString stringByReplacingOccurrencesOfString:@"\t" withString:@""]];
                         
                       //  NSLog(@"%@",responseString);
                         
                         NSMutableArray *jsonRicevuto = [jsonReader objectWithString:responseString];
                         
                         if ([jsonRicevuto count] > 0) {
                             if (_delegate && [_delegate respondsToSelector:@selector(datiOnline:)]) {
                                 [_delegate datiOnline:jsonRicevuto];
                             }
                         } else {
                             NSLog(@"parsing error");
                             if (_delegate && [_delegate respondsToSelector:@selector(datiOnline:)]) {
                                 [_delegate datiOnline:[[NSMutableArray alloc] initWithCapacity:0]];
                             }
                         }
                     }
                     else if (error == nil)
                     {
                         NSLog(@"Nulla da scaricare");
                     }
                     else if (error != nil){
                         NSLog(@"Errore = %@", error);
                         if (_delegate && [_delegate respondsToSelector:@selector(datiOnline:)]) {
                             [_delegate datiOnline:[[NSMutableArray alloc] initWithCapacity:0]];
                         }
                     }
                 }];
            }
            @catch (NSException *exception) {
                NSLog(@"Problemi nel download del json: %@", exception);
            }

        } else {
            UIAlertView *avvisoRete = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"connecting_error",nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [avvisoRete show];
        }
 
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


@end
