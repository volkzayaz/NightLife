//
//  SBLViewModel.m
//  SBL
//
//  Created by Vlad Soroka on 6/9/16.
//  Copyright © 2016 com.sbl. All rights reserved.
//

#import "GHMViewModel.h"
#import "GHMViewModel_Protected.h"

#import "NSError+GHM.h"

@interface GHMViewModel ()
@end

@implementation GHMViewModel

@synthesize message = _message;

- (void)handleError:(NSError *)error {
    
    self.message = [error messageFromError];
    
}

@end
