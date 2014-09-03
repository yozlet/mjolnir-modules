//
//  MJAnimation.m
//  Application
//
//  Created by Yoz Grahame on 9/3/14.
//  Copyright (c) 2014 Mjolnir. All rights reserved.
//

#import "MJAnimation.h"

@implementation MJAnimation

- (void)setCurrentProgress:(NSAnimationProgress)progress
{
    // Call super to update the progress value.
    [super setCurrentProgress:progress];
    float value = self.currentValue;
    
    CGPoint thePoint = (CGPoint){
        _oldTopLeft.x + value * (_newTopLeft.x - _oldTopLeft.x),
        _oldTopLeft.y + value * (_newTopLeft.y - _oldTopLeft.y)
    };
    
    CGSize theSize = (CGSize){
        _oldSize.width + value * (_newSize.width - _oldSize.width),
        _oldSize.height + value * (_newSize.height - _oldSize.height)
    };
    
    // Update the window position & size.
    CFTypeRef positionStorage = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&thePoint));
    CFTypeRef sizeStorage = (CFTypeRef)(AXValueCreate(kAXValueCGSizeType, (const void *)&theSize));
    
    AXUIElementSetAttributeValue(_window, (CFStringRef)NSAccessibilityPositionAttribute, positionStorage);
    AXUIElementSetAttributeValue(_window, (CFStringRef)NSAccessibilitySizeAttribute, sizeStorage);

    if (sizeStorage) CFRelease(sizeStorage);
    if (positionStorage) CFRelease(positionStorage);
}

@end

