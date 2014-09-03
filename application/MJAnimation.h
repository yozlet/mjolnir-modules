//
//  MJAnimation.h
//  Application
//
//  Created by Yoz Grahame on 9/3/14.
//  Copyright (c) 2014 Mjolnir. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MJAnimation : NSAnimation

@property CGPoint newTopLeft;
@property CGPoint oldTopLeft;
@property CGSize newSize;
@property CGSize oldSize;
@property AXUIElementRef window;

@end
