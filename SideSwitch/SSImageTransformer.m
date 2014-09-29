//
//  SSImageTransformer.m
//  SideSwitch
//
//  Created by kenta on 2014/09/29.
//
//

#import "SSImageTransformer.h"

@implementation SSImageTransformer

+ (Class)transformedValueClass
{
    return [NSImage class];
}

- (id)transformedValue:(id)value
{
    if (!value) {
        return nil;
    }
    return value;
}

@end
