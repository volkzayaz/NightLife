//
//  SBLViewControllerProtocol.h
//  SBL
//
//  Created by Vlad Soroka on 6/13/16.
//  Copyright © 2016 com.sbl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GHMViewModel;

/**
 *  @discussion - dynamically implemented into GHMViewController.m file
 */
@protocol GHMViewControllerProtocol <NSObject>

- (GHMViewModel*) viewModel;
- (void) setViewModel:(GHMViewModel*) viewModel;

@end
