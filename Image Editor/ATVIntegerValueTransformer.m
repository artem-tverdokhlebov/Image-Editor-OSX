//
//  ATVIntegerValueTransformer.m
//  Image Editor
//
//  Created by Артём Твердохлебов on 8/28/16.
//  Copyright © 2016 Артём Твердохлебов. All rights reserved.
//

#import "ATVIntegerValueTransformer.h"

@implementation ATVIntegerValueTransformer

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return value;
}

- (id)reverseTransformedValue:(id)value
{
    NSNumber *result = @(0.0);
    
    if (value)
    {
        result = value;
    }
    
    return result;
}

@end
