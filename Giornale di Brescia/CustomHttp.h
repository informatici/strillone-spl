//
//  CustomHttp.h
//
//  Created by Emiliano Auricchio on 12/05/12.
//  Copyright (c) 2012 ELFapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "Constant.h"

@class Reachability;

@class CustomHttp;

@protocol CustomHttpDelegate <NSObject>
@optional
-(void)datiOnline:(NSMutableArray *)listItem;
@end

@interface CustomHttp : NSObject {
    id <CustomHttpDelegate> delegate;

}

@property (nonatomic, assign ) id <CustomHttpDelegate> delegate;


-(void) sendRequest:(NSString *)urlRequest restJson:(NSMutableArray*)restJson methodHttp:(NSString*)methodHttp;


@end

