//
//  SBLMessage.m
//  SBL
//
//  Created by Vlad Soroka on 6/13/16.
//  Copyright © 2016 com.sbl. All rights reserved.
//

#import "GHMMessage.h"

@implementation GHMMessage

+ (instancetype)messageWithTitle:(NSString *)title text:(NSString *)text {
    return [[self alloc] initWithTitle:title text:text];
}

- (instancetype) initWithTitle:(NSString*)title text:(NSString*) text {
    self = [super init];
    if (!self) return nil;
    
    _title = title;
    _text = text;
    
    return self;
}

@end
