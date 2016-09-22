//
//  SBLMessage.h
//  SBL
//
//  Created by Vlad Soroka on 6/13/16.
//  Copyright © 2016 com.sbl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GHMMessage : NSObject

+ (instancetype) messageWithTitle:(NSString*)title text:(NSString*)text;

@property(nonatomic, readonly) NSString* title;
@property(nonatomic, readonly) NSString* text;


@end
