//
//  SBLViewController.m
//  SBL
//
//  Created by Vlad Soroka on 6/9/16.
//  Copyright © 2016 com.sbl. All rights reserved.
//

///SBL imports
#import "GHMViewControllerProtocol.h"
#import "GHMViewModel.h"
#import "GHMMessage.h"

#import "PXAlertView.h"

///external
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <objc/runtime.h>
#import <stdlib.h>

bool class_hasSelectorImplemented(Class clz, SEL selector) {
    
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(clz, &methodCount);
    
    bool answer = false;
    
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        NSString* methodName = NSStringFromSelector(method_getName(method));
        NSString* searchForMethodName = NSStringFromSelector(selector);
        
        if ([methodName isEqualToString:searchForMethodName]) {
            answer = true;
            break;
        }
        
    }
    
    free(methods);
    
    return answer;
}

@implementation UIViewController (GHMViewController)

+ (void)load {
    
    Protocol *protocol = @protocol(GHMViewControllerProtocol);
    
    int numberOfClasses = objc_getClassList(NULL, 0);
    __unsafe_unretained Class *classList = (Class*) malloc(numberOfClasses * sizeof(Class));
    numberOfClasses = objc_getClassList(classList, numberOfClasses);
    
    for (int idx = 0; idx < numberOfClasses; idx++)
    {
        Class class = classList[idx];
        if (class_conformsToProtocol(class, protocol))
        {
            //NSLog(@"Doing stuff for class %@", NSStringFromClass(class));
            [self dynamicallyImplementSBLProtocolForClass:class];
        }
    }
    
    free(classList);
}



+ (void) dynamicallyImplementSBLProtocolForClass: (Class) class {
    
    ///1. getting implementation we want to inject into SBLViewControllers
    IMP impl = class_getMethodImplementation(self, @selector(swizzle_viewDidLoad));
    SEL selectorOfInterest = @selector(viewDidLoad);
    
    if (class_hasSelectorImplemented(class, selectorOfInterest))
    {
        ///in case class implements viewDidLoad itself we need to call it's implementation after
        ///injected behaviour. For this, we do the following:
        
        ///step 1 - obtain original viewDidLoad method
        Method viewDidLoadMethod = class_getInstanceMethod(class, selectorOfInterest);
        
        ///step 2 - set implementation of swizzle_viewDidLoad as implementation of viewDidLoad method
        IMP originalImplementation = method_setImplementation(viewDidLoadMethod, impl);
        
        ///step 3 - add new method to class identical to viewDidLoad with name 'SBL_ClassName_viewDidLoad'
        ///set it's implementaion equal to original implementation of viewDidLoad
        SEL newSelector = [self originalImplementationSelectorForClass:class];
        const char *types = [[NSString stringWithFormat:@"%s", @encode(void)] UTF8String];
        class_addMethod(class, newSelector, originalImplementation, types);

    }
    else
    {
        ///in case class does not implement viewDidLoad, we'll add this method dynamically
        
        const char *types = [[NSString stringWithFormat:@"%s", @encode(void)] UTF8String];
        class_addMethod(class, selectorOfInterest, impl, types);
    }
}

+ (SEL) originalImplementationSelectorForClass:(Class) class {
    
    NSString* originalImplementationMethodName = [NSString stringWithFormat:@"GHM_%@_viewDidLoad", NSStringFromClass(class)];
    
    return NSSelectorFromString(originalImplementationMethodName);
}

- (void) swizzle_viewDidLoad {
    
    NSAssert ([self conformsToProtocol:@protocol(GHMViewControllerProtocol)], @"Logic error. Shouldn't swizzle method if class does not conform to SBLViewControllerProtocol");
    
    id<GHMViewControllerProtocol> _self = (id<GHMViewControllerProtocol>)self;
    
    NSAssert([_self viewModel] != nil, @"Can't load GHMViewController prior to set up GHMViewModel");
    
    ////-------------------------
    
    ////binding viewModel's message to showing PXAlertView
    [[RACObserve([_self viewModel], message) filter:^BOOL(GHMMessage* x) {
        return x != nil && x.text.length > 0 && x.title.length > 0;
    }] subscribeNext:^(GHMMessage* x) {
        [PXAlertView showAlertWithTitle:x.title message:x.text];
    }];
    
    ////-------------------------
    ///calling original viewDidLoad if any were present
    
    SEL originalSelector = [UIViewController originalImplementationSelectorForClass:self.class];
    if ([self respondsToSelector:originalSelector]) {
    
        IMP imp = [self methodForSelector:originalSelector];
        void (*func)(id, SEL) = (void *)imp;
        func(self, originalSelector);
        
    }
    
}

@end
